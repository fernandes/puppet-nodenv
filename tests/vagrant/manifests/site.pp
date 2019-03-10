class { 'nodenv': group => $group }

nodenv::plugin { 'nodenv/ruby-build': }
nodenv::plugin { 'nodenv/nodenv-vars': }
nodenv::build { '2.1.7': global => true }

nodenv::gem { 'rack':
  ruby_version => '2.1.7',
  skip_docs    => true,
}

nodenv::gem { 'backup':
  version      => '4.0.2',
  ruby_version => '2.1.7',
  skip_docs    => true,
}
