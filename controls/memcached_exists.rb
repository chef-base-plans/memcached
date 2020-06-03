title 'Tests to confirm memcached exists'

plan_name = input('plan_name', value: 'memcached')
plan_ident = "#{ENV['HAB_ORIGIN']}/#{plan_name}"
memcached_relative_path = input('command_path', value: '/bin/memcached')
memcached_installation_directory = command("hab pkg path #{plan_ident}")
memcached_full_path = memcached_installation_directory.stdout.strip + "#{ memcached_relative_path}"
 
control 'core-plans-memcached-exists' do
  impact 1.0
  title 'Ensure memcached exists'
  desc '
  '
   describe file(memcached_full_path) do
    it { should exist }
  end
end
