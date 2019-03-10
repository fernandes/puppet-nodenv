class { 'nodenv': }
-> nodenv::plugin { 'nodenv/ruby-build': }
-> nodenv::build { '2.0.0-p247': global => true }
