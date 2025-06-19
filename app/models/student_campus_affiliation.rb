class StudentCampusAffiliation < ApplicationRecord
  # ===================================================================
  # 生徒と校舎の多対多リレーション用中間テーブルモデル
  # 
  # 【役割】
  # - 1人の生徒が複数の校舎に所属可能
  # - 1つの校舎に複数の生徒が所属可能
  # - 生徒と校舎の関連を管理する中間テーブル
  # 
  # 【使用例】
  # - 生徒が転校舎した場合の履歴管理
  # - 複数校舎で授業を受ける生徒の管理
  # - 校舎別の生徒数集計等
  # ===================================================================
  
  # 関連付け
  belongs_to :student  # 生徒への参照（必須）
  belongs_to :campus   # 校舎への参照（必須）
  
  # バリデーション
  # データベースレベルでユニーク制約があるが、アプリケーションレベルでも追加
  validates :student_id, uniqueness: { scope: :campus_id, 
                                       message: "この生徒は既にこの校舎に所属しています" }
  
  # スコープ（よく使う検索条件）
  scope :by_campus, ->(campus) { where(campus: campus) }
  scope :by_student, ->(student) { where(student: student) }
  scope :recent, -> { order(created_at: :desc) }
  
  # インスタンスメソッド
  def affiliation_info
    "#{student.name} - #{campus.name}"
  end
end
