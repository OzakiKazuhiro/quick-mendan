class Admin < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  # バリデーション
  validates :user_login_name, presence: true, uniqueness: true, 
            format: { with: /\A[a-zA-Z0-9_]+\z/, message: "英数字とアンダースコアのみ使用可能です" }
  validates :name, presence: true
  validates :email, uniqueness: true, allow_blank: true
  
  # Deviseでユーザー名認証を使用するための設定
  def email_required?
    false
  end
  
  def email_changed?
    false
  end
  
  def will_save_change_to_email?
    false
  end
  
  # ユーザー名でログインするための設定
  def self.find_for_database_authentication(login_conditions)
    search_conditions = login_conditions.dup
    if (username_input = search_conditions.delete(:email))
      where(search_conditions.to_h).where(["user_login_name = :username", { username: username_input }]).first
    elsif search_conditions.has_key?(:user_login_name)
      where(search_conditions.to_h).first
    end
  end
end
