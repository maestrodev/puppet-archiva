require "#{File.join(File.dirname(__FILE__),'..','spec_helper')}"

DEFAULT_PARAMS = {
  :version => "1.3.5"
}

describe 'archiva' do
  let (:params) { DEFAULT_PARAMS }

  context "when downloading archiva" do
    it do should contain_wget__fetch('archiva_download').with(
        'source'      => 'http://archive.apache.org/dist/archiva/binaries/apache-archiva-1.3.5-bin.tar.gz',
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
        'source'      =>
'http://repo1.maven.org/maven2/org/apache/archiva/archiva-jetty/1.3.5/archiva-jetty-1.3.5-bin.tar.gz',
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
        'source'      => 'http://repo1.maven.org/maven2/org/apache/archiva/archiva-jetty/1.3.5/archiva-jetty-1.3.5-bin.tar.gz',
        'user'        => 'u',
        'password'    => 'p')
    end
  end
end
