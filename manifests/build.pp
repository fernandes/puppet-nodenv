# == Define: nodenv::build
#
# Calling this define will install Ruby in your default nodenv
# installs directory. Additionally, it can define the installed
# ruby as the global interpretter. It will install the bundler gem.
#
# === Variables
#
# [$install_dir]
#   This is set when you declare the nodenv class. There is no
#   need to overrite it when calling the nodenv::build define.
#   Default: $nodenv::install_dir
#   This variable is required.
#
# [$owner]
#   This is set when you declare the nodenv class. There is no
#   need to overrite it when calling the nodenv::build define.
#   Default: $nodenv::owner
#   This variable is required.
#
# [$group]
#   This is set when you declare the nodenv class. There is no
#   need to overrite it when calling the nodenv::build define.
#   Default: $nodenv::group
#   This variable is required.
#
# [$global]
#   This is used to set the ruby to be the global interpreter.
#   Default: false
#   This variable is optional.
#
# [$keep]
#   This is used to keep the source code of a compiled ruby.
#   Default: false
#   This variable is optional.
#
# [$patch]
#   A single file that can be written to the local disk to be used
#   to patch the ruby installation.
#   Default: undef
#   This variable is optional.
#
# [$bundler_version]
#   This is used to set a specific version of bundler.
#   Default: '>=0'
#   This variable is optional.
#
# === Examples
#
# nodenv::build { '2.0.0-p247': global => true }
#
# === Authors
#
# Justin Downing <justin@downing.us>
#
define nodenv::build (
  $install_dir      = $nodenv::install_dir,
  $owner            = $nodenv::owner,
  $group            = $nodenv::group,
  $global           = false,
  $keep             = false,
  $bundler_version  = '>=0',
) {
  include nodenv

  validate_bool($global)
  validate_bool($keep)

  $environment_for_build = ["NODENV_ROOT=${install_dir}"]

  Exec {
    cwd         => $install_dir,
    timeout     => 1800,
    environment => $environment_for_build,
    path        => [
      "${install_dir}/bin/",
      "${install_dir}/shims/",
      '/bin/',
      '/sbin/',
      '/usr/bin/',
      '/usr/sbin/'
    ],
  }

  $install_options = join([ $keep ? { true => ' --keep', default => '' }], '')

  exec { "own-plugins-${title}":
    command => "chown -R ${owner}:${group} ${install_dir}/plugins",
    user    => 'root',
    unless  => "test -d ${install_dir}/versions/${title}",
    require => Class['nodenv'],
  }
  -> exec { "git-pull-nodebuild-${title}":
    command => 'git reset --hard HEAD && git pull',
    cwd     => "${install_dir}/plugins/node-build",
    user    => 'root',
    unless  => "test -d ${install_dir}/versions/${title}",
    require => Nodenv::Plugin['nodenv/node-build'],
  }
  -> exec { "nodenv-install-${title}":
    # patch file must be read from stdin only if supplied
    command => sprintf("nodenv install ${title}${install_options}"),
    creates => "${install_dir}/versions/${title}",
  }
  ~> exec { "nodenv-ownit-${title}":
    command     => "chown -R ${owner}:${group} \
                    ${install_dir}/versions/${title} && \
                    chmod -R g+w ${install_dir}/versions/${title}",
    user        => 'root',
    refreshonly => true,
  }

  if $global == true {
    exec { "nodenv-global-${title}":
      command     => "nodenv global ${title}",
      environment => ["NODENV_ROOT=${install_dir}"],
      require     => Exec["nodenv-install-${title}"],
      subscribe   => Exec["nodenv-ownit-${title}"],
      refreshonly => true,
    }
  }

}
