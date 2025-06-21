class InterviewRecord < ApplicationRecord
  belongs_to :appointment
  
  # バリデーション
  validates :content, presence: true, length: { minimum: 10, maximum: 2000 }
  validates :appointment_id, uniqueness: true
  
  # 作成者情報（講師）を取得
  def teacher
    appointment.time_slot.teacher
  end
  
  # 生徒情報を取得
  def student
    appointment.student
  end
  
  # 面談日時を取得
  def interview_datetime
    appointment.appointment_datetime
  end
end
