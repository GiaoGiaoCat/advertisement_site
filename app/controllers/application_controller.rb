class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :authenticate_user!
  # before_filter :customer_user
  before_filter :configure_permitted_parameters, if: :devise_controller?

  def after_sign_in_path_for(resource)
    # request.env['omniauth.origin'] || stored_location_for(resource) || root_path
    stored_location_for(resource) || manage_welcome_path
  end

  # CanCan Exception Handling.
  # https://github.com/ryanb/cancan/wiki/exception-handling
  rescue_from CanCan::AccessDenied do |exception|
    render file: "#{Rails.root}/public/403", formats: [:html], status: 403, layout: false
  end

  protected
  # Strong Params(lazy way) of rails4 and devise.
  # https://github.com/yelinaung/StrongParams_example
  # other way: https://gist.github.com/apeacox/5245821
  # def customer_user
  #   if  user_signed_in?
  #     if current_user.role?(:admin) && current_user.id != 1
  #         sign_out_and_redirect(:user)
  #     end
  #   end
  # end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:email, :password, :password_confirmation) }
  end
end
