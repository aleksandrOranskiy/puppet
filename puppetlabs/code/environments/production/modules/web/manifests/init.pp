class web {

  $docRoot       = '/var/www/html'
  $template      = 'web/vhost.conf.erb'
  $htmlTemplate  = 'web/index.html.erb'

  if $::osfamily == 'RedHat' {
    $packageName = 'httpd'
    $vhostConf   = '/etc/httpd/conf.d/vhost.conf'
  }
  elsif $::osfamily =~ /^(Debian|Ubuntu)$/ {
    $packageName = 'apache2'
    $vhostConf   = "/etc/apache2/sites-available/${hostname}.conf"
  }
  package { $packageName:
    ensure => 'installed',
  }
  service { $packageName:
    ensure  => 'running',
    enable  => 'true',
    require => Package[$packageName],
  }
  file { $docRoot:
    ensure  => directory,
    recurse => true,
  }
  file { $vhostConf:
    ensure  => file,
    content => template($template),
  }
  file { "${docRoot}/index.html":
    ensure  => file,
    content => template($htmlTemplate),
    notify  => Service[$packageName],
  }
}
