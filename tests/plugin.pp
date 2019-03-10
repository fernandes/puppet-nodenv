package { 'git': ensure => 'installed' }
-> class { 'nodenv': }
-> nodenv::plugin { 'nodenv/ruby-build': }
