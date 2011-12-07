# coding: utf-8 
class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def provides_callback
    logger.info "login succeed, create auth"
    omniauth = request.env["omniauth.auth"] 
    user = User.where("authentications.provider" => omniauth['provider'], "authentications.uid" => omniauth['uid']).first

    if user
      logger.info "user #{user.name} signed in"
      flash[:notice] = t("devise.sessions.signed_in")
      sign_in_and_redirect(:user, user)

    elsif current_user
      logger.info "current user #{current_user.name} bind with provider: #{omniauth['provider']} #{omniauth['uid']}"
      current_user.bind_service(omniauth['provider'], omniauth['uid'])
      flash[:notice] = t("devise.omniauth_callbacks.success", :kind => omniauth['provider'])
      redirect_to authentications_url

    elsif user = User.new_from_provider_data(omniauth)
      logger.info "new user #{user.name} signed up with provider: #{omniauth['provider']} #{omniauth['uid']}"
      flash[:notice] = t("devise.registrations.signed_up")
      sign_in_and_redirect(:user, user)

    else
      logger.warn "failed create user: omniauth = #{omniauth}"
      flash[:alert] = t(:fail)
      redirect_to new_user_registration_url   
    end
  end

  # This is solution for existing accout want bind Google login but current_user is always nil
  # https://github.com/intridea/omniauth/issues/185
  def handle_unverified_request
    true
  end


end