# frozen_string_literal: true

module AuthenticationHelpers
  def login_as(user)
    post login_url, params: { email: user.email, password: 'Password123' }
  end
end
