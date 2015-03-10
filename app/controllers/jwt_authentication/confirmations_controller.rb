class JwtAuthentication::ConfirmationsController < Devise::ConfirmationsController
  include JwtAuthentication::Concerns::JwtControllerHelpers

  def create
    self.resource = resource_class.send_confirmation_instructions(resource_params)
    yield resource if block_given?
    render json: { status: json_status(true) }
  end

  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])
    yield resource if block_given?
    if resource.errors.empty?
      render json: { auth_token: resource.jwt_token }
    else
      render json: { errors: resource.errors }
    end
  end
end
