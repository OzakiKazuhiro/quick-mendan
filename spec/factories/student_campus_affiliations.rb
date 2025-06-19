FactoryBot.define do
  factory :student_campus_affiliation do
    # 関連データは毎回新規作成
    association :student
    association :campus
    
    # 特定の生徒と校舎を指定するtrait
    trait :with_specific_data do
      transient do
        specific_student { nil }
        specific_campus { nil }
      end
      
      student { specific_student || association(:student) }
      campus { specific_campus || association(:campus) }
    end
    
    # 実際の校舎名を使用するtrait
    trait :mikunigaoka_affiliation do
      association :student
      association :campus, :mikunigaoka
    end
    
    trait :izumigaoka_affiliation do
      association :student
      association :campus, :izumigaoka
    end
    
    trait :kishiwada_affiliation do
      association :student
      association :campus, :kishiwada
    end
    
    trait :otori_affiliation do
      association :student
      association :campus, :otori
    end
  end
end
