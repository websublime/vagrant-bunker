Welcome to Vagrant Bunkerbox
=====================

This is my vagrant bunker arsenal for development of all the crazy things that i do. It is a box based on Ubuntu 12.04 and supports PHP and Python. This box use [vagrant dns plugin][1] for name resolution of websites.

----------
Application list
---------
The basic features of the OS is installed on demand.

 - Python
 - PHP5
 - Nginx
 - PHP5-Fpm
 - Xdebug and all demand extensions
 - Nodejs
 - Composer
 - VirtualEnv
 - MySql Percona
 - Postgres
 - Sites templates for PHP and Django
 - Phpmyadmin
 - Ruby
 - Git
 - Mercurial
 - uWsgi

----------
Usage and Info
---------
Install [vagrant dns plugin][1].
Virtual enviroment is installed in /home/vagrant/.virtualenvs.
This machine uses puppet-labs for modules.

To add new names resolution please add it to your vagrant file and follow the instruction of [vagrant dns plugin][1]. Example:

    config.dns.tld = "dev"
    config.vm.hostname = "bunkerbox"
    config.dns.patterns = [ /^.*bunkerbox.dev$/, /^.*websublime.dev$/]
    
Add on dns.patterns. The current pattern responds to domains an subdomains. Please do not change hostname because provision scripts are node based on this name.

Basic clone this repo and construct your virtual box with:

    vagrant up

After that a basic website in projects directory is ready to use and gives information about phpinfo.

To add new website there are two scripts on manifests dir. 

    php.pp and django.pp

All you have to do is to edit the file of your choice adding your project configurations and then ssh to vagrant to apply it.

    vagrant ssh
    cd /vagrant/manifests
    sudo puppet apply --hiera_config /vagrant/puppet/hiera.yaml --modulepath /etc/puppet/modules/ php.pp

After this you are ready to rock. 

> **Note**: This is my second attempt to make an enviroment to support my prefered languages. If you have nice things to apply, please fork it. Sharing is knowlegement.


  [1]: https://github.com/BerlinVagrant/vagrant-dns