FactoryBot.define do
  factory :interview_record do
    association :appointment
    content { "面談内容のテストデータです。生徒の学習状況や進路について話し合いました。" }
    
    trait :detailed do
      content { "詳細な面談記録です。生徒の成績向上について具体的な対策を話し合い、次回までの学習計画を立てました。保護者との連携も重要だと感じました。" }
    end
    
    trait :short do
      content { "簡潔な面談記録です。" }
    end
    
    trait :long do
      content { "非常に詳細な面談記録です。" + "詳細な内容が続きます。" * 50 }
    end
  end
end
