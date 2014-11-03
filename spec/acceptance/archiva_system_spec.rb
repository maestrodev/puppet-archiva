require 'spec_helper_acceptance'

describe 'archiva' do

  let(:manifest) { %Q(
    class { 'java': } ->
    class { 'archiva':
      enable => false,
    }
  ) }

  it 'should install idempotently' do
    apply_manifest(manifest, :catch_failures => true)
    apply_manifest(manifest, :catch_changes => true)
    # wait no more than 60 secs for service to be up
    shell(%Q(timeout 60 sh -c "while ! grep 'Started SelectChannelConnector@0.0.0.0:8080' /var/local/archiva/logs/wrapper*.log; do sleep 1; done"))
    port(8080).should be_listening
  end

end
