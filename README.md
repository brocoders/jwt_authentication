JWT Authentication
===========================

This is mix of Simple Token Authentication and JWT.

  [devise]: https://github.com/plataformatec/devise
  [jwt-gem]: https://github.com/progrium/ruby-jwt

Installation
------------

Install [Devise][devise] with any modules you want, then add the gem to your `Gemfile`:

```ruby
# Gemfile

gem 'jwt_authentication'
```

### Make models token authenticatable

#### ActiveRecord

First define which model or models will be token authenticatable (typ. `User`):

```ruby
# app/models/user.rb

class User < ActiveRecord::Base
  acts_as_jwt_authenticatable

  # Note: you can include any module you want. If available,
  # token authentication will be performed before any other
  # Devise authentication method.
  #
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable,
         :lockable

  # ...
end
```

If the model or models you chose have no `:authentication_token` attribute, add them one (with an index):

```bash
rails g jwt_authentication MODEL
```
This will add 'acts_as_jwt_authenticatable' to specified MODEL. Also, this will generate migration for adding 'authentication_token' to MODEL.
To skip generating migration, add '-m' parameter: rails g jwt_authentication User -m


### Allow controllers to handle jwt authentication

Finally define which controllers will handle jwt authentication (typ. `ApplicationController`) for which _jwt authenticatable_ models:

 ```ruby
 # app/controllers/application_controller.rb

 class ApplicationController < ActionController::Base # or ActionController::API
   # ...

   acts_as_jwt_authentication_handler
   # Note: you can specify several parameters for handling authentication for this controller:  
   #   :model (which "acts as jwt authenticatable") for authenticating
   # 
   #   :key_field. Name of the field in _payload_ of decoded jwt. Entity will be searched in database by this field.
   #
   #   :before_filter. Should the before_filter (with selected authenticate method) be injected in controller.   
   #
   #   :fallback. What to do, if jwt_authentication falls. 
   #
   #   :sign_in. How to authenticate entity in controller.
   #
   # example:
   #  acts_as_jwt_authentication_handler model: :terminal, before_filter: true, fallback: :none, key_field: :id, sign_in: :simplified
   # 
   # ...
 end
 ```
See detailed parameters description in [Configuration](#configuration)

Configuration
-------------

Some aspects of the behavior of _Jwt Authentication_ can be customized with an initializer.
Below is an example with reasonable defaults:

```ruby
# config/initializers/jwt_authentication.rb

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

end

# # Configure list of Devise Controllers to be overridden. Those controllers will work via JSON.
# # Note: request should contain 'Accept' header, that has 'application/json' value
# # Possible controllers list: %i{registrations confirmations passwords sessions}
# JwtAuthentication.override_devise_controllers [:sessions, :passwords]

```
You'll find details for `:fallback` parameters in in [Fallback](#fallback)
You'll find details for `:sign_in` parameters in in [Sign in](#sign-in) 

Usage
-----

### Tokens Generation

Assuming `user` is an instance of `User`, which is _jwt authenticatable_: each time `user` will be saved, and `user.authentication_token.blank?` it receives a new and unique authentication token (via `Devise.friendly_token`).

### Authentication Method 1: Query Params

You can authenticate passing the `user_token` params as query params:

```
GET https://secure.example.com?user_token=eyJ0eXAiOiJKV1QiLCJhbGciOiJ...iGhux7wDwM_QFpU
```

The _token authentication handler_ (e.g. `ApplicationController`) will perform the user sign in if both are correct.

### Authentication Method 2: Request Headers

You can also use request headers (which may be simpler when authenticating against an API):

```
X-User-Token eyJ0eXAiOiJKV1QiLCJhbGciOiJ...iGhux7wDwM_QFpU
```

Authentication process
-----

### Authentication methods

`acts_as_jwt_authentication_handler` method in controller will generate and add 4 auth method for controller. 
Each of them will try to authenticate entity with. 
The difference is in then behavior at auth falling: it matches fallback parameter in config:  
  
  * `:authenticate_user_by_jwt` - fallback: :`none`
  * `:authenticate_user_by_jwt!` - fallback: :`error`
  * `:authenticate_user_by_jwt_and_devise` fallback: :`devise`
  * `:authenticate_user_by_jwt_with_response` fallback: :`response`
Instead of user there`ll be name of specified model
Detailed info about fallback is in [Fallback](#fallback)

If parameter `before_filter` set to true, one of this methods (it depends on `fallback`) will be set as before_filter  

You may set one of this method in any action:
```ruby
  class GroupsController < ApplicationController    
    def index
      authenticate_user_by_jwt!
      render json: current_user.groups
    end
  end
```

### Sign in
Jwt Authentication supports 3 variants of authentication - _:devise_, _:devise_with_session_, _:simplified_
  * `:devise` _(default)_ standard devise _sign_in_ call with _entity_m, that was authenticated
  * `:devise_with_session` the same as _:devise_, but with saving devise session
  * `:simplified` just creates `@user` (or other specified @entity) controller instance variable

### Fallback
There are 4 variants of fallback - `:none`, `:devise`, `:response`, `:error`
   * `:none` _(default)_ nothing happens if entity could not be authenticated
   * `:devise` control is given to devise strategies
   * `:response` process will be interrupted and 'not authenticated' error is returned in json
   * `:error` process will be interrupted with NotAuthenticated error throwing

Devise controllers
-----

You may override Devise controllers for working via JSON.
For doing this, uncomment `override_devise_controllers` method in _jwt_authentication.rb_ initializer and specify controllers to be overridden.
`override_devise_controllers` will create alias method chains for needed actions: create -> create_with_token, create_without_token, etc. 
Dependently on accept headers in request, actions will be called. IF _json_ was requested, create_with_token will be called, create_without_token otherwise.  
