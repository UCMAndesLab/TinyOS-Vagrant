# -*- mode: sh -*-
# vi: set ft=sh :


# ~/.profile: executed by the command interpreter for login shells.
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

TINYOS_ROOT_DIR=/opt/tinyos
TOSDIR=$TINYOS_ROOT_DIR/tos

MAKERULES=$TINYOS_ROOT_DIR/support/make/Makerules
CLASSPATH=.:$TINYOS_ROOT_DIR/support/sdk/java/tinyos.jar

PYTHONPATH=$TINYOS_ROOT_DIR/support/sdk/python:$PYTHONPATH

export MAKERULES TINYOS_ROOT_DIR TOSDIR CLASSPATH PYTHONPATH
export MOTECOM

