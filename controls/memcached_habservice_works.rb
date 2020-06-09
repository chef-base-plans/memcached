title 'Tests to confirm memcached habitat service works as expected'

plan_origin = ENV['HAB_ORIGIN']
plan_name = input('plan_name', value: 'memcached')
service_port=11211

control 'core-plans-memcached-hab-service-works' do
  impact 1.0
  title 'Ensure memcached habitat service works as expected'
  desc '
  Verify memcached habitat service by ensuring that (1) the default.memcached habitat service is "up"; 
  (2) the memcache process is listening on port 11211 the expected port is LISTENing.  Note that regex to detect
  the port has been adjusted to work both for a habitat studio environment, in which the program name is
  displayed as nnnn/memcached, and also for docker, in which the same is as "-"
  and also for docker
  '
  
  plan_installation_directory = command("hab pkg path #{plan_origin}/#{plan_name}")
  describe plan_installation_directory do
    its('exit_status') { should eq 0 }
    its('stdout') { should_not be_empty }
  end

  plan_pkg_ident = ((plan_installation_directory.stdout.strip).match /(?<=pkgs\/)(.*)/)[1]
  describe command("hab svc status") do
    its('exit_status') { should eq 0 }
    its('stdout') { should_not be_empty }
    its('stdout') { should match /(?<package>#{plan_pkg_ident})\s+(?<type>standalone)\s+(?<desired>up)\s+(?<state>up)/ }
    its('stderr') { should be_empty }
  end

  describe command(" hab pkg exec core/busybox-static netstat -peanut") do
    its('exit_status') { should eq 0 }
    its('stdout') { should_not be_empty }
    its('stdout') { should match /:(?<port>#{11211}).*LISTEN\s+(?<program>-|\d+\/#{plan_name})/ }
    its('stderr') { should be_empty }
  end
end
