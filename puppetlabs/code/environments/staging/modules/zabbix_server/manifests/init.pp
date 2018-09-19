class zabbix_server {

  include stdlib
  $mariadb = ['mariadb', 'mariadb-server']
  $base_url_3_2 = 'http://repo.zabbix.com/zabbix/3.2/rhel/7/x86_64/zabbix-release-3.2-1.el7.noarch.rpm'
  $base_url_3_4 = 'http://repo.zabbix.com/zabbix/3.4/rhel/7/x86_64/zabbix-release-3.4-2.el7.noarch.rpm'
  $base_url_3_5 = 'http://repo.zabbix.com/zabbix/3.5/rhel/7/x86_64/zabbix-release-3.5-1.el7.noarch.rpm'
  $gpgkey = 'http://repo.zabbix.com/zabbix-official-repo.key'
  $zabbix_release = 'zabbix3.2'
  $zabbix = [$zabbix_release, 'zabbix-server-mysql', 'zabbix-web-mysql']
  $db = 'zabbix'
  $user = 'zabbix'
  $pass = 'zabbixdb'
  $port = '10051'

  file { 'zabbixserver-repo':
    path    => "/etc/yum.repos.d/zabbix.repo",
    content => template('zabbix-server/zabbix.repo.erb'),
  }

  package { $mariadb:
    ensure => installed,
  }

  exec { 'mariadb installation':
    command => '/usr/bin/mysql_install_db --user=mysql'
    onlyif => "test ! -f /etc/systemd/system/mariadb.service"
  }
  
  service { 'mariadb':
    ensure => 'running',
    enable => 'true',
  }

  exec { 'creating an initial db':
    command => mysql -uroot @(SQL)
      create database zabbix character set utf8 collate utf8_bin;
      grant all privileges on zabbix.* to zabbix@localhost identified by 'zabbixdb';
      | SQL,
    unless  => "mysql -u root -e 'zabbix'",
  }

  package { $zabbix:
    ensure  => installed,
    require => [ Package[$mariadb], File['zabbixserver-repo'] ],
  }

  exec { 'zabbixdb':
    command => 'zcat /usr/share/doc/zabbix-server-mysql-*/create.sql.gz | mysql -uzabbix -pzabbixdb zabbix',
    unless  => "mysql -u root -e 'SHOW TABLES FROM \'zabbix\' LIKE \'maintenance\';'",
  }

  file_line { 'zabbix_server_conf':
    ensure  => present,
    path    => '/etc/zabbix/zabbix_server.conf',
    line    => "DBPassword=zabbixdb",
    match   => '^.*DBPassword=.*$',
    require => Package[$zabbix], 
  }
  
  file { '/etc/zabbix/web':
    ensure  => file,
    content => template(zabbix_server/web.conf.erb) 
  }

  service { 'zabbix-server':
    ensure => 'running',
    enable => 'true',
    require => File['/etc/zabbix/web']
  }
}
