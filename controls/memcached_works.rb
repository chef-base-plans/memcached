title 'Tests to confirm memcached works as expected'

plan_name = input('plan_name', value: 'memcached')
plan_ident = "#{ENV['HAB_ORIGIN']}/#{plan_name}"

control 'core-plans-memcached-works' do
  impact 1.0
  title 'Ensure memcached works as expected'
  desc '
  '
  memcached_path = command("hab pkg path #{plan_ident}")
  describe memcached_path do
    its('exit_status') { should eq 0 }
    its('stdout') { should_not be_empty }
  end
  
  memcached_pkg_ident = ((memcached_path.stdout.strip).match /(?<=pkgs\/)(.*)/)[1]
  describe command("DEBUG=true; hab pkg exec #{ memcached_pkg_ident} memcached --version") do
    its('exit_status') { should eq 0 }
    its('stdout') { should_not be_empty }
    its('stdout') { should match /memcached 1.6.5/ }
    its('stderr') { should be_empty }
  end
end
