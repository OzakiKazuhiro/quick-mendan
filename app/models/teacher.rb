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
    # warden_conditions = {email: "shibaguti"}
    conditions = warden_conditions.dup
     # conditions = {email: "shibaguti"}  (複製)
    if (email = conditions.delete(:email))
        # conditions.delete(:email) の動作：
        # 1. conditions から :email キーを削除
        # 2. 削除されたキーの値を返す
        # 実行前: conditions = {email: "shibaguti"}
        # 実行後: conditions = {}  (空のハッシュ)
        # 戻り値:   email = "shibaguti"
        # email = "shibaguti" なので、条件は true
      where(user_login_name: email).first
    else
      # emailキー以外の場合はnilを返す
      nil
    end
  end
  
  # リマインダーメールが設定されているかチェック
  def reminder_enabled?
    email.present? && notification_time.present?
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
