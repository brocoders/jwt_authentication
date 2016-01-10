require 'jwt_authentication/acts_as_jwt_authenticatable'
require 'jwt_authentication/acts_as_jwt_authentication_handler'
require 'jwt_authentication/configuration'
require 'jwt_authentication/engine'
require 'jwt_authentication/devise'
require 'jwt'

module JwtAuthentication
  extend Configuration

  NoAdapterAvailableError = Class.new(LoadError)

  private

  def self.ensure_models_can_act_as_jwt_authenticatables model_adapters
    model_adapters.each do |model_adapter|
      model_adapter.base_class.send :include, JwtAuthentication::ActsAsJwtAuthenticatable
    end
  end

  def self.ensure_controllers_can_act_as_jwt_authentication_handlers controller_adapters
    controller_adapters.each do |controller_adapter|
      controller_adapter.base_class.send :extend, JwtAuthentication::ActsAsJwtAuthenticationHandler
    end
  end

  def self.load_available_adapters adapters_short_names
    available_adapters = adapters_short_names.collect do |short_name|
      adapter_name = "jwt_authentication/adapters/#{short_name}_adapter"
      if adapter_dependency_fulfilled?(short_name) && require(adapter_name)
        adapter_name.camelize.constantize
      end
    end
    available_adapters.compact!

    raise JwtAuthentication::NoAdapterAvailableError if available_adapters.empty?

    available_adapters
  end

  def self.adapter_dependency_fulfilled? adapter_short_name
    qualified_const_defined?(JwtAuthentication.adapters_dependencies[adapter_short_name])
  end

  available_model_adapters = load_available_adapters JwtAuthentication.model_adapters
  ensure_models_can_act_as_jwt_authenticatables available_model_adapters

  available_controller_adapters = load_available_adapters JwtAuthentication.controller_adapters
  ensure_controllers_can_act_as_jwt_authentication_handlers available_controller_adapters

end
