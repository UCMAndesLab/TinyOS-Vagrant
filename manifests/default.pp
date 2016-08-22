include apt

# Update everything
exec { 'apt-update':
    command => '/usr/bin/apt-get update'
}

#install tinyos
class tinyosPre{
    # Get Build Tools
    $builders = [ 'build-essential', 'stow', 'automake', 'autoconf', 'libtool', 'libc6-dev' ]
    package { $tinyosPre::builders: ensure => 'installed', require => Exec['apt-update'] }

    # Get Git Tools
    $git = [ 'git-core', 'git-daemon-run', 'git-doc', 'git-email', 'git-gui', 'gitk', 'gitmagic' ]
    package { $tinyosPre::git: ensure => 'installed', require => Exec['apt-update'] }

    # Get SSH Client and Server (probably for serial forwarder scripts)
    $ssh = [ 'openssh-client', 'openssh-server' ]
    package { $tinyosPre::ssh: ensure => 'installed', require => Exec['apt-update'] }

    # Get python for support scripts
    $py = [ 'python3', 'python3-serial', 'python', 'python-serial' ]
    package { $tinyosPre::py: ensure => 'installed', require => Exec['apt-update'] }
}

### Get Tinyos tools Ready

## TinyProd
# Get TinyProd key. Puppet will complain about the short id. Tinyprod doesn't provide a better key.
apt::key{'tinyprod':
    id => 'A9B913B9',
    server => 'keyserver.ubuntu.com',
}

# Add Source
apt::source{'tinyprod':
    comment => "TinyOS Dev tools and nesc",
    location => "http://tinyprod.net/repos/debian/",
    repos => 'main',
    release => 'wheezy',
}

apt::source{'tinyprod-msp430':
    comment => "Msp430 toolchain",
    location => "http://tinyprod.net/repos/debian/",
    repos => 'main',
    release => 'msp430-46',
}

# Build Tools for Tinyos
class tinyos-tools{
#    $tiny = [ 'nesc', 'tinyos-tools-devel', 'msp430-46', 'mspdebug' ]
    $tiny = [ 'nesc', 'msp430-46', 'mspdebug' ]
    package { $tiny:
        require => [ Exec['apt-update'],
            Apt::Source['tinyprod'],
            Apt::Source['tinyprod-msp430'],
            Apt::Key['tinyprod'], ],
        ensure => 'installed',
    }

}

# Get main tinyos repo
class tinyos-main{
    vcsrepo{'/opt/tinyos':
        ensure => present,
        provider => git,
        source => 'https://github.com/tinyos/tinyos-main.git',
        require => Class['tinyos-tools'],
    }

	# Copy profile into home directory
    # This is for makefiles
    file{'/home/ubuntu/.profile':
        mode => "0644",
        owner => 'ubuntu',
        group => 'ubuntu',

# There is probably a better way of copying a file. Like a master puppet server, but this
# is a work arround.
        content => '# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
fi

# set PATH so it includes users private bin directories
PATH="$HOME/bin:$HOME/.local/bin:$PATH"

MOTECOM="serial@/dev/ttyUSB0:telosb"

TOSROOT=/opt/tinyos
TOSDIR=$TOSROOT/tos

MAKERULES=$TOSROOT/support/make/Makerules
CLASSPATH=.:$TOSROOT/support/sdk/java/tinyos.jar

PYTHONPATH=$TOSROOT/support/sdk/python:$PYTHONPATH

export MAKERULES TOSDIR TOSROOT CLASSPATH PYTHONPATH
export MOTECOM',

	}


    # We should be ready to compile the tinyos repo
    exec{'tiny-compile':
        path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin',
        cwd  => '/opt/tinyos/tools/',
        command => 'bash -c ./Bootstrap && bash -c ./configure && make && sudo make install && chown -R ubuntu:ubuntu /opt/tinyos/',
        require => Vcsrepo['/opt/tinyos'],
    }
}



# Vagrant doesn't come with the necessary drivers to do serial communication/programming.
# The following package adds it.
package {'linux-image-extra-virtual':
    require => Exec['apt-update'],
}

include tinyosPre
include tinyos-tools
include tinyos-main
