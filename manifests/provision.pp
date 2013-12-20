Exec { path => [ '/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/' ] }

#
class provision::params
{
  # Puppet variables
  $puppet_dir     = "/vagrant/puppet"
  $templates_dir  = "$puppet_dir/templates"

  # Webserver variables
  $sites_dir      = "/var/www"
  $fpm_listen     = "/var/run/php5-fpm.sock"
  $nginx_template = "nginx/vhost.php.conf.erb"

  # Database variables
  $dbuser         = "root"
  $dbpassword     = "vagrant"
  $dbconfig       = "/etc/.puppet.cnf"

  #composer
  $target_dir      = '/usr/local/bin'
  $composer_file   = 'composer'
  $download_method = 'curl'
  $logoutput       = false
  $tmp_path        = '/tmp'
  $php_package     = 'php5-cli'
  $curl_package    = 'curl'
  $suhosin_enabled = true

  $remote_enable    = '1'
  $remote_handler   = 'dbgp'
  $remote_port      = '9000'
  $remote_autostart = '1'
  $remote_connect_back = '1'
  $remote_host      = '33.33.33.50'
}

#
class php::modules
{
  $php_ini_dir     = "${provision::params::templates_dir}/php/"
  $notify_services = [
    Service["nginx"],
    Class["php::fpm::service"]
  ]

  php::module { [ "cgi", "curl", "suhosin" ]:
    notify => $notify_services
  }

  php::module { [ "mysql", "mcrypt", "memcache", "pgsql", "xdebug" ]:
    notify  => $notify_services,
    content => $php_ini_dir
  }

  php::module { "apc":
    package_prefix => "php-",
    notify         => $notify_services,
    content        => $php_ini_dir
  }

  php::module { [ "gd", "intl", "tidy", "imap", "imagick" ]:
    notify => $notify_services
  }

}

#
class php::pools
{
  php::fpm::pool { "www":
    listen => $provision::params::fpm_listen
  }
}

#
class web::vhosts
{
  $sites_dir = $provision::params::sites_dir
  $nginx_dir = "${provision::params::templates_dir}/nginx"

  nginx::vhost { "www.bunkerbox.dev":
    root     => "${sites_dir}/default",
    index    => "index.php",
    template => "${nginx_dir}/default.conf.erb"
  }
}

class mypercona::config
{
  percona::adminpass{ $provision::params::dbuser:
    password  => $provision::params::dbpassword,
  }

  percona::mgmt_cnf { $provision::params::dbconfig:
    password => $provision::params::dbpassword,
    user     => $provision::params::dbuser,
  }

  class { "percona::params":
    mgmt_cnf => $provision::params::dbconfig,
  }
}

# Class: provision::percona::databases
#
#
class mypercona::databases
{
  percona::database { "database":
    ensure => present
  }
}

# Class: provision::percona::rights
#
#
class mypercona::rights
{
  percona::rights { "root@localhost":
    database => "*",
    password => "vagrant",
    priv     => "all"
  }
}

node 'bunkerbox' {

  include provision::params
  include apt, php, php::fpm, composer

  class { 'nginx':
    ensure => present,
    default_vhost => "default"
  }

  include web::vhosts
  include php::modules
  include php::pools

  include mypercona::config

  class { "percona":
    server          => true,
    manage_repo     => true,
    percona_version => "5.5",
    require         => Class["apt"]
  }

  include mypercona::databases
  include mypercona::rights

  package { "phpmyadmin":
    ensure  => installed,
    require => Package["php5-cgi"]
  }

  class { "postgresql::server":
    ip_mask_allow_all_users    => '0.0.0.0/0',
    ip_mask_deny_postgres_user => '0.0.0.0/32',
    postgres_password          => 'blank',
    manage_firewall            => false,
    listen_addresses           => '*'
  }

  class { 'postgresql::server::contrib':
    package_ensure  => present
  }

  class { 'postgresql::lib::python':
    package_ensure  => present
  }

  include nodejs
}
