# frozen_string_literal: true

module Paginatable
  extend ActiveSupport::Concern

  class ValidationError < StandardError
    attr_reader :message

    def initialize(message)
      @message = message
      super
    end
  end

  private

  def validate_pagination_params!(page:, per_page:)
    raise ValidationError, "page must be greater than or equal to 0" if page.negative?

    raise ValidationError, "per_page must be greater than or equal to 1" if per_page < 1

    return unless per_page > 1000

    raise ValidationError, "per_page must be less than or equal to 1000"
  end
end
