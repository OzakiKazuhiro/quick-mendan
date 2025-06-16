FactoryBot.define do
  factory :time_slot do
    teacher { nil }
    campus { nil }
    date { "2025-06-16" }
    start_time { "2025-06-16 09:17:52" }
    status { 1 }
  end
end
