FactoryBot.define do
  factory :appointment do
    association :student
    association :time_slot
    notes { "面談についてのメモ" }
    
    # メモありのtrait
    trait :with_notes do
      notes { "重要な面談内容について話し合う予定です。" }
    end
    
    # メモなしのtrait
    trait :without_notes do
      notes { nil }
    end
  end
end
