class zabbix_agent {

  $base_url_3_2 = 'http://repo.zabbix.com/zabbix/3.2/rhel/7/x86_64/zabbix-agent-3.2.11-1.el7.x86_64.rpm'
  $base_url_3_4 = 'http://repo.zabbix.com/zabbix/3.4/rhel/7/x86_64/zabbix-agent-3.4.14-1.el7.x86_64.rpm'
  $base_url_3_5 = 'http://repo.zabbix.com/zabbix/3.5/rhel/7/x86_64/zabbix-agent-4.0.0-1.1beta2.el7.x86_64.rpm'
  $gpgkey = 'http://repo.zabbix.com/zabbix-official-repo.key'
  $zabbix_agent_release = 'zabbix3.2'
  $zabbix_agent = [$zabbix_agent_release]

  file { 'zabbixagent-repo':
    path    => "/etc/yum.repos.d/zabbix-agent.repo",
    content => template('zabbix-agent/zabbix-agent.repo.erb'),
  }
}
