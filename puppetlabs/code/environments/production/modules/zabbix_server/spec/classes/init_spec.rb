require 'spec_helper'
describe 'zabbix_server' do
  context 'with default values for all parameters' do
    it { should contain_class('zabbix_server') }
  end
end
