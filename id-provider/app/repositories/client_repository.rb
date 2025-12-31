class ClientRepository
    def self.find_by_client_id(client_id)
        dummy_client
    end

    private

    def self.dummy_client
      DummyClient.new(
        client_id: 'DUMMY',
        client_secret: 'DUMMY',
        redirect_uris: ['https://service-provider.local:3444/auth/callback']
      )
    end

    class DummyClient
      attr_reader :id, :client_id, :client_secret, :redirect_uris

      def initialize(client_id:, client_secret:, redirect_uris:)
        @id = -1
        @client_id = client_id
        @client_secret = client_secret
        @redirect_uris = redirect_uris
      end

      def active?
        true
      end

      def valid_redirect_uri?(uri)
        @redirect_uris.include?(uri)
      end

      def supports_response_type?(response_type)
        response_type == 'code'
      end

      def authenticate(secret)
        ActiveSupport::SecurityUtils.secure_compare(@client_secret, secret)
      end
    end
  end