require 'mongoid'
require 'jwt_authentication/adapter'

module JwtAuthentication
  module Adapters
    class MongoidAdapter
      extend JwtAuthentication::Adapter

      def self.base_class
        ::Mongoid::Document
      end
    end
  end
end
