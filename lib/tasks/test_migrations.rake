desc 'Test the database migrations'
task :test_migrations do
  sh 'rake migrate'
  sh 'rake migrate VERSION=0'
  sh 'rake migrate'
end
