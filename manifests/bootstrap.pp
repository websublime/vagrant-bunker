Exec { path => [ '/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/', '/usr/local/bin', '/opt/vagrant_ruby/bin/' ] }

node default {
    class { "aptupdate": stage => "aptupdate" }
    class { "packages": stage => "pre" }
    class { "python": stage => "py" }
    class { "puppet": stage => "pup"}
    class { "pyimage": stage => "pil"}
    class { "application": stage => "app" }
}

stage { "aptupdate": before => Stage["pre"] }
class aptupdate {
    exec { 'apt-get update':
        command => '/usr/bin/apt-get update'
    }
}

stage { "pre": before => Stage["py"] }
class packages {
    package { 
        'build-essential': ensure => latest;
        'libshadow': ensure => latest, provider => 'gem', require => Package["build-essential"];
        "lsb-release": ensure => latest, require => Package["build-essential"];
        "git-core": ensure => latest, require => Package["build-essential"]; 
        "g++": ensure => latest, require => Package["build-essential"];
        "make": ensure => latest, require => Package["build-essential"];
        "wget": ensure => latest, require => Package["build-essential"];
        "ruby": ensure => latest, require => Package["build-essential"];
        "ruby-dev": ensure => latest, require => Package["ruby"];
        "libgemplugin-ruby": ensure => latest, require => Package["ruby"];
        "libaugeas-ruby": ensure => latest, require => Package["ruby"];
    }

    group { "postgres":
	    ensure => "present",
	  }
}

stage { "py": before => Stage["pup"] }
class python {
    package {
        "python-dev": ensure => "2.7.3-0ubuntu2";
        "python": ensure => "2.7.3-0ubuntu2";
        "python-setuptools": ensure => installed;
        "python-virtualenv": ensure => installed;
        "virtualenvwrapper": ensure => installed;
    }
}

stage {"pup": before => Stage["pil"]}
class puppet {
	exec { "apt_puppet_labs":
    cwd => "/home/vagrant",
    command => "sudo wget -q http://apt.puppetlabs.com/puppetlabs-release-precise.deb",
    require => Package['wget']
  }

  exec { "install_puppet_labs":
    cwd => "/home/vagrant",
    command => "sudo dpkg -i puppetlabs-release-precise.deb",
    require => Exec['apt_puppet_labs']
  }

  exec { "update_puppet_labs":
    cwd => "/home/vagrant",
    command => "sudo apt-get update && sudo apt-get install --yes puppet",
    require => Exec['install_puppet_labs']
  }

  package {
  	"puppet": ensure => latest, provider => "gem", require => [Package["ruby"], Exec['update_puppet_labs']];
  	"facter": ensure => latest, provider => "gem", require => Package["puppet"];
  	"librarian-puppet": ensure => latest, provider => "gem", require => Package["facter"];
  }

  exec { "copy_puppet_file":
    command => "cp /vagrant/puppet/Puppetfile /etc/puppet && cp /vagrant/puppet/hiera.yaml /etc/puppet",
    require => Package["librarian-puppet"]
  }

  exec { "fresh_puppet_install":
    cwd => "/etc/puppet",
    command => "sudo librarian-puppet install --clean",
    require => Exec['copy_puppet_file']
  }

  exec { "update_puppet":
    cwd => "/etc/puppet",
    command => "sudo librarian-puppet update",
    require => Exec['fresh_puppet_install']
  }
}

stage {"pil": before => Stage["app"]}
class pyimage {
  package { ['python-imaging', 'libjpeg-dev', 'libfreetype6-dev']:
    ensure => latest,
    require => Package['python'],
    before => Exec['pil png', 'pil jpg', 'pil freetype']
  }
  
  exec { 'pil png':
    command => 'sudo ln -s /usr/lib/`uname -i`-linux-gnu/libz.so /usr/lib/',
    unless => 'test -L /usr/lib/libz.so'
  }

  exec { 'pil jpg':
    command => 'sudo ln -s /usr/lib/`uname -i`-linux-gnu/libjpeg.so /usr/lib/',
    unless => 'test -L /usr/lib/libjpeg.so'
  }
  
  exec { 'pil freetype':
    command => 'sudo ln -s /usr/lib/`uname -i`-linux-gnu/libfreetype.so /usr/lib/',
    unless => 'test -L /usr/lib/libfreetype.so'
  }
}

stage {"app": before => Stage["main"]}
class application {
	package {
      'mercurial': ensure => installed;
      'uwsgi': ensure => installed;
      'uwsgi-plugin-python': ensure => installed, require => Package["uwsgi"];
      'libmysqlclient-dev': ensure => installed;
      "postgresql": ensure => installed;
  }
}