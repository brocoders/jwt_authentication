module JwtAuthentication
  module Generators
    class SetupGenerator < Rails::Generators::Base
      def all
        generate 'jwt_authentication:initialize'
        generate 'jwt_authentication User'
      end
    end
  end
end
