# Install and configure a Zabbix agent
class zabbix_agent ( 
  String $zabbix_server = lookup('zabbix_server', {value_type => String}),
  String $base_url_32 = lookup('base_url_32', {value_type => String}),
  String $base_url_34 = lookup('base_url_34', {value_type => String}),
  String $base_url_35 = lookup('base_url_35', {value_type => String}),
  String $gpgkey = lookup('gpgkey', {value_type => String}),
) {

  $zabbix_agent_yum = lookup('zabbix_agent_yum', {value_type => Array})

  file { 'zabbixagent-repo':
    path    => '/etc/yum.repos.d/zabbix-agent.repo',
    content => template('zabbix_agent/zabbix-agent.repo.erb'),
  }

  package { $zabbix_agent_yum:
    ensure        => installed,
    allow_virtual => true,
    require       => File['zabbixagent-repo'],
  }

  file_line { 'zabbix_agent_conf':
    ensure  => present,
    path    => '/etc/zabbix/zabbix_agentd.conf',
    line    => "Server=${zabbix_server}",
    match   => '^Server\s*=.*$',
    require => Package[$zabbix_agent_yum],
  }

  service { 'zabbix-agent':
    ensure    => running,
    enable    => true,
    subscribe => File_line['zabbix_agent_conf'],
  }
}

