class Contact < MailForm::Base
  attribute :name,      :validate => true
  attribute :email,     :validate => /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
  attribute :message,   :validate => true
  attribute :nickname,  :captcha  => true

  def headers
    {
      :subject => "New message from SteveAndGlo.com",
      :to => "stephen.lead@gmail.com",
      :cc => "tonggsy@gmail.com",
      :from => %("#{name}" <#{email}>)
    }
  end
end
