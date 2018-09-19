# Install and configure a mysql
class profile::mysql::base {
  include '::mysql::server'
}
