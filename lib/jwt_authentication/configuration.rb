module JwtAuthentication
  module Configuration

    mattr_accessor :models
    mattr_accessor :controller_adapters
    mattr_accessor :model_adapters
    mattr_accessor :adapters_dependencies
    mattr_accessor :jwt_timeout_verify
    mattr_accessor :jwt_timeout_leeway
    mattr_accessor :jwt_timeout
    mattr_accessor :jwt_timeout_remember_me
    mattr_accessor :key_fields

    @@controller_adapters = ['rails', 'rails_api']
    @@model_adapters = ['active_record', 'mongoid']
    @@adapters_dependencies = { 'active_record' => 'ActiveRecord::Base',
                                'mongoid'       => 'Mongoid::Document',
                                'rails'         => 'ActionController::Base',
                                'rails_api'     => 'ActionController::API' }
    @@jwt_timeout_verify = true
    @@jwt_timeout_leeway  = 60
    @@jwt_timeout = 20.minutes
    @@jwt_timeout_remember_me = 1.month
    @@models = {user: {header_name: 'X-User-Token',
                       param_name: 'user_token',
                       sign_in: :devise}}
    @@key_fields = [:email]

    def configure
      yield self if block_given?
    end

    def parse_options(options)
      options[:models]  ||= @@models
      options
    end
  end
end
