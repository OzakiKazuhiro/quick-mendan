class TimeSlot < ApplicationRecord
  belongs_to :teacher
  belongs_to :campus

  # ステータスの定義
  enum :status, {
    available: 0,    # 予約可能
    booked: 1,       # 予約済み
    unavailable: 2   # 利用不可
  }

  # バリデーション
  validates :date, presence: true
  validates :start_time, presence: true
  validates :status, presence: true
  validates :teacher_id, uniqueness: { 
    scope: [:date, :start_time], 
    message: "同じ日時に複数の面談枠を設定することはできません" 
  }

  # 過去の日付は設定不可
  validate :date_cannot_be_in_the_past

  # 営業時間内のバリデーション（14:00-22:00）
  validate :start_time_within_business_hours

  # 10分刻みのバリデーション
  validate :start_time_must_be_ten_minute_intervals

  # スコープ
  scope :by_teacher, ->(teacher) { where(teacher: teacher) }
  scope :by_campus, ->(campus) { where(campus: campus) }
  scope :by_date, ->(date) { where(date: date) }
  scope :by_week, ->(start_date) { where(date: start_date..(start_date + 6.days)) }
  scope :ordered, -> { order(:date, :start_time) }

  # 週の面談枠を取得
  def self.for_week(teacher, start_date, campus = nil)
    scope = by_teacher(teacher).by_week(start_date).ordered
    scope = scope.by_campus(campus) if campus
    scope
  end

  # 時間枠の表示用文字列
  def time_display
    start_time.strftime('%H:%M')
  end

  # 日時の表示用文字列
  def datetime_display
    "#{date.strftime('%m/%d')} #{time_display}"
  end

  # 予約可能かどうか
  def bookable?
    available? && date >= Date.current
  end

  private

  def date_cannot_be_in_the_past
    return unless date.present?
    
    if date < Date.current
      errors.add(:date, "過去の日付は設定できません")
    end
  end

  def start_time_within_business_hours
    return unless start_time.present?
    
    business_start = Time.parse('14:00')
    business_end = Time.parse('22:00')
    
    if start_time < business_start || start_time >= business_end
      errors.add(:start_time, "営業時間内（14:00-22:00）で設定してください")
    end
  end

  def start_time_must_be_ten_minute_intervals
    return unless start_time.present?
    
    minutes = start_time.min
    unless minutes % 10 == 0
      errors.add(:start_time, "10分刻みで設定してください")
    end
  end
end
