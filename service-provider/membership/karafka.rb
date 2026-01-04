# frozen_string_literal: true

# Karafka boot file - loads Rails and Karafka configuration
ENV['KARAFKA_ENV'] ||= ENV['RAILS_ENV'] || 'development'

require ::File.expand_path('config/environment', __dir__)

# Load Karafka configuration
require_relative 'config/karafka'
