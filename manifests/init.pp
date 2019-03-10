# == Class: nodenv
#
# This module manages nodenv on Ubuntu. The default installation directory
# allows nodenv to available for all users and applications.
#
# === Variables
#
# [$repo_path]
#   This is the git repo used to install nodenv.
#   Default: 'https://github.com/nodenv/nodenv.git'
#   This variable is required.
#
# [$install_dir]
#   This is where nodenv will be installed to.
#   Default: '/usr/local/nodenv'
#   This variable is required.
#
# [$owner]
#   This defines who owns the nodenv install directory.
#   Default: 'root'
#   This variable is required.
#
# [$group]
#   This defines the group membership for nodenv.
#   Default: 'adm'
#   This variable is required.
#
# [$latest]
#   This defines whether the nodenv $install_dir is kept up-to-date.
#   Defaults: false
#   This variable is optional.
#
# [$version]
#   This checks out the specified version of nodenv to $install_dir.
#   Defaults: undef
#   This variable is optional and has no affect if latest is true.
#
# [$env]
#   This is used to set environment variables when compiling ruby.
#   Default: []
#   This variable is optional.
#
# [$manage_deps]
#   Toggles the option to let module manage dependencies or not.
#   Default: true
#   This variable is optional.
#
# [$manage_profile]
#   Toggles the option to let the module install nodenv.sh into /etc/profile.d.
#   Default: true
#   This variable is optional.
#
# === Requires
#
# This module requires the following modules:
#   'puppetlabs/stdlib' >= 4.1.0
#
# === Examples
#
# class { nodenv: }  #Uses the default parameters
#
# class { nodenv:  #Uses a user-defined installation path
#   install_dir => '/opt/nodenv',
# }
#
# More information on using Hiera to override parameters is available here:
#   http://docs.puppetlabs.com/hiera/1/puppet.html#automatic-parameter-lookup
#
# === Authors
#
# Justin Downing <justin@downing.us>
#
# === Copyright
#
# Copyright 2013 Justin Downing
#
class nodenv (
  $repo_path      = 'https://github.com/nodenv/nodenv.git',
  $install_dir    = '/usr/local/nodenv',
  $owner          = 'root',
  $latest         = false,
  $version        = undef,
  $group          = 'adm',
  $manage_profile = true,
) {

  exec { 'git-clone-nodenv':
    command     => "/usr/bin/git clone ${nodenv::repo_path} ${install_dir}",
    creates     => $install_dir,
    cwd         => '/',
    user        => $owner,
  }

  file { [
    $install_dir,
    "${install_dir}/plugins",
    "${install_dir}/shims",
    "${install_dir}/versions"
  ]:
    ensure => directory,
    owner  => $owner,
    group  => $group,
    mode   => '0775',
  }

  if $manage_profile {
    file { '/etc/profile.d/nodenv.sh':
      ensure  => file,
      content => template('nodenv/nodenv.sh'),
      mode    => '0775'
    }
  }

  # run `git pull` on each run if we want to keep nodenv updated
  if $latest == true {
    exec { 'checkout-nodenv':
      command     => '/usr/bin/git checkout master',
      cwd         => $install_dir,
      user        => $owner,
      onlyif      => '/usr/bin/test $(git rev-parse --abbrev-ref HEAD) != "master"',
      require     => File[$install_dir],
    }
    -> exec { 'update-nodenv':
      command     => '/usr/bin/git pull',
      cwd         => $install_dir,
      user        => $owner,
      unless      => '/usr/bin/git fetch --quiet; /usr/bin/test $(git rev-parse HEAD) == $(git rev-parse @{u})',
      require     => File[$install_dir],
    }
  } elsif $version {
    exec { 'fetch-nodenv':
      command     => '/usr/bin/git fetch',
      cwd         => $install_dir,
      user        => $owner,
      require     => File[$install_dir],
    }
    ~> exec { 'update-nodenv':
      command     => "/usr/bin/git checkout ${version}",
      cwd         => $install_dir,
      user        => $owner,
      refreshonly => true,
    }
  }

  Exec['git-clone-nodenv'] -> File[$install_dir]

}
