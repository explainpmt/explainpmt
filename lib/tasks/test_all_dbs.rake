desc 'Migrate and test'
task :migrate_and_test do
  sh 'rake test_migrations'
  sh 'rake test'
end

desc 'Run unit and functional tests for postgresql'
task :test_postgresql do
  sh 'cp config/database.yml config/database.yml.before_test'
  sh 'cp config/database.yml.postgresql config/database.yml'
  sh 'rake migrate_and_test'
  sh 'mv config/database.yml.before_test config/database.yml'
end

desc 'Run unit and funtional tests for mysql'
task :test_mysql do
  sh 'cp config/database.yml config/database.yml.before_test'
  sh 'cp config/database.yml.mysql config/database.yml'
  sh 'rake migrate_and_test'
  sh 'mv config/database.yml.before_test config/database.yml'
end

desc 'Run the unit and functional tests for sqlite3'
task :test_sqlite3 do
  sh 'cp config/database.yml config/database.yml.before_test'
  sh 'cp config/database.yml.sqlite3 config/database.yml'
  sh 'rake migrate_and_test'
  sh 'mv config/database.yml.before_test config/database.yml'
end

desc 'Run unit and functional tests for all dbs'
task :test_all_dbs => [ :test_postgresql, :test_mysql, :test_sqlite3 ]
