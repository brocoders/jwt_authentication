module JwtAuthentication
  class Engine < ::Rails::Engine
    initializer 'jwt-autentication' do |app|
      cookies_required = JwtAuthentication.models.any? { |key, value| value.is_a?(Hash) && value.has_key?(:cookie_name) }

      if cookies_required
        app.middleware.use ::ActionDispatch::Cookies

        JwtAuthentication::JwtAuthenticationHandler.module_exec do
          include ::ActionController::Cookies
        end
      end
    end
  end
end
