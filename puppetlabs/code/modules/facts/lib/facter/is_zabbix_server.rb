Facter.add(:is_zabbix_server) do
  setcode do
   $is_server = Facter::Core::Execution.execute('/usr/bin/hostname')
   if $is_server == 'zabbixServer'
     'true'
   else
     'false'
   end
  end
end
