require 'sinatra'
require 'json'
require_relative 'payload'

services = %w[barong peatio frontend tower]

secret = ENV['WEBHOOK_JWT_SECRET']
raise 'WEBHOOK_JWT_SECRET is not set' unless secret
decoder = Microkube::Payload.new(secret: secret)

before do
  content_type 'application/json'
end

get '/deploy/ping' do
  'pong'
end

get '/deploy/' do
  token = env.fetch('HTTP_AUTHORIZATION', '').slice(7..-1)
  decoded = decoder.safe_decode(token)
  answer(400, 'invalid token') unless decoded

  service = decoded["service"]
  tag = decoded["tag"]

  answer(400, 'service is not specified') unless service
  answer(400, 'tag is not specified') unless tag
  answer(404, 'unknown service') unless services.include? service
  answer(400, 'invalid tag') unless /^[-\w\.]{,20}$/ =~ tag

  image_tag = "rubykube/#{service}:#{tag}"
  system "docker image pull #{image_tag}"

  unless $?.success?
    system("docker image inspect #{image_tag} > /dev/null")
    answer(404, 'invalid image tag') unless $?.success?
  end

  tag = "#{service.upcase}_IMAGE=#{image_tag}"
  system "#{tag} docker-compose up -Vd #{service}"

  answer(500, 'could not restart container') unless $?.success?
  answer(200, "service #{service} updated with tag #{image_tag}")
end

def answer(status, message)
  halt(status, {
    message: message
  }.to_json)
end
