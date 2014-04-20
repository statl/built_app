class User < ActiveRecord::Base
  has_many :workouts, dependent: :destroy
  has_secure_password
  before_save { email.downcase! }
  before_save { nickname.downcase! }
  before_create :create_remember_token
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(?:\.[a-z\d\-]+)*\.[a-z]+\z/i
  VALID_NICKNAME_REGEX = /[a-z\d\-\_\+]{4,}/i
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 6 }
  validates :nickname, presence: true, format: { with: VALID_NICKNAME_REGEX },
                       uniqueness: { case_sensitive: false },
					   length: { minimum: 4, maximum: 50 }
  
  def User.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def User.digest(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  def feed
    Workout.where("user_id = ?", id)
  end

  
  private

    def create_remember_token
      self.remember_token = User.digest(User.new_remember_token)
    end
end
