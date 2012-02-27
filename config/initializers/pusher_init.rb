require 'pusher'

pusher_config = YAML.load_file("#{Rails.root}/config/pusher.yml")[Rails.env] rescue nil
if pusher_config
  Pusher.app_id = pusher_config["app_id"]
  Pusher.key    = pusher_config["key"]
  Pusher.secret = pusher_config["secret"]

else
  STDERR.puts "Pusher config (#{Rails.root}/config/pusher.yml) for environment (#{Rails.env}) not found, pusher not loaded"

end