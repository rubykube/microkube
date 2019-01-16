
require_relative '../microkube/renderer'

namespace :render do
  desc 'Render configuration files'
  task :config do
    renderer = Microkube::Renderer.new('./config/app.yml', './templates', '.')
    renderer.render
  end
end
