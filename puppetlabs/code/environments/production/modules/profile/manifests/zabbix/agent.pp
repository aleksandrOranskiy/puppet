# Install and configure a Zabbix agent
class profile::zabbix::agent {
  class { 'zabbix_agent': }
}
