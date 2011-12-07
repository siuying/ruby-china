# coding: utf-8  
class User
  module OmniauthCallbacks    
    def new_from_provider_data(provider, uid, data)
      user = User.new
      user.email = data["email"] unless data["email"].blank?

      user.login = data["nickname"]
      user.login = data["name"] if provider == "google"
      user.login.gsub!(/[^\w]/, "_")

      if User.where(:login => user.login).count > 0 || user.login.blank?
        old_login = user.login
        new_login = "u#{Time.now.to_i}"
        user.login = new_login
        logger.warn "duplicated user login: #{old_login}, use #{new_login} instead"        
      end
      
      user.password = Devise.friendly_token[0, 20]
      user.location = data["location"]
      user.tagline = data["description"]
      user.bind_service(provider, uid)

      return user
    end
  end
end