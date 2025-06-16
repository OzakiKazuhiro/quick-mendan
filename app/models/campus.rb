class Campus < ApplicationRecord
  # バリデーション
  validates :name, presence: true, uniqueness: true
  
  # 関連付け
  has_many :students, dependent: :nullify
  has_many :time_slots, dependent: :destroy
  
  # スコープ
  scope :ordered, -> { order(:name) }
end
