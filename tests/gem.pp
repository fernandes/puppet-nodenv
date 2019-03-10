package { ['git', 'build-essential']: ensure => 'installed' }
-> class { 'nodenv': }
-> nodenv::plugin { 'nodenv/ruby-build': }
-> nodenv::build { '2.0.0-p247': global => true }
-> nodenv::gem { 'thor':
  version      => '0.18.1',
  ruby_version => '2.0.0-p247'
}
