require 'active_record'
require 'jwt_authentication/adapter'

module JwtAuthentication
  module Adapters
    class ActiveRecordAdapter
      extend JwtAuthentication::Adapter

      def self.base_class
        ::ActiveRecord::Base
      end
    end
  end
end
