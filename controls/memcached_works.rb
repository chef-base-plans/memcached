title 'Tests to confirm memcached works as expected'

plan_origin = ENV['HAB_ORIGIN']
plan_name = input('plan_name', value: 'memcached')
plan_installation_directory = command("hab pkg path #{plan_origin}/#{plan_name}")
plan_pkg_ident = ((plan_installation_directory.stdout.strip).match /(?<=pkgs\/)(.*)/)[1]
plan_pkg_version = (plan_pkg_ident.match /^#{plan_origin}\/#{plan_name}\/(?<version>.*)\//)[:version]

control 'core-plans-memcached-works' do
  impact 1.0
  title 'Ensure memcached works as expected'
  desc '
  Verify memcached by ensuring that (1) its installation directory exists; (2)
  it returns the expected version; (3) it can --enable-ssl; and 
  '
  
  describe plan_installation_directory do
    its('exit_status') { should eq 0 }
    its('stdout') { should_not be_empty }
  end
  
  describe command("DEBUG=true; hab pkg exec #{plan_pkg_ident} memcached --version") do
    its('exit_status') { should eq 0 }
    its('stdout') { should_not be_empty }
    its('stdout') { should match /memcached #{plan_pkg_version}/ }
    its('stderr') { should be_empty }
  end

  # should be able to --enable-ssl
  describe command("DEBUG=true; hab pkg exec #{plan_pkg_ident} memcached --help | grep 'enable-sasl'") do
    its('exit_status') { should eq 0 }
    its('stdout') { should_not be_empty }
    its('stdout') { should match /--enable-sasl\s+turn on Sasl authentication/ }
    its('stderr') { should be_empty }
  end
end