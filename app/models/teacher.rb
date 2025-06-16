class Teacher < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  # 役割の定義
  enum :role, { teacher: 0, admin: 1 }
  
  # 関連付け（将来的に面談枠や予約との関連付けを追加予定）
  has_many :time_slots, dependent: :destroy
  # has_many :appointments, through: :time_slots
  
  # バリデーション
  validates :user_login_name, presence: true, uniqueness: true,
            format: { with: /\A[a-zA-Z0-9_]+\z/, message: "英数字とアンダースコアのみ使用可能です" }
  validates :name, presence: true
  validates :email, uniqueness: true, allow_blank: true
  validates :notification_email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :role, presence: true
  
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
  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if (email = conditions.delete(:email))
      # emailキーで渡された値をuser_login_nameで検索
      where(user_login_name: email).first
    elsif (login = conditions.delete(:user_login_name))
      # user_login_nameキーで直接検索
      where(user_login_name: login).first
    else
      # その他の条件で検索
      where(conditions.to_h).first
    end
  end
  
  # リマインダーメールが設定されているかチェック
  def reminder_enabled?
    notification_email.present? && notification_time.present?
  end
  
  # 管理者権限チェック
  def admin?
    role == 'admin'
  end
  
  # 講師権限チェック（管理者も講師として機能）
  def can_teach?
    true  # 全てのTeacherレコードは講師として機能可能
  end
end
