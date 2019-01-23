require 'openssl'
require 'pathname'
require 'yaml'
require 'base64'

class BaseRenderer
  def initialize(config_path, template_path, output_path, keys)
    @template_path = Pathname.new(template_path)
    @output_path   = Pathname.new(output_path)
    @config_path   = config_path
    @keys          = keys

    keys.each do |key_path|
      key  = OpenSSL::PKey::RSA.generate(2048)
      File.open(key_path, 'w') { |file| file.puts(key) }
      name = File.basename(key_path).sub('.', '_')
      instance_variable_set("@#{name}", key)
      instance_variable_set("@public_#{name}", Base64.urlsafe_encode64(key.public_key.to_pem))
      instance_variable_set("@private_#{name}", Base64.urlsafe_encode64(key.to_pem))
    end
  end

  def render(data)
    Dir.glob("#{@template_path}/**/*.erb").each do |file|
      render_file(file, template_name(file), data)
    end
  end

  def render_file(file, out_file, data)
    result = ERB.new(File.read(file), 0, '-').result_with_hash(data)
    File.write(out_file, result)
  end

  def template_name(file)
    path = Pathname.new(file)
    out_path = path.relative_path_from(@template_path).sub('.erb', '')
    File.join(@output_path, out_path)
  end

  def config
    YAML.load_file(@config_path)
  end
end

module Microkube
  class Renderer < BaseRenderer
    def initialize(config_path, template_path, output_path)
      keys = %w(config/secrets/barong.key config/secrets/toolbox.key)
      super(config_path, template_path, output_path, keys)

    end

    def render
      data = {
        config: config,
        barong_key: @barong_key,
        jwt_public_key: @public_barong_key,
        jwt_private_key: @private_barong_key,
        toolbox_jwt_private_key: @private_toolbox_key
      }

      super(data)
    end
  end
end
