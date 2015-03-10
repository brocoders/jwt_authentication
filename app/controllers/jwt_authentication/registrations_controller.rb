class JwtAuthentication::RegistrationsController < Devise::RegistrationsController
  include JwtAuthentication::Concerns::JwtControllerHelpers

  def create
    build_resource(sign_up_params)
    resource_saved = resource.save
    yield resource if block_given?
    if resource_saved
      if resource.active_for_authentication?
        sign_in(resource_name, resource, store: false)
        render json: {
            auth_token: resource.jwt_token,
            resource_name => resource
        }
        return
      else
        expire_data_after_sign_in!
      end
    end
    render_resource_or_errors(resource)
  end

  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    resource_updated = update_resource(resource, account_update_params)
    yield resource if block_given?
    if resource_updated
      sign_in resource_name, resource, bypass: true
    end
    render_resource_or_errors(resource)
  end

  def destroy
    resource.destroy
    Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
    yield resource if block_given?
    render nothing: true, status: json_status(resource.destroyed?)
  end
end
