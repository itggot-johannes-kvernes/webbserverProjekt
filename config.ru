# Use bundler to load gems
require 'bundler'
require 'byebug'

# Load gems from Gemfile
Bundler.require

# Load the app
require_relative 'app.rb'

# Load models
Dir.glob('models/*.rb') do |m|
    require_relative m
end

# Make sure PUT, PATCH, and DELETE work
use Rack::MethodOverride

# Slim options
Slim::Engine.set_options pretty: true, sort_attrs: false

# Enable sessions
App.enable :sessions

# Run the app
run App