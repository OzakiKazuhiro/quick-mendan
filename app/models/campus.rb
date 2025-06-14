class Campus < ApplicationRecord
  # バリデーション
  validates :name, presence: true, uniqueness: true
  
  # 関連付け
  has_many :students, dependent: :nullify
  
  # スコープ
  scope :ordered, -> { order(:name) }
end
