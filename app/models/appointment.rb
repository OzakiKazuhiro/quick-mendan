class Appointment < ApplicationRecord
  belongs_to :student
  belongs_to :time_slot

  # バリデーション
  validates :student_id, presence: true
  validates :time_slot_id, presence: true, uniqueness: true

  # 予約可能かどうかチェック
  validate :time_slot_must_be_bookable, on: :create
  validate :cancellation_deadline_check, on: :destroy

  # スコープ
  scope :by_student, ->(student) { where(student: student) }
  scope :by_time_slot, ->(time_slot) { where(time_slot: time_slot) }
  scope :upcoming, -> { joins(:time_slot).where('time_slots.date >= ?', Date.current).order('time_slots.date, time_slots.start_time') }
  scope :past, -> { joins(:time_slot).where('time_slots.date < ?', Date.current).order('time_slots.date DESC, time_slots.start_time DESC') }

  # コールバック - 予約作成時にTimeSlotのステータスを更新
  after_create :mark_time_slot_as_booked
  before_destroy :check_cancellation_deadline
  after_destroy :mark_time_slot_as_available

  # 予約の日時情報を取得
  def appointment_datetime
    return nil unless time_slot
    
    DateTime.new(
      time_slot.date.year,
      time_slot.date.month,
      time_slot.date.day,
      time_slot.start_time.hour,
      time_slot.start_time.min
    )
  end

  # 予約の表示用文字列
  def appointment_display
    return "予約情報なし" unless time_slot&.teacher
    
    "#{time_slot.teacher.name}先生 #{time_slot.date.strftime('%m/%d')} #{time_slot.start_time.strftime('%H:%M')}"
  end

  # キャンセル可能かどうか
  def cancellable?
    return false unless time_slot&.date
    
    # 前日の22:15まで
    deadline = (time_slot.date - 1.day).end_of_day.change(hour: 22, min: 15)
    Time.current <= deadline
  end

  # 変更可能かどうか
  def modifiable?
    cancellable? # キャンセル可能な条件と同じ
  end

  private

  def time_slot_must_be_bookable
    return unless time_slot
    
    unless time_slot.bookable?
      errors.add(:time_slot, "選択された時間枠は予約できません")
    end
  end

  def cancellation_deadline_check
    unless cancellable?
      errors.add(:base, "予約変更・キャンセルの締切時間を過ぎています（前日22:15まで）")
      throw :abort
    end
  end

  def check_cancellation_deadline
    cancellation_deadline_check
  end

  def mark_time_slot_as_booked
    time_slot.update!(status: :booked) if time_slot.available?
  end

  def mark_time_slot_as_available
    time_slot.update!(status: :available) if time_slot.booked?
  end
end
