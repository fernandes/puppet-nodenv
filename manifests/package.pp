# == Define: nodenv::package
#
# Calling this define will install a ruby package for a specific ruby version
#
# === Variable
#
# [$install_dir]
#   This is set when you declare the nodenv class. There is no
#   need to overrite it when calling the nodenv::package define.
#   Default: $nodenv::install_dir
#   This variable is required.
#
# [$package]
#   The name of the package to be installed. Useful if you are going
#   to install the same package under multiple ruby versions.
#   Default: $title
#   This variable is optional.
#
# [$version]
#   The version of the package to be installed.
#   Default: '>= 0'
#   This variable is optional.
#
# [$node_version]
#   The ruby version under which the package will be installed.
#   Default: undefined
#   This variable is required.
#
# [$skip_docs]
#   Skips the installation of ri and rdoc docs.
#   Default: false
#   This variable is optional.

# [$timeout]
#   Seconds that a package has to finish installing. Set to 0 for unlimited.
#   Default: 300
#   This variable is optional.
#
# [$env]
#   This is used to set environment variables when installing a package.
#   Default: []
#   This variable is optional.
#
# [$source]
#   Source to be passed ot the package command
#   Default: "https://rubypackages.org/"
#   This variable is optional.
# === Examples
#
# nodenv::package { 'thor': node_version => '2.0.0-p247' }
#
# === Authors
#
# Justin Downing <justin@downing.us>
#
define nodenv::package(
  $install_dir  = $nodenv::install_dir,
  $package      = $title,
  $version      = '>=0',
  $node_version = undef,
  $timeout      = 300,
  $source       = 'https://npmjs.com/'
) {
  include nodenv

  if $node_version == undef {
    fail('You must declare a node_version for nodenv::package')
  }

  $environment_for_install = ["NODENV_ROOT=${install_dir}"]
  $version_for_exec_name = regsubst($version, '[^0-9]+', '_', 'EG')

  exec { "node-${node_version}-package-install-${package}-${version_for_exec_name}":
    command => "npm install ${package} --version '${version}' --global --source '${source}'",
    unless  => "npm ls --depth=0 -g ${package}@${version}",
    path    => [
      "${install_dir}/versions/${node_version}/bin/",
      '/usr/bin',
      '/usr/sbin',
      '/bin',
      '/sbin'
    ],
    timeout => $timeout
  }
  ~> exec { "ruby-${node_version}-nodenv-rehash-${package}-${version_for_exec_name}":
    command     => "${install_dir}/bin/nodenv rehash",
    refreshonly => true,
  }
  ~> exec { "ruby-${node_version}-nodenv-permissions-${package}-${version_for_exec_name}":
    command     => "/bin/chown -R ${nodenv::owner}:${nodenv::group} \
                  ${install_dir}/versions/${node_version}/lib/node_modules && \
                  /bin/chmod -R g+w \
                  ${install_dir}/versions/${node_version}/lib/node_modules",
    refreshonly => true,
  }

  Exec {
    environment => $environment_for_install,
    require => Exec["nodenv-install-${node_version}"]
  }
}
