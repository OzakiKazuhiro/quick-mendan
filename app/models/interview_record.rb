class InterviewRecord < ApplicationRecord
  belongs_to :appointment
  
  # Delegateメソッド
  has_one :student, through: :appointment
  has_one :time_slot, through: :appointment
  has_one :teacher, through: :time_slot
  
  # バリデーション
  validates :content, presence: true, length: { minimum: 10, maximum: 2000 }
  validates :appointment_id, uniqueness: true
  
  # スコープ
  scope :recent, -> { where('created_at >= ?', 1.month.ago).order(created_at: :desc) }
  scope :by_teacher, ->(teacher) { joins(appointment: { time_slot: :teacher }).where(teachers: { id: teacher.id }) }
  scope :by_student, ->(student) { joins(:appointment).where(appointments: { student_id: student.id }) }
  
  # 面談日を取得
  def interview_date
    appointment.time_slot.date
  end
  
  # 面談時間を取得
  def interview_time
    appointment.time_slot.start_time
  end
  
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
