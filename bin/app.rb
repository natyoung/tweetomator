require 'sinatra'
require_relative '../lib/tweetomator'

get '/' do
  Thread.new do
    begin
      t = Tweetomator.new
      t.run_once
    rescue
      return 'Goodbye World!'
    end
  end
  'Hello World!'
end
