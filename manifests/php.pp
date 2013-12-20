Exec { path => [ '/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/' ] }

class sites
{
  include sites::params
  include sites::vhosts
}

class sites::params
{
	# Puppet variables
	$puppet_dir     = "/vagrant/puppet"
	$templates_dir  = "$puppet_dir/templates"

	# Webserver variables
	$sites_dir      = "/var/www"
	$nginx_template = "$templates_dir/nginx/vhost.php.conf.erb"
}

class sites::vhosts
{
  $sites_dir = $sites::params::sites_dir
  $nginx_dir = "${sites::params::templates_dir}/nginx"

  #ccea.dev
  nginx::vhost { "ccea":
    root     => "${sites_dir}/ccea.dev",
    index    => "index.php",
    template => $sites::params::nginx_template,
    server_name => "www.ccea.dev"
  }
}

node 'bunkerbox' {
  include sites
}
