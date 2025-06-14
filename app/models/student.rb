class Student < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  # 関連付け
  belongs_to :campus, optional: true
  # has_many :appointments, dependent: :destroy（将来的に追加予定）
  
  # バリデーション
  validates :student_number, presence: true, uniqueness: true,
            format: { with: /\A[a-zA-Z0-9]+\z/, message: "英数字のみ使用可能です" }
  validates :name, presence: true
  
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
  
  # 生徒番号でログインするための設定
  def self.find_for_database_authentication(login_conditions)
    search_conditions = login_conditions.dup
    if (student_number_input = search_conditions.delete(:email))
      where(search_conditions.to_h).where(["student_number = :student_number", { student_number: student_number_input }]).first
    elsif search_conditions.has_key?(:student_number)
      where(search_conditions.to_h).first
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
