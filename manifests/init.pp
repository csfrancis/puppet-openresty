# Install nginx
#
class openresty {
  include openresty::config
  include homebrew

  # Install our custom plist for nginx. This is one of the very few
  # pieces of setup that takes over priv. ports (80 in this case).

  file { '/Library/LaunchDaemons/dev.nginx.plist':
    content => template('openresty/dev.nginx.plist.erb'),
    group   => 'wheel',
    notify  => Service['dev.nginx'],
    owner   => 'root'
  }

  # Set up all the files and directories nginx expects. We go
  # nonstandard on this mofo to make things as clearly accessible as
  # possible under $BOXEN_HOME.

  file { [
    $openresty::config::configdir,
    $openresty::config::datadir,
    $openresty::config::logdir,
    $openresty::config::sitesdir
  ]:
    ensure => directory
  }

  file { $openresty::config::configfile:
    content => template('openresty/config/nginx/nginx.conf.erb'),
    notify  => Service['dev.nginx']
  }

  file { "${openresty::config::configdir}/mime.types":
    notify  => Service['dev.nginx'],
    source  => 'puppet:///modules/openresty/config/nginx/mime.types'
  }

  # Set up a very friendly little default one-page site for when
  # people hit http://localhost.

  file { "${openresty::config::configdir}/public":
    ensure  => directory,
    recurse => true,
    source  => 'puppet:///modules/openresty/config/nginx/public'
  }

  homebrew::formula { 'openresty':
    before => Package['boxen/brews/openresty'],
  }

  package { 'boxen/brews/openresty':
    ensure => '1.4.2.1-boxen',
    notify => Service['dev.nginx']
  }

  # Remove Homebrew's nginx config to avoid confusion.

  file { "${boxen::config::home}/homebrew/etc/nginx":
    ensure  => absent,
    force   => true,
    recurse => true,
  }

  service { 'dev.nginx':
    ensure  => running,
    require => Package['boxen/brews/openresty']
  }
}
