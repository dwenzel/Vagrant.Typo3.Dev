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

When you start your virtual machine for the first time it will take quite a
while until all necessary software is installed. You should see some info
messages reporting the executed tasks.

Your machine will be available with a working TYPO3 version at http://localhost:8333

# Passwords

As usual there is a system vagrant user with password "vagrant". The MySQL Installation is done with the root user and the password "typo3"

# Complete Installation

## Select Database
Point your browser to http://localhost:8333/install/
Enter the default password 'joh316' when prompted.
Go to the 'Basic configuration' section and enter the following into the database
fields:
Username: root
Password: typo3
Host: localhost

Select the existing (empty) database 'typo3' and hit the 'Generate random key'
button.
When you are finished hit the 'Update configuration' button.

## Import Database
Proceed to the 'Database Analyser' section. Make shure the database 'typo3' has
been selected and connected successfully and click the 'Compare' link in the
menu area. 
You should now see a message 'Table and field definitions should be updated' and
a lot of database statements. Hit the 'Write to database' button to complete.

## Create Admin User
Click the 'Create "admin" user' button in the menu and fill in a username and
password. Hit the 'Write to databasse' button again.

You should now see a message 'User created'. Follow the 'Backend admin' link and
log into the backend of your new TYPO3 instance.

Have fun with it!
