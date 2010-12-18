require 'data_loader'

namespace :explainpmt do
  task :upgrade do
    DataLoader.run!
    
  end
end