require 'spec_helper'

describe 'nodenv', :type => 'class' do
  let(:facts) { { :osfamily => 'Debian' } }
  let(:params) do
    {
      :install_dir => '/usr/local/nodenv',
      :latest      => true,
    }
  end

  it { should contain_exec('git-clone-nodenv').with(
    {
      'command' => '/usr/bin/git clone https://github.com/nodenv/nodenv.git /usr/local/nodenv',
      'creates' => '/usr/local/nodenv',
    }
  )}

  [ 'plugins', 'shims', 'versions' ].each do |dir|
    describe "creates #{dir}" do
      it { should contain_file("/usr/local/nodenv/#{dir}").with({
          'ensure'  => 'directory',
          'owner'   => 'root',
          'group'   => 'adm',
          'mode'    => '0775',
        })
      }
    end
  end

  it { should contain_file('/etc/profile.d/nodenv.sh').with(
    {
      'ensure'  => 'file',
      'mode'    => '0775',
    }
  )}

  it { should contain_exec("update-nodenv") }
end
