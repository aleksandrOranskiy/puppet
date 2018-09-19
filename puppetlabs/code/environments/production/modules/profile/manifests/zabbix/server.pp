# Install and configure a Zabbix server
class profile::zabbix::server {
  class { 'zabbix_server': }
}
