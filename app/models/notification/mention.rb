class Notification::Mention < Notification::Base
  belongs_to :reply
  
  after_create :publish_pusher_notification
  def publish_pusher_notification
    data = {
      :reply => {:login => reply.user.login, :email => reply.user.email, :body => reply.body, :created_at => reply.created_at}, 
      :unread => user.notifications.unread.count
    }
    Pusher["user_#{user_id}"].trigger('mention', data)
  end
end
