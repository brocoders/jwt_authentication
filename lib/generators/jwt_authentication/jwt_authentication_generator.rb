require 'rails/generators/named_base'

module JwtAuthentication
  module Generators
    class JwtAuthenticationGenerator < Rails::Generators::NamedBase
      include Rails::Generators::ResourceHelpers
      hook_for :orm
    end
  end
end
