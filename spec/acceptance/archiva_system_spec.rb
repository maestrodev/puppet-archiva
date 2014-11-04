require 'spec_helper_acceptance'

describe 'archiva' do

  let(:params) { '' }
  let(:port_number) { 8080 }
  let(:manifest) { %Q(
    class { 'java': } ->
    class { 'archiva':
      enable => false,
      #{params}
    }
  ) }

  it 'should install idempotently' do
    apply_manifest(manifest, :catch_failures => true)
    apply_manifest(manifest, :catch_changes => true)
    # wait no more than 60 secs for service to be up
    shell(%Q(timeout 60 sh -c "while ! grep 'Started SelectChannelConnector@0.0.0.0:#{port_number}' /var/local/archiva/logs/wrapper*.log; do sleep 1; done"))
    port(port_number).should be_listening
    shell("curl -fsSL -o /dev/null http://localhost:#{port_number}/")
  end

  context 'when using custom port and context path' do

    let(:port_number) { 8000 }
    let(:params) { %Q(
      port => #{port_number},
      context_path => '/archiva',
    ) }

    it 'should install correctly' do
      apply_manifest(manifest, :catch_failures => true)
      # wait no more than 60 secs for service to be up
      shell(%Q(timeout 60 sh -c "while ! grep 'Started SelectChannelConnector@0.0.0.0:#{port_number}' /var/local/archiva/logs/wrapper*.log; do sleep 1; done"))
      port(port_number).should be_listening
      shell("curl -fsSL -o /dev/null http://localhost:#{port_number}/archiva/")
    end
  end

end
