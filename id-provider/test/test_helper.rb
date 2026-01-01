# frozen_string_literal: true

require 'simplecov'
SimpleCov.start 'rails' do
  add_filter '/test/'
  add_filter '/config/'
  add_filter '/vendor/'

  add_group 'Controllers', 'app/controllers'
  add_group 'Models', 'app/models'
  add_group 'Helpers', 'app/helpers'
  add_group 'Services', 'app/services'
end

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'minitest/spec'

module ActiveSupport
  class TestCase
    # Remove conflicting describe method if it exists and enable Minitest::Spec DSL
    class << self
      remove_method :describe if method_defined?(:describe)
    end
    extend Minitest::Spec::DSL

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end
