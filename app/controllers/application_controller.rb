# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  # ✅ Permit additional Devise parameters
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  # Allow extra fields for sign up and account update
  def configure_permitted_parameters
    # Permit parameters for sign up
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username, :email, :avatar])

    # Permit parameters for account update
    devise_parameter_sanitizer.permit(:account_update, keys: [:username, :email, :avatar, :bio])
  end

  # ✅ Redirect users after login
  def after_sign_in_path_for(resource)
    # Only admins go to admin dashboard
    resource.admin? ? admin_dashboard_path : feed_path
  end

  # Redirect users after sign up
  def after_sign_up_path_for(resource)
    feed_path
  end
end
