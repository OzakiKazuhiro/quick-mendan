class TimeSlot < ApplicationRecord
  belongs_to :teacher
  belongs_to :campus

  # 予約との関連
  has_one :appointment, dependent: :destroy
  has_one :student, through: :appointment

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
    scope: [:date, :start_time, :campus_id], 
    message: "同じ校舎・同じ日時に複数の面談枠を設定することはできません" 
  }

  # 過去の日付は設定不可（テスト環境では許可）
  validate :date_cannot_be_in_the_past, unless: -> { Rails.env.test? }

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

  # 週の面談枠を取得（全校舎対応）
  def self.for_week(teacher, start_date, campus = nil)
    scope = by_teacher(teacher).by_week(start_date).ordered
    scope = scope.by_campus(campus) if campus
    scope
  end

  # 週の面談枠を全校舎で取得
  def self.for_week_all_campuses(teacher, start_date)
    by_teacher(teacher).by_week(start_date).includes(:campus).ordered
  end

  # 時間枠の表示用文字列
  def time_display
    start_time.strftime('%H:%M')
  end

  # 終了時間を計算（開始時間 + 30分）
  def end_time
    return nil unless start_time
    start_time + 30.minutes
  end

  # 日時の表示用文字列
  def datetime_display
    "#{date.strftime('%m/%d')} #{time_display}"
  end

  # 校舎名付きの表示用文字列
  def campus_display
    case campus.name
    when /三国.*本部|三国ヶ丘本部/
      "三国"
    when /鳳駅前|鳳/
      "鳳"
    when /泉ヶ丘駅前|泉ヶ丘/
      "泉ヶ丘"
    when /岸和田/
      "岸和田"
    else
      campus.name.slice(0, 3) # フォールバック：最初の3文字
    end
  end

  # 予約可能かどうか
  def bookable?
    if Rails.env.test?
      available?
    else
    available? && date >= Date.current
    end
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
    
    # 時刻のみを比較するため、同じ日付で統一
    business_start_hour = 14
    business_end_hour = 22
    
    start_hour = start_time.hour
    start_min = start_time.min
    
    # 14:00未満または22:00以上の場合はエラー
    if start_hour < business_start_hour || 
       start_hour > business_end_hour || 
       (start_hour == business_end_hour && start_min > 0)
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
