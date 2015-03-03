require 'active_support/deprecation'
require 'jwt_authentication/jwt_authentication_handler'

module JwtAuthentication
  module ActsAsJwtAuthenticationHandler
    def acts_as_jwt_authentication_handler(options = {})
      include JwtAuthentication::JwtAuthenticationHandler
      handle_jwt_authentication(options)
    end
  end
end
