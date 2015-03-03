require 'action_controller'
require 'jwt_authentication/adapter'

module JwtAuthentication
  module Adapters
    class RailsAdapter
      extend JwtAuthentication::Adapter

      def self.base_class
        ::ActionController::Base
      end
    end
  end
end
