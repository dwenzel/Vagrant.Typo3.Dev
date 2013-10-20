# What is it?
This is a development environment for the TYPO3 Content Management System.
It is based on the repository https://github.com/ipf/typo3-vagrant and aims to
deliver a more versatile development version.

We will add configuration for choosing the version of TYPO3 to work with. Additionally
there will be an option to choose whether an introduction or government package should be setup 
or just an empty TYPO3 instance (the so called blank package).

We will also include the mailcatcher package which enables sending and receiving
E-Mails whithout setting up a mail delivery agent.

Pleae have a look at the milestones. They indicate the current development
status of the above features.

# Installation

## Clone this repository

 > git clone git@github.com:dwenzel/Vagrant.Typo3.Dev.git

## Get all submodules

 > git submodule update --init

# Running

Simply use the "vagrant up" command to start your virtual machine.
In some cases you have to call "vagrant reload" after that to become provisioned with software.

Your machine will be available with a working TYPO3 version at http://localhost:8333

# Passwords

As usual there is a system vagrant user with password "vagrant". The MySQL Installation is done with the root user and the password "typo3"
