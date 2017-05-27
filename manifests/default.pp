include apt

# Update everything
exec { 'apt-update':
    command => '/usr/bin/apt-get update'
}

#install tinyos
class tinyosPre{
    # Get Build Tools
    $builders = [
        'build-essential',
        'stow',
        'automake',
        'autoconf',
        'libtool',
        'libc6-dev'
    ]
    package { $tinyosPre::builders:
        ensure  => 'installed',
        require => Exec['apt-update']
    }

    # Get Git Tools
    $git = [
        'git-core',
        'git-daemon-run',
        'git-doc',
        'git-email',
        'git-gui',
        'gitk',
        'gitmagic'
    ]
    package { $tinyosPre::git:
        ensure  => 'installed',
        require => Exec['apt-update']
    }

    # Get SSH Client and Server (probably for serial forwarder scripts)
    $ssh = [
        'openssh-client',
        'openssh-server'
    ]
    package { $tinyosPre::ssh:
        ensure  => 'installed',
        require => Exec['apt-update']
    }

    # Get python for support scripts
    $py = [
        'python3',
        'python3-serial',
        'python',
        'python-serial',
        'python-dev',
        'gcc-4.8',
        'g++-4.8'
    ]
    package { $tinyosPre::py:
        ensure  => 'installed',
        require => Exec['apt-update']
    }
}

### Get Tinyos tools Ready

## TinyProd
# Get TinyProd key. Puppet will complain about the short id. Tinyprod doesn't provide a better key.
apt::key{'tinyprod':
    id     => 'E071DBCA24B8A9B913B9',
    server => 'keyserver.ubuntu.com'
}

# Add Source
apt::source{'tinyprod':
    comment  => "TinyOS Dev tools and nesc",
    location => "http://tinyprod.net/repos/debian/",
    repos    => 'main',
    release  => 'wheezy'
}

apt::source{'tinyprod-msp430':
    comment  => "Msp430 toolchain",
    location => "http://tinyprod.net/repos/debian/",
    repos    => 'main',
    release  => 'msp430-46'
}

# Build Tools for Tinyos
class tinyos-tools{
#    $tiny = [ 'nesc', 'tinyos-tools-devel', 'msp430-46', 'mspdebug' ]
    $tiny = [
        'nesc',
        'msp430-46',
        'mspdebug'
    ]
    package { $tiny:
        ensure => 'installed',
        require => [
            Exec['apt-update'],
            Apt::Source['tinyprod'],
            Apt::Source['tinyprod-msp430'],
            Apt::Key['tinyprod']
        ]
    }

}

# Get main tinyos repo
class tinyos-main{
    vcsrepo{'/opt/tinyos':
        ensure   => present,
        provider => git,
        source   => 'https://github.com/tinyos/tinyos-main.git',
        require  => Class['tinyos-tools']
    }

	# Copy profile into home directory
    # This is for makefiles
    file{'/home/ubuntu/.profile':
        ensure => 'file'
        mode   => '0644',
        owner  => 'ubuntu',
        group  => 'ubuntu',
        source => 'file:///profile'
	}


    # We should be ready to compile the tinyos repo
    exec{'tiny-compile':
        path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin',
        cwd     => '/opt/tinyos/tools/',
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
