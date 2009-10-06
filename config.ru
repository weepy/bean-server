require 'app'

log = File.new("sinatra.log", "a")
STDOUT.reopen(log)
STDERR.reopen(log)

set :environment, :development
run Sinatra::Application