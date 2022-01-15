require "validator/email_validator"

class User < ApplicationRecord
    include TokenGenerateService
    
    before_validation :downcase_email

    has_secure_password

    validates :name, presence: true,
               length: {
                    maximum: 30, 
                    allow_blank: true 
                }
    # 追加
  VALID_PASSWORD_REGEX = /\A[\w\-]+\z/
    validates :password, presence: true,
                       length: { 
                        minimum: 8,
                        allow_blank: true},
                       format: {
                         with: VALID_PASSWORD_REGEX ,
                         message: :invalid_password ,
                         allow_blank: true
                       },
                       allow_nil: true
    validates :email, presence: true,
                       email: { allow_blank: true }

    ## methods
    # class method  ###########################
    class << self
        # emailからアクティブなユーザーを返す
        def find_activated(email)
            find_by(email: email, activated: true)
        end
    end
    # class method end #########################

    # 自分以外の同じemailのアクティブなユーザーがいる場合にtrueを返す
    def email_activated?
        users = User.where.not(id: id)
        users.find_activated(email).present?
    end

    def remember(jti)
      update!(refresh_jti: jti)
    end

    def response_json(payload = {})
      as_json(only: [:id, :name]).merge(payload).with_indifferent_access
    end

    def forget
      update!(refresh_jti: nil)
    end

    private

    # email小文字化
    def downcase_email
      self.email.downcase! if email
    end
end
