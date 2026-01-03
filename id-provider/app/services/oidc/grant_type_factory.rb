# frozen_string_literal: true

module Oidc
  class GrantTypeFactory
    GRANT_TYPE_CLASSES = {
      'authorization_code' => Oidc::GrantTypes::AuthorizationCodeFlow,
      'client_credentials' => Oidc::GrantTypes::ClientCredentialsFlow,
    }.freeze

    def self.create(grant_type, params, request)
      grant_class = GRANT_TYPE_CLASSES[grant_type]

      raise UnsupportedGrantTypeError, grant_type unless grant_class

      grant_class.new(params, request)
    end

    def self.supported?(grant_type)
      GRANT_TYPE_CLASSES.key?(grant_type)
    end

    class UnsupportedGrantTypeError < StandardError
      def initialize(grant_type)
        super("Unsupported grant type: #{grant_type}")
      end
    end
  end
end
