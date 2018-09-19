# Install and configure a Zabbix server
class zabbix_server (
  String $base_url_32 = lookup('base_url_32', {value_type => String}),
  String $base_url_34 = lookup('base_url_34', {value_type => String}),
  String $base_url_35 = lookup('base_url_35', {value_type => String}),
  String $gpgkey = lookup('gpgkey', {value_type => String}),
  String $db = lookup('db', {value_type => String, default_value => 'zabbix'}),
  String $user = lookup('user', {value_type => String, default_value => 'zabbix'}),
  String $pass = lookup('pass', {value_type => String}),
  String $port = lookup('port', {value_type => String, default_value => '10050'}),
) {

  $xml = lookup('xml', {value_type => String})
  $zabbix = lookup('zabbix', {value_type => Array})

  file { 'zabbixserver-repo':
    path    => '/etc/yum.repos.d/zabbix.repo',
    content => template('zabbix_server/zabbix.repo.erb'),
  }

  exec { 'install iksemel':
    unless  => '/usr/bin/yum list installed | grep iksemel.x86_64',
    command => "/usr/bin/yum install -y ${xml}",
  }

  package { $zabbix:
    ensure        => installed,
    allow_virtual => true,
    require       => [ Exec['install iksemel'], File['zabbixserver-repo'] ]
  }

  mysql::db { $db:
    user           => $user,
    password       => $pass,
    host           => 'localhost',
    grant          => ['ALL'],
    sql            => '/usr/share/doc/zabbix-server-mysql-*/create.sql.gz',
    import_cat_cmd => 'zcat',
    require        => Package[$zabbix],
  }

  file_line { 'zabbix_server_conf':
    ensure  => present,
    path    => '/etc/zabbix/zabbix_server.conf',
    line    => 'DBPassword=zabbixdb',
    match   => '^.*DBPassword=.*$',
    require => Package[$zabbix],
  }

  file { 'web_conf':
    path    => '/etc/zabbix/web/zabbix.conf.php',
    content => template('zabbix_server/web.erb'),
    require => Package[$zabbix],
  }

  file_line { 'change timezone':
    ensure  => present,
    path    => '/etc/httpd/conf.d/zabbix.conf',
    line    => '	php_value date.timezone Europe/Minsk',
    match   => '^.*php_value date\.timezone.*$',
    require => Package[$zabbix],
  }

  service { 'zabbix-server':
    ensure  => 'running',
    enable  => true,
    require => File['/etc/zabbix/web/zabbix.conf.php'],
  }

  service { 'httpd':
    ensure  => 'running',
    enable  => true,
    require => File_line['change timezone'],
  }
}
