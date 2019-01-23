require 'microkube/renderer'

describe Microkube::Renderer do
  let(:renderer) { Microkube::Renderer.new("test/app.yml", "#{Dir.pwd}/templates", Dir.pwd) }
  let(:fake_erb_result) { { 'data' => 'this is fake data'} }
  let(:config) do
    {
      'app' => {
        'name' => 'Microkube',
        'domain' => 'app.test'
      },
      'ssl' => {
        'enabled' => 'true',
        'email' => 'support@example.com'
      },
      'images' => {
        'peatio' => 'rubykube/peatio:latest',
        'barong' => 'rubykube/barong:latest',
        'frontend' => 'rubykube/mikroapp:latest',
        'tower' => 'rubykube/tower:latest'
      },
      'vendor' => {
        'frontend' => 'https://github.com/rubykube/mikroapp.git'
      }
    }
  end

  describe '.config' do
    it 'should load configuration' do
      allow(YAML).to receive(:load_file).and_return(config)
      expect(renderer.config).to eq(config)
    end
  end

  describe '.template_name' do
    it 'should exclude "templates" directory' do
      file_name = renderer.template_name('./templates/config/peatio.env.erb')
      expect(file_name).not_to start_with('./templates')
    end

    it 'should return relative path to file' do
      file_name = renderer.template_name('./templates/compose/app.yaml.erb')
      expect(file_name).to start_with('.')
    end
  end

  describe '.render' do
    it 'should call exact amount of helper functions' do
      number_of_files = Dir.glob('./templates/**/*.erb').length

      expect(renderer).to receive(:render_keys).once
      expect(renderer).to receive(:render_file).exactly(number_of_files).times
      expect(renderer).to receive(:template_name).exactly(number_of_files).times

      renderer.render
    end
  end
end
