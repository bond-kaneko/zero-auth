# frozen_string_literal: true

module Oidc
  class ApplicationController < ApplicationController
    skip_before_action :verify_authenticity_token
  end
end
