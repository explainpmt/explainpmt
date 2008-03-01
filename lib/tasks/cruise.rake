task :cruise =>[ 'cruise:dbconfig', 'db:migrate', :test ]

namespace :cruise do
  task :dbconfig do
    confdir = File.dirname( __FILE__ ) + '/../../config'
    `cp #{confdir}/database_cruise.yml #{confdir}/database.yml`
  end
end