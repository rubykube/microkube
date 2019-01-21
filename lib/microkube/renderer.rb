require 'openssl'
require 'pathname'
require 'yaml'
require 'base64'

module Microkube
  # Renderer is class for rendering Microkube templates.
  class Renderer
    JWT_KEY = 'config/secrets/barong.key'.freeze
    SSH_KEY = 'config/secrets/kite.key'.freeze

    def initialize(config_path, template_path, output_path, keys)
      @template_path = Pathname.new(template_path)
      @output_path   = Pathname.new(output_path)
      @config_path   = config_path

      keys.each do |key|
        name = File.basename(key).sub('.', '_')
        instance_variable_set("@#{name}", OpenSSL::PKey::RSA.new(File.read(key), ''))
      end
    end

    def render
      render_keys

      Dir.glob("#{@template_path}/**/*.erb").each do |file|
        render_file(file, template_name(file))
      end
    end

    # TODO: Exclude vars to special controller.
    def render_file(file, out_file)

      data = {
        config: config,
        barong_key: @barong_key,
        jwt_private_key: Base64.urlsafe_encode64(@barong_key.to_pem),
        jwt_public_key: Base64.urlsafe_encode64(@barong_key.public_key.to_pem)
      }

      result = ERB.new(File.read(file), 0, '-').result_with_hash(data)
      File.write(out_file, result)
    end

    def template_name(file)
      path = Pathname.new(file)
      out_path = path.relative_path_from(@template_path).sub('.erb', '')
      File.join(@output_path, out_path)
    end

    def render_keys
      generate_key(JWT_KEY)
      generate_key(SSH_KEY, public: true)
    end

    def generate_key(filename, public: false)
      key = OpenSSL::PKey::RSA.generate(2048)
      File.open(filename, 'w') { |file| file.puts(key) }
      File.open("#{filename}.pub", 'w') { |file| file.puts(key.public_key) } if public
    end

    def config
      YAML.load_file(@config_path)
    end
  end
end
