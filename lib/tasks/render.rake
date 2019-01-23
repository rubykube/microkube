require_relative '../microkube/renderer'

namespace :render do
  desc 'Render configuration files'
  task :config do
    renderer = Microkube::Renderer.new("#{Dir.pwd}/config/app.yml", "#{Dir.pwd}/templates", Dir.pwd)
    renderer.render
  end
end
