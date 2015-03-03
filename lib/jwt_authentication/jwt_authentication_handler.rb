require 'active_support/concern'

require 'jwt_authentication/entities_manager'
require 'jwt_authentication/sign_in_handler'
require 'jwt_authentication/exceptions'

module JwtAuthentication
  module JwtAuthenticationHandler
    extend ::ActiveSupport::Concern

    included do
      private_class_method :define_jwt_authentication_helpers_for
      private_class_method :entities_manager

      private :authenticate_entity_by_jwt!
      private :sign_in_handler
      private :raise_error!
    end

    def authenticate_entity_by_jwt!(entity)
      return true unless valid_entity_name?(entity)
      record = entity.get_entity(self)
      return false unless record.present?
      perform_sign_in!(record, sign_in_handler, self)
      true
    end

    def sign_in_handler
      @@sign_in_handler ||= SignInHandler.new
    end

    def raise_error!
      raise JwtAuthentication::NotAuthenticated.new('Not authenticated')
    end

    def valid_entity_name?(entity)
      jwt_models.has_key? entity.name_underscore.to_sym
    end

    module ClassMethods
      def handle_jwt_authentication(options = {})
        options = JwtAuthentication.parse_options(options)
        (options[:models] || JwtAuthentication.models).each do |model, params|
          entity = entities_manager.find_or_create_entity(model)
          define_jwt_authentication_helpers_for(entity)
          sign_in_method = options[:sign_in] || :devise
          define_sign_in_method(entity, sign_in_method)
        end
        define_common_helpers(options)
      end

      def entities_manager
        if class_variable_defined?(:@@entities_manager)
          class_variable_get(:@@entities_manager)
        else
          class_variable_set(:@@entities_manager, EntitiesManager.new)
        end
      end

      def define_sign_in_method(entity, method = :devise)
        case method   # :devise, :simplified
        when :devise
          sign_in_method = lambda { |record, sign_in_handler, controller| sign_in_handler.sign_in controller, record, store: false }
        else
          sign_in_method = lambda { |record, sign_in_handler, controller| controller.instance_variable_set("@#{entity.name.underscore}", record) }
        end

        class_eval do
          define_method :perform_sign_in! do |record, sign_in_handler, controller|
            sign_in_method.call(record, sign_in_handler, controller)
          end
          private :perform_sign_in!
        end
      end

      def define_common_helpers(options)
        class_eval do
          define_method :jwt_models do
            lambda do |models|
              return models
            end.call(options[:models])
          end
        end
      end

      def define_jwt_authentication_helpers_for(entity)
        class_eval do
          define_method "jwt_authenticate_#{entity.name_underscore}".to_sym do
            lambda do |_entity|
              authenticate_entity_by_jwt!(_entity)
            end.call(entity)
          end

          define_method "jwt_authenticate_#{entity.name_underscore}!".to_sym do
            lambda do |_entity|
              raise_error! unless authenticate_entity_by_jwt!(_entity)
            end.call(entity)
          end
        end
      end
    end
  end
end
