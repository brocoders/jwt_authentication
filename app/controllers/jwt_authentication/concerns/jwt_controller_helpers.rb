module JwtAuthentication
  module Concerns
    module JwtControllerHelpers
      extend ActiveSupport::Concern

      included do
        skip_before_filter :verify_authenticity_token  # to avoid Devise check anti forgery token
        before_filter :allow_params_authentication!
        before_filter :set_request_format!
      end

      def render_resource_or_errors(resource, options = {})
        if resource.errors.empty?
          render options.merge({ json: { resource: resource } })
        else
          render json: { errors: resource.errors }, status: :unprocessable_entity
        end
      end

      def json_status(bool)
        bool ? :ok : :error
      end

      def require_no_authentication
      end

      def set_request_format!
        request.format = :json
      end
    end
  end
end
