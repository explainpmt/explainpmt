task :tu => :test_units

task :tf => :test_functional

task :test => [ :test_units, :test_functional ]
