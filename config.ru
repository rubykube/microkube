#\ -s Puma -b tcp://0.0.0.0 -p 1337

require_relative 'lib/microkube/webhook'

run Webhook
