module JwtAuthentication
  class Entity
    def initialize(model)
      @model = model
      @name = model.name
    end

    def model
      @model
    end

    def name
      @name
    end

    def name_underscore
      name.underscore
    end

    def token_header_name(controller)
      controller.jwt_models[name_underscore.to_sym][:header_name] || "X-#{name}-Token"
    end

    def token_param_name(controller)
      controller.jwt_models[name_underscore.to_sym][:param_name] || "#{name_underscore}_token"
    end

    def token_cookie_name(controller)
      controller.jwt_models[name_underscore.to_sym][:cookie_name]
    end

    def cookie_enabled?(controller)
      token_cookie_name(controller).present?
    end

    def get_token_from_cookie(controller)
      cookie_enabled?(controller) ? controller.send(:cookies).signed[token_cookie_name(controller)] : nil
    end

    def get_token(controller)
      (get_token_from_cookie(controller) || controller.request.headers[token_header_name(controller)] || controller.params[token_param_name(controller)]).to_s
    end

    def get_entity(controller)
      begin
        token = get_token controller
        payload = JWT.decode(token, nil, false)[0]        # get payload; decode can raise: JWT::DecodeError
        keys = model.jwt_key_fields.inject({}) do |hash, field|
          hash[field] = payload[name_underscore][field.to_s]
          hash
        end
        keys[:email] = integrate_with_devise_case_insensitive_keys(keys[:email]) if keys[:email].present?
        record = find_entity_by_keys(keys)
        JWT.decode(token, record.authentication_token, true, verify_expiration: JwtAuthentication.jwt_timeout_verify, leeway: JwtAuthentication.jwt_timeout_leeway)
        record
      rescue
        nil
      end
    end

    def find_entity_by_keys(keys)
      model.find_by keys
    end

    # Private: Take benefit from Devise case-insensitive keys
    #
    # See https://github.com/plataformatec/devise/blob/v3.4.1/lib/generators/templates/devise.rb#L45-L48
    #
    # email - the original email String
    #
    # Returns an email String which case follows the Devise case-insensitive keys policy
    def integrate_with_devise_case_insensitive_keys(email)
      email.downcase! if email && Devise.case_insensitive_keys.include?(:email)
      email
    end
  end
end
