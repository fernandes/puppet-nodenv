package { 'git': ensure => 'installed' }
-> class { 'nodenv': }
-> nodenv::plugin { 'nodenv/nodenv-vars': }
