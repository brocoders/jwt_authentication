JWT Authentication
===========================

  [devise]: https://github.com/plataformatec/devise
  [jwt-gem]: https://github.com/progrium/ruby-jwt
  [sta-gem]: https://github.com/gonzalo-bulnes/simple_token_authentication

This is mix of [Simple Token Authentication][sta-gem] and [JWT][jwt-gem], based on [Devise][devise].



* [Installation](#installation)
* [Using](#using)
* [Configuring](#configuring)
* [Authentication](#authentication)
* [Devise](#devise)

Installation
-----

Add the gem to your `Gemfile`:

```ruby
# Gemfile

gem 'jwt_authentication', github: 'Rezonans/jwt_authentication'
```

Using
-----

### Models

Make models token authenticatable

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

Method `acts_as_jwt_authenticatable` extends Model with several methods: `:jwt_token`, `:generate_authentication_token!`
and some others. Obviously, `jwt_token` returns token for current record and `:generate_authentication_token!` updates record with new authentication_token.

If the model or models you chose have no `:authentication_token` attribute, add them one (with an index):

```bash
rails g jwt_authentication MODEL
```
This will add 'acts_as_jwt_authenticatable' to specified MODEL. Also, this will generate migration for adding 'authentication_token' to MODEL.
To skip generating migration, add '-m' parameter: rails g jwt_authentication User -m.
Migration looks like:
```ruby
  def change
    add_column :users, :authentication_token, :string
    add_index  :users, :authentication_token
  end
```


### Allow controllers to handle jwt authentication

Define controllers, which will handle jwt authentication (typ. `HomeController`) for which _jwt authenticatable_ models:

 ```ruby
 # app/controllers/home_controller.rb

 class HomeController < ActionController::Base # or ActionController::API
   # ...

   acts_as_jwt_authentication_handler
   # Note: you can specify several parameters for handling authentication for this controller:  
   #   :models (which "acts as jwt authenticatable") for authenticating, hash, that specifies models
   #            and those authentication parameters :header_name, :param_name, :sign_in
   #
   # example:
   #  acts_as_jwt_authentication_handler models: {terminal: {header_name: 'terminal_auth_token',
   #                                                         param_name: 'X-Auth-Terminal-Token',
   #                                                         sign_in: :simplified}
   # 
   # ...
 end
 ```

Method `acts_as_jwt_authentication_handler` extends controller with methods: `:jwt_authenticate_user`, `::jwt_authenticate_user!` and some others.
Instead of _user_ there will be specified model names, pair of methods for each model.

See detailed parameters and methods description in [Authentication](#authentication)

Atfer controller was extended with jwt_authentication helpers, you may authenticate entity in actions or in before filter:

```ruby
class TerminalsController < ActionController
  acts_as_jwt_authentication_handler models: {terminal: {sign_in: :simlified}}
  before_filter :jwt_authenticate_terminal!

  def show
    @terminal
  end

end

```

### Routing

Define devise routes for creating devise mapping.

```ruby
# config/routes.rb

...
devise_for :users, module: :jwt_authentication
...

```
Devise routing is necessary, because it creates devise mappings.

Configuring
------

Some aspects of the behavior of _Jwt Authentication_ can be customized with an initializer.
Below is an example with reasonable defaults:

```ruby
# config/initializers/jwt_authentication.rb

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

end
```

Authentication
-----

As there was mentioned in [Using](#using), method `acts_as_jwt_authentication_handler` add to controller two methods:
`:jwt_authenticate_user` and `:jwt_authenticate_user!`. Method with bang raises error, if authentication falls,
method without bang do nothing if authentication falls.
 Authentication process in primitive simple:
* Analize request - try to find token in params or header. If token not found, authentication falls.
* Read payload from jwt
* Search for entity by field, that payload contains. If entity not found, authentication falls.
* Decode jwt with entities `authentication_token` (private key, that is stored as entities field).
     If `jwt_timeout_verify` specified, timeout verification will take place also.
* If token successfully verified - _sign_in handler_ will be called, otherwise authentication falls.

 `sign_in_handler`. You may specify, what to do at success authentication in `sign_in` parameter in model:
   ```ruby
   # config/initializers/jwt_authentication.rb
   ...
   config.models = {user: {sign_in: :devise}}
   ...
   ```
 There are 2 variants:
* `:devise` (default) - `:sign_in` (devise controller method) will be called
* `:simplified` - create instance variable with resource name (@user, @terminal, etc).

Devise
-----

JwtAuthentication inherits devise controllers: Registrations, Confirmations, Sessions, Passwords.
So, you can extend this functionality with inheritance or overriding some of them.
Note, that you need to specify routes to this inherited controllers, like this:
```ruby
# config/routes.rb
...
devise_for :users, module: :jwt_authentication
...

```
_Note: request format will be set to `:json` by before filter `:set_request_format!`, that is plugged to each inherited devise controller.
It is necessary for process action if `warder.authenticate!` falls. It will render view for sessions creating by default, 
by in our case, we need json response :unauthorized_  
