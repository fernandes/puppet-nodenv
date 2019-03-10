require 'spec_helper'

describe 'nodenv::package' do
  describe 'install yarn' do
    let(:title) { 'yarn' }
    let(:params) do
      {
        :install_dir  => '/usr/local/nodenv',
        :version      => '1.12.3',
        :node_version => '8.1.12',
      }
    end

    it { should contain_class('nodenv') }
    it { should contain_exec("node-8.1.12-package-install-yarn-1_12_3") }
    it { should contain_exec("node-8.1.12-nodenv-rehash-yarn-1_12_3") }
    it { should contain_exec("node-8.1.12-nodenv-permissions-yarn-1_12_3") }
  end
end
