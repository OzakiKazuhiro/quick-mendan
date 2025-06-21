class Student < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable
  
  # ===================================================================
  # 関連付け（多対多リレーション）
  # 【変更内容】1対多 → 多対多に変更
  # - 以前: belongs_to :campus（1人の生徒は1つの校舎のみ）
  # - 現在: has_many :through（1人の生徒は複数の校舎に所属可能）
  # ===================================================================
  
  # 中間テーブルとの関連（直接的な関連）
  has_many :student_campus_affiliations, dependent: :destroy
  
  # 校舎との関連（中間テーブル経由の間接的な関連）
  has_many :campuses, through: :student_campus_affiliations, source: :campus
  
  # 予約との関連
  has_many :appointments, dependent: :destroy
  has_many :time_slots, through: :appointments
  
  # 後方互換性のためのメソッド（単数形のcampus）
  def campus
    campuses.first
  end
  
  # campus_idsメソッドを追加（フォーム用）
  def campus_ids
    campuses.pluck(:id)
  end
  
  def campus_ids=(ids)
    self.campus_ids_will_change! if respond_to?(:campus_ids_will_change!)
    ids = ids.reject(&:blank?) if ids.is_a?(Array)
    self.campuses = Campus.where(id: ids)
  end
  
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
  
  # ===================================================================
  # 多対多リレーション用の便利メソッド
  # ===================================================================
  
  # 所属校舎名を取得（複数校舎対応）
  def campus_names
    campuses.pluck(:name).join(", ")
  end
  
  # メイン校舎名を取得（最初に登録された校舎または指定された校舎）
  def primary_campus_name
    campuses.first&.name || "未設定"
  end
  
  # 特定の校舎に所属しているかチェック
  def belongs_to_campus?(campus)
    campuses.include?(campus)
  end
  
  # 校舎を追加
  def add_campus(campus)
    campuses << campus unless belongs_to_campus?(campus)
  end
  
  # 校舎から除外
  def remove_campus(campus)
    campuses.delete(campus)
  end
  
  # 後方互換性のため：既存コードで使用されている可能性があるメソッドを残す
  def campus_name
    primary_campus_name
  end
end
