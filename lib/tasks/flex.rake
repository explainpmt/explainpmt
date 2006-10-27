desc 'compile the Flex interface'
task :flex => [ 'public/bin/explainpmt.swf', 'public/bin/explainpmt-debug.swf' ]

file 'public/bin/explainpmt.swf' => FileList[ 'app/flex/**/*.mxml',
  'app/flex/**/*.as', 'app/flex/**/*.swf' ] do |t|
  sh "mxmlc -o #{t.name} -incremental app/flex/explainpmt.mxml"
end

file 'public/bin/explainpmt-debug.swf' => FileList[ 'app/flex/**/*.mxml',
  'app/flex/**/*.as', 'app/flex/**/*.swf' ] do |t|
  if ENV['DEBUG']
    sh "mxmlc -o #{t.name} -incremental -debug app/flex/explainpmt.mxml"
  end
end