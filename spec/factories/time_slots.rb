FactoryBot.define do
  factory :time_slot do
    association :teacher
    association :campus
    date { Date.tomorrow }  # 明日の日付（過去の日付エラー回避）
    start_time { Time.parse("15:00") }  # 営業時間内（14:00-22:00）、10分刻み
    status { 0 }  # デフォルトステータス（available）
    
    # 異なる時間のtrait
    trait :morning do
      start_time { Time.parse("14:00") }  # 営業開始時間
    end
    
    trait :afternoon do
      start_time { Time.parse("16:30") }  # 午後の時間
    end
    
    trait :evening do
      start_time { Time.parse("20:00") }  # 夜の時間
    end
    
    # 予約済みのtrait
    trait :booked do
      status { 1 }
    end
    
    # 特定の日付を指定するtrait
    trait :next_week do
      date { 1.week.from_now.to_date }
    end
  end
end
