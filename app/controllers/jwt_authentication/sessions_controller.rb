class JwtAuthentication::SessionsController < Devise::SessionsController
  include JwtAuthentication::Concerns::JwtControllerHelpers

  def create
    self.resource = warden.authenticate!({ scope: resource_name, recall: "#{controller_path}#new" })
    sign_in(resource_name, resource)
    yield resource if block_given?
    render json: { auth_token: resource.jwt_token(sign_in_params[:remember_me]) }
  end

  def destroy
    unless all_signed_out?
      Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
      yield if block_given?
    end
    render json: { status: json_status(true) }
  end

  def destroy_all
    current_entity = send(:"current_#{resource_name}")
    current_entity.regenerate_authentication_token! if current_entity
  end
end
