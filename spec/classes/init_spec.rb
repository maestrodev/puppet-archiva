require "#{File.join(File.dirname(__FILE__),'..','spec_helper')}"

ARCHIVA_VERSION = "1.3.5"
DEFAULT_PARAMS = {
  :version => ARCHIVA_VERSION
}

describe 'archiva' do
  let (:params) { DEFAULT_PARAMS }

  context "when downloading archiva" do
    it do should contain_wget__fetch('archiva_download').with(
        'source'      => "http://archive.apache.org/dist/archiva/binaries/apache-archiva-#{ARCHIVA_VERSION}-bin.tar.gz",
        'user'        => nil,
        'password'    => nil
    ) 
    end
  end

  context "when downloading archiva from another repo" do
    let(:params) { { :repo => {
        'url'      => 'http://repo1.maven.org/maven2',
      }
    }.merge DEFAULT_PARAMS }

    it 'should fetch archiva from repo' do
      should contain_wget__fetch('archiva_download').with(
        'source'      => "http://repo1.maven.org/maven2/org/apache/archiva/archiva-jetty/#{ARCHIVA_VERSION}/archiva-jetty-#{ARCHIVA_VERSION}-bin.tar.gz",
        'user'        => nil,
        'password'    => nil)
    end
  end

  context "when downloading archiva from another repo with credentials" do
    let(:params) { { :repo => {
        'url'      => 'http://repo1.maven.org/maven2',
        'username' => 'u',
        'password' => 'p'
      }
    }.merge DEFAULT_PARAMS }

    it 'should fetch archiva with username and password' do
      should contain_wget__authfetch('archiva_download').with(
        'source'      => "http://repo1.maven.org/maven2/org/apache/archiva/archiva-jetty/#{ARCHIVA_VERSION}/archiva-jetty-#{ARCHIVA_VERSION}-bin.tar.gz",
        'user'        => 'u',
        'password'    => 'p')
    end
  end

  

  context 'when application URL is not set' do    
    it 'should set the HOME variable correctly in the startup script' do
      should contain_file('/var/local/archiva/conf/security.properties').with_content =~ %r[application\\.url = http://localhost:8080/archiva/]
    end
  end
  

  context 'when application URL is set' do
    let(:params) { { :application_url => 'http://someurl/' }.merge DEFAULT_PARAMS }
    
    it 'should set the HOME variable correctly in the startup script' do
      should contain_file('/var/local/archiva/conf/security.properties').with_content =~ %r[application\\.url = http://someurl/]
    end
  end

  context "when cookie path is set" do
    let(:params) { { :cookie_path => "/" }.merge DEFAULT_PARAMS }

    security_config_file="/var/local/archiva/conf/security.properties"
    it "should set the cookie paths" do
      should contain_file(security_config_file)
      content = catalogue.resource('file', security_config_file).send(:parameters)[:content]
      content.should =~ %r[security\.signon\.path=/]
      content.should =~ %r[security\.rememberme\.path=/]
    end
  end

  context "when cookie path is not set" do
    security_config_file="/var/local/archiva/conf/security.properties"
    it "should not set the cookie paths" do
      should contain_file(security_config_file)
      content = catalogue.resource('file', security_config_file).send(:parameters)[:content]
      content.should_not =~ %r[security\.signon\.path]
      content.should_not =~ %r[security\.rememberme\.path]
    end
  end

  context "when upload size is set" do
    let(:params) { { :max_upload_size => 10485760 }.merge DEFAULT_PARAMS }

    it { should contain_augeas('set-upload-size') }
  end

  context "when upload size is not set" do
    it { should_not contain_augeas('set-upload-size') }
  end
end
