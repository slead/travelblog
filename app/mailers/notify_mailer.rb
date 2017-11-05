class NotifyMailer < ActionMailer::Base
  default from: "no-reply@IgniteTalks.io"

    def new_video_email(user, video)
      @user = user
      @video = video
      mail(to: @user.email, subject: 'New video added to IgniteTalks.io')
    end

    def new_user_email(user)
      @user = user
      mail(to: @user.email, subject: 'Welcome to IgniteTalks.io')
    end

end
