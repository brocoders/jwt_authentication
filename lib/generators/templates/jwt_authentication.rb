JwtAuthentication.configure do |config|
  #
  # # Configure models, that will be default for `acts_as_jwt_authentication_handler` calling.
  # # Note: specified model should have `authentication_token` attribute (Model should "act as jwt authenticatable")
  # # header_name - name of header to search auth_token in request
  # # param_name - name of parameters to search auth_token in request
  # # sign_in - method to be executed if authentication success, possible values: :devise, :simplified
  # #           if :devise selected, devises method sign_in() will be called at success authentication,
  # #           if :simplified selected, instance variable with name of resource will be set (@user or @terminal)
  # config.models = {user: {header_name: 'X-User-Token',
  #                         param_name: 'user_token',
  #                         sign_in: :devise}}
  #
  # # Configure mark of jwt timeout verification
  # config.jwt_timeout_verify = true
  #
  # # Configure jwt timeout leeway (value in seconds)
  # config.jwt_timeout_leeway = 60
  #
  # # Configure jwt timeout for simple login (without "remember me)
  # # Devise SessionsController generates jwt according to this parameter
  # # * This parameter may be overridden in each model:
  # #    acts_as_jwt_authenticatable jwt_timeout: 10.minutes
  # config.jwt_timeout = 20.minutes
  #
  # # Configure jwt timeout for session login (with "remember me)
  # # Devise SessionsController generates jwt according to this parameter
  # # * This parameter may be overridden in each model:
  # #    acts_as_jwt_authenticatable jwt_timeout_remember_me: 1.week
  # config.jwt_timeout_remember_me = 1.month
  #
  # # Configure list of model keys, to be stored in jwt payload.
  # # Also, record we be searched by this fields at authentication.
  # # * This parameter may be overridden in each model:
  # #    acts_as_jwt_authenticatable key_fields: [:email, :id]
  # config.key_fields = [:email]
  #
  # # Configure response http-status at fail. If true - status at error will be 422, if false - 200
  # config.status_error_in_response = false
  #

end
