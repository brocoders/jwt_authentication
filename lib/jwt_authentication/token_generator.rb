require 'devise'

module JwtAuthentication
  class TokenGenerator
    def generate_token
      Devise.friendly_token
    end
  end
end
