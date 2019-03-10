# puppet-nodenv

[![Build Status](https://travis-ci.org/fernandes/puppet-nodenv.png)](https://travis-ci.org/fernandes/puppet-nodenv) [![Puppet Forge](http://img.shields.io/puppetforge/v/jdowning/nodenv.svg?style=flat)](https://forge.puppetlabs.com/jdowning/nodenv)

## Description

This Puppet module will install and manage [nodenv](https://https://github.com/nodenv/nodenv). By default, it installs
nodenv for systemwide use, rather than for a user or project. Additionally,
you can install different versions of Node, nodenv plugins, and NPM packages.

## Installation

`puppet module install --modulepath /path/to/puppet/modules fernandes-nodenv`

## Usage
To use this module, you must declare it in your manifest like so:

    class { 'nodenv': }

If you wish to install nodenv somewhere other than the default
(`/usr/local/nodenv`), you can do so by declaring the `install_dir`:

    class { 'nodenv': install_dir => '/opt/nodenv' }

You can also ensure nodenv is kept up-to-date:

    class { 'nodenv':
      install_dir => '/opt/nodenv'
      latest      => true
    }

The class will merely setup nodenv on your host. If you wish to install
nodes, plugins, or packages, you will have to add those declarations to your manifests
as well.

### Installing Node using node-build
Node requires additional packages to operate properly. Fortunately, this module
will ensure these dependencies are met before installing Node. To install Node
you will need the [ruby-build](https://github.com/nodenv/ruby-build) plugin. Once
installed, you can install most any Node. Additionally, you can set the Node to
be the global interpreter.

    nodenv::plugin { 'nodenv/node-build': }
    nodenv::build { '8.1.12': global => true }

## Plugins
Plugins can be installed from GitHub using the following definiton:

    nodenv::plugin { 'github_user/github_repo': }

You can ensure a plugin is kept up-to-date. This is helpful for a plugin like
`node-build` so that definitions are always available:

    nodenv::plugin { 'nodenv/node-build': latest => true }

## Packages

Packages can be installed too! You *must* specify the `node_version` you want to
install for.

    nodenv::gem { 'yarn': node_version => '8.1.12' }

## Full Example
site.pp

    class { 'nodenv': }
    nodenv::plugin { [ 'nodenv/nodenv-vars', 'nodenv/ruby-build' ]: }
    nodenv::build { '8.1.12': global => true }
    nodenv::gem { 'yarn': node_version => '8.1.12' }

## Testing
You can run specs in  this module with rspec:

    bundle install
    bundle exec rake spec

Or with Docker:

    docker build -t puppet-nodenv .

## Vagrant

You can also test this module in a Vagrant box. There are two box definitons included in the
Vagrant file for CentOS and Ubuntu testing. You will need to use `librarian-puppet` to setup
dependencies:

    bundle install
    bundle exec librarian-puppet install

To test both boxes:

    vagrant up

To test one distribution:

    vagrant up [centos|ubuntu]

## Credits

This is the puppet-nodenv created by [jdowning](https://github.com/jdowning) ported to nodenv. All credits to him