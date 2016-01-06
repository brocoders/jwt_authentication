class JwtAuthentication::ConfirmationsController < Devise::ConfirmationsController
  include JwtAuthentication::Concerns::JwtControllerHelpers

  def create
    self.resource = resource_class.send_confirmation_instructions(resource_params)
    yield resource if block_given?
    render nothing: true, status: json_status(true)
  end

  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])
    yield resource if block_given?
    if resource.errors.empty?
      token, expires = resource.jwt_token_and_expires
      send(:"set_jwt_cookie_for_#{resource_name}", token, expires)
      render json: { auth_token: token }
    else
      render_errors resource.errors
    end
  end
end
