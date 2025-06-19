class Campus < ApplicationRecord
  # ===================================================================
  # 校舎モデル
  # 
  # 【役割】
  # - 各校舎の情報管理
  # - 生徒との多対多リレーション
  # - 面談枠（time_slots）との関連
  # ===================================================================
  
  # バリデーション
  validates :name, presence: true, uniqueness: true
  
  # ===================================================================
  # 関連付け（多対多リレーション対応）
  # 【変更内容】1対多 → 多対多に変更
  # - 以前: has_many :students（1つの校舎に複数の生徒、生徒は1校舎のみ）
  # - 現在: has_many :through（1つの校舎に複数の生徒、生徒は複数校舎可能）
  # ===================================================================
  
  # 中間テーブルとの関連（直接的な関連）
  has_many :student_campus_affiliations, dependent: :destroy
  
  # 生徒との関連（中間テーブル経由の間接的な関連）
  has_many :students, through: :student_campus_affiliations, source: :student
  
  # 面談枠との関連（1対多のまま）
  has_many :time_slots, dependent: :destroy
  
  # スコープ（よく使う検索条件）
  scope :ordered, -> { order(:name) }
  scope :with_students, -> { joins(:students).distinct }
  scope :with_time_slots, -> { joins(:time_slots).distinct }
  
  # ===================================================================
  # 多対多リレーション用の便利メソッド
  # ===================================================================
  
  # この校舎に所属する生徒数
  def student_count
    students.count
  end
  
  # この校舎に所属する生徒の名前一覧
  def student_names
    students.pluck(:name)
  end
  
  # 特定の生徒がこの校舎に所属しているかチェック
  def has_student?(student)
    students.include?(student)
  end
  
  # 生徒をこの校舎に追加
  def add_student(student)
    students << student unless has_student?(student)
  end
  
  # 生徒をこの校舎から除外
  def remove_student(student)
    students.delete(student)
  end
  
  # この校舎での面談枠数
  def time_slot_count
    time_slots.count
  end
  
  # 校舎の基本情報を文字列で返す
  def info
    "#{name} (生徒数: #{student_count}名, 面談枠: #{time_slot_count}件)"
  end
end
