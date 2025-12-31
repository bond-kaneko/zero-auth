class UserRepository
    def self.find_by_email(email)
      dummy_user if email == 'test@example.com'
    end

    def self.find_dummy_user
      dummy_user
    end

    private

    def self.dummy_user
      DummyUser.new(
        email: 'test@example.com',
        password: 'password',
        name: 'Test User',
        given_name: 'Test',
        family_name: 'User',
        sub: 'dummy-sub-12345'
      )
    end

    class DummyUser
      attr_reader :id, :email, :name, :given_name, :family_name, :sub

      def initialize(email:, password:, name:, given_name:, family_name:, sub:)
        @id = -1
        @email = email
        @password = password
        @name = name
        @given_name = given_name
        @family_name = family_name
        @sub = sub
      end

      def authenticate(password)
        ActiveSupport::SecurityUtils.secure_compare(@password, password)
      end

      # For compatibility with User model
      def persisted?
        true
      end

      def new_record?
        false
      end
    end
  end