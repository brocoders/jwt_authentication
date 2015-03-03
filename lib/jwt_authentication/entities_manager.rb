require 'jwt_authentication/entity'

module JwtAuthentication
  class EntitiesManager
    def find_or_create_entity(model)
      @entities ||= {}
      @entities[model] ||= Entity.new(model.to_s.classify.constantize)
    end
  end
end
