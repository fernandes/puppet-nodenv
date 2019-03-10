require 'spec_helper'

describe 'nodenv::build' do
  describe 'install 8.1.12' do
    let(:title) { '8.1.12' }
    let(:facts) { { :vardir => '/var/lib/puppet' } }
    let(:params) do
      {
        :install_dir      => '/usr/local/nodenv',
        :owner            => 'root',
        :group            => 'adm',
        :global           => false,
      }
    end

    it { should contain_class('nodenv') }

    it { should contain_exec("own-plugins-8.1.12") }
    it { should contain_exec("git-pull-nodebuild-8.1.12") }
    it { should contain_exec("nodenv-install-8.1.12") }
    it { should contain_exec("nodenv-ownit-8.1.12") }

    context 'with global => true' do
      let(:params) do
        {
          :install_dir => '/usr/local/nodenv',
          :owner       => 'root',
          :group       => 'adm',
          :global      => true,
        }
      end

      it { should contain_exec("nodenv-global-8.1.12") }
    end
  end
end
