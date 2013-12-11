Exec { path => [ '/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/' ] }

class sites
{
  include sites::params
  include sites::venv
  include sites::vhosts
}

class sites::params
{
	# Puppet variables
	$project_name		= "websublime"
	$puppet_dir     = "/vagrant/puppet"
	$templates_dir  = "$puppet_dir/templates"

	# Webserver variables
	$sites_dir      = "/var/www"
	$nginx_template = "$templates_dir/nginx/vhost.django.conf.erb"

	#uwsgi variables
	$uwsgi_socket = "/var/run/websublime.socket"
	$uwsgi_file 	= "/var/www/websublime.dev/websublime/wsgi.py"
	$uwsgi_module = "websublime.wsgi:application"
	$uwsgi_home 	= "/home/vagrant/.virtualenvs/websublime"
	$uwsgi_chdir	= "/var/www/websublime.dev"
}

class sites::venv {
	exec { "create_virtual":
		command => "sudo /usr/bin/virtualenv /home/vagrant/.virtualenvs/${sites::params::project_name}",
		path   => "/usr/local/bin:/usr/bin:/bin",
		
	}
}

class sites::vhosts
{
  $sites_dir = $sites::params::sites_dir
  $nginx_dir = "${sites::params::templates_dir}/nginx"

  class { 'uwsgi': }

  uwsgi::app { 'websublime':
	    socket    => "${sites::params::uwsgi_socket}",
	    plugins   => "python",
	    wsgi_file => "${sites::params::uwsgi_file}",
	    module 		=> "${sites::params::uwsgi_module}",
	    home 			=> "${sites::params::uwsgi_home}",
	    chdir 		=> "${sites::params::uwsgi_chdir}",
	    env 			=> "DJANGO_SETTINGS_MODULE.websublime",
	    uid 			=> "www-data",
	    gid 			=> "www-data"
	    #chmod-socket = 666
			#chown-socket = www-data:www-data
	}

  #websublime.dev
  nginx::vhost { "websublime":
    root     => "${sites_dir}/websublime.dev",
    index    => "index.php",
    template => $sites::params::nginx_template,
    server_name => "www.websublime.dev"
  }
}

node 'bunkerbox' {
	include sites
}