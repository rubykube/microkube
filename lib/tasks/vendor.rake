namespace :vendor do
  ENV['APP_DOMAIN'] = CONFIG['app']['domain']

  desc 'Clone the frontend and tower repositories into vendor/'
  task :clone do
    puts '----- Cloning frontend and tower repos -----'
    sh "git clone #{CONFIG['vendor']['frontend']} vendor/frontend" unless File.exist? 'vendor/frontend'
    sh "git clone #{CONFIG['vendor']['tower']} vendor/tower" unless File.exist? 'vendor/tower'
  end

  desc 'Starting the frontend and tower repositories from vendor/'
  task :start do
    puts '----- Starting development frontend and tower services -----'
    sh "docker-compose rm -f -s -v tower frontend"
    sh "docker-compose -f compose/dev.yaml up -d tower frontend"
  end
end
