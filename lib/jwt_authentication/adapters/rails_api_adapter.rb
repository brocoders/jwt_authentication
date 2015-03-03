require 'action_controller'
require 'jwt_authentication/adapter'

module JwtAuthentication
  module Adapters
    class RailsAPIAdapter
      extend JwtAuthentication::Adapter

      def self.base_class
        ::ActionController::API
      end
    end

    # make the adpater available even if the 'API' acronym is not defined
    RailsApiAdapter = RailsAPIAdapter
  end
end

