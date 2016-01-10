require 'devise/models/authenticatable'

Devise::Models::Authenticatable::BLACKLIST_FOR_SERIALIZATION << :authentication_token
