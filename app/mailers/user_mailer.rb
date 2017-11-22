class UserMailer < ApplicationMailer
  def account_activation user
    @user = user
    mail to: user.email, subject: t("mailer.subject")
  end

  def password_reset
    @greeting = t "mailer.greeting"
    mail to: "to@example.org"
  end
end
