# Use bundler to load gems
require 'bundler'

# Load gems from Gemfile
Bundler.require

# Load the app
require_relative 'app.rb'

# Load models
require_relative 'models/User.rb'
require_relative 'models/Post.rb'

# Make sure PUT, PATCH, and DELETE work
use Rack::MethodOverride

# Slim options
Slim::Engine.set_options pretty: true, sort_attrs: false

# Enable sessions
# enable :sessions

# Run the app
run App