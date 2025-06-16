class Student < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable
  
  # 関連付け
  belongs_to :campus, optional: true
  # has_many :appointments, dependent: :destroy（将来的に追加予定）
  
  # バリデーション
  validates :student_number, presence: true, uniqueness: true,
            format: { with: /\A[a-zA-Z0-9]+\z/, message: "英数字のみ使用可能です" }
  validates :name, presence: true
  
  # カスタムパスワードバリデーション（生徒用の9999パスワードのため4文字以上）
  validates :password, length: { minimum: 4 }, confirmation: true, if: :password_required?
  
  # Deviseで生徒番号認証を使用するための設定
  def email_required?
    false
  end
  
  def email_changed?
    false
  end
  
  def will_save_change_to_email?
    false
  end
  
  # パスワードバリデーション用メソッド
  def password_required?
    !persisted? || !password.nil? || !password_confirmation.nil?
  end
  
  # emailメソッドをstudent_numberのエイリアスとして定義
  def email
    student_number
  end
  
  def email=(value)
    self.student_number = value
  end
  
  # 生徒番号でログインするための設定
  def self.find_for_database_authentication(login_conditions)
    # login_conditions = {email: "2024001"}
    search_conditions = login_conditions.dup
    # search_conditions = {email: "2024001"}  (複製)
    if (student_number_input = search_conditions.delete(:email))
      # search_conditions.delete(:email) の動作：
      # 1. search_conditions から :email キーを削除
      # 2. 削除されたキーの値を返す
      # 実行前: search_conditions = {email: "2024001"}
      # 実行後: search_conditions = {}  (空のハッシュ)
      # 戻り値:   student_number_input = "2024001"
      # student_number_input = "2024001" なので、条件は true
      where(["student_number = :student_number", { student_number: student_number_input }]).first
    else
      # emailキー以外の場合はnilを返す
      nil
    end
  end
  
  # パスワードを9999に固定するためのメソッド
  def self.create_with_default_password(attributes)
    student = new(attributes)
    student.password = "9999"
    student.password_confirmation = "9999"
    student.save
    student
  end
  
  # 校舎名を取得（校舎が設定されていない場合は"未設定"を返す）
  def campus_name
    campus&.name || "未設定"
  end
end
