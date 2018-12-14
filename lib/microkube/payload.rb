require 'jwt'

class PayloadError < StandardError
end

module Microkube
  class Payload
    def initialize(params)
      @jwt_secret = params[:secret]
      @jwt_exp = params[:expire]
      raise PayloadError.new unless @jwt_secret
      @jwt_exp = 600 unless @jwt_exp
    end

    def encode(token)
      JWT.encode token, @jwt_secret, 'HS256'
    end

    def generate!(params)
      raise PayloadError.new unless params[:service]
      raise PayloadError.new unless params[:tag]

      token = params.merge({
        'iat': Time.now.to_i,
        'exp': (Time.now + @jwt_exp).to_i
      })

      encode token
    end

    def decode!(token)
      JWT.decode(token, @jwt_secret, true, {
        algorithm: 'HS256'
      }).first
    end

    def safe_decode(token)
      begin
        decode!(token)
      rescue JWT::ExpiredSignature
      rescue JWT::ImmatureSignature
      rescue JWT::VerificationError
      rescue JWT::DecodeError
        nil
      end
    end
  end
end
