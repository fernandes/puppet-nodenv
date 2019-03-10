require 'spec_helper'

describe 'nodenv::plugin' do
  describe 'install node-build' do
    let(:title) { 'nodenv/node-build' }
    let(:params) do
      {
        :install_dir => '/usr/local/nodenv',
        :latest      => true,
      }
    end

    it { should contain_class('nodenv') }
    it { should contain_exec("install-nodenv/node-build") }
    it { should contain_exec("nodenv-permissions-nodenv/node-build") }
    it { should contain_exec("update-nodenv/node-build") }
  end
end
