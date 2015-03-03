JwtAuthentication.configure do |config|
  #
  # # Configure model, that will be default for `acts_as_jwt_authentication_handler` calling.
  # # Note: specified model should have `authentication_token` attribute (Model should "act as jwt authenticatable")
  # config.model = :user
  #
  # # Configure default fallback, that will be default for `acts_as_jwt_authentication_handler` calling.
  # # Possible values: :none, :devise, :response, :error
  # config.fallback = :none
  #
  # # Configure default sign_in authentication reaction, that will be default for `acts_as_jwt_authentication_handler` calling.
  # # Possible values: :devise, :devise_session, :simplified
  # config.sign_in = :devise
  #
  # # Configure default before_filter injection mark, that will be default for `acts_as_jwt_authentication_handler` calling.
  # # True - inject, false - do not inject.
  # config.before_filter = true
  #
  # # Configure default key_field, that will be default for `acts_as_jwt_authentication_handler` calling.
  # # Value of this filed will be searched in payload if received jwt, entity fill by searched by this field :
  # #  token: { email: test@mail.com }           # decoded jwt
  # #  `model.where(key_field => key).first`     # entity search
  # config.key_field = :email
  #
  # # Configure default header and parameter names for searching jwt in request.
  # config.header_names = { user: { jwt_header_name: 'X-User-JWT', jwt_param_name: 'user_jwt' } }
  #
  # # Configure mark of jwt timeout verification
  # config.jwt_timeout_verify = true
  #
  # # Configure jwt timeout leeway (value in seconds)
  # config.jwt_timeout_leeway = 60
  #
  # # Configure jwt timeout for simple login (without "remember me)
  # # Devise SessionsController generates jwt according to this parameter
  # config.jwt_timeout = 20.minutes
  #
  # # Configure jwt timeout for session login (with "remember me)
  # # Devise SessionsController generates jwt according to this parameter
  # config.jwt_timeout_remember_me = 1.month
  #
  # # Configure list of controller actions not to be authenticated with jwt_authentication
  # # Example:
  # #   {'Devise::SessionsController'      => [:create, :destroy],
  # #    'Devise::RegistrationsController' => [:create],
  # #    'Devise::PasswordsController'     => [:create, :update],
  # #    'Devise::ConfirmationsController' => [:create, :show]}
  # config.jwt_skip_authentication_for = {}
  #
  # # Configure checking of 'application/json' presence in 'Accept' header.
  # # If true, jwt_authentication will not call Devise controller if such header exists,
  # # if there is no header 'Accept'=> 'application/json' Devise controller will be called.
  # # If false, jwt_authentication will be called always instead of Devise.
  # config.jwt_use_accept_json = false

end
