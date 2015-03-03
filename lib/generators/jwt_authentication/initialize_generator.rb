require 'rails/generators/base'
require 'securerandom'

module JwtAuthentication
  module Generators
    class InitializeGenerator < Rails::Generators::Base
      source_root File.expand_path("../../templates", __FILE__)

      desc "Creates a JwtAuthentication initializer in your application."

      def copy_initializer
        template "jwt_authentication.rb", "config/initializers/jwt_authentication.rb"
      end

    end
  end
end
