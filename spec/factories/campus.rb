FactoryBot.define do
  factory :campus do
    sequence(:name) { |n| "テスト校舎#{n}" }

    # 実際の校舎名のtrait
    trait :mikunigaoka do
      name { "三国ヶ丘本部校" }
    end

    trait :izumigaoka do
      name { "泉ヶ丘駅前校" }
    end

    trait :kishiwada do
      name { "岸和田校" }
    end

    trait :otori do
      name { "鳳駅前校" }
    end

    # 重複する名前のtrait（バリデーションテスト用）
    trait :duplicate_name do
      name { "重複テスト校舎" }
    end

    # 生徒付きのtrait（多対多対応）
    trait :with_students do
      after(:create) do |campus|
        students = create_list(:student, 3)
        students.each { |student| student.campuses << campus }
      end
    end
    
    # 特定数の生徒付きのtrait
    trait :with_specific_student_count do
      transient do
        student_count { 2 }
      end
      
      after(:create) do |campus, evaluator|
        students = create_list(:student, evaluator.student_count)
        students.each { |student| student.campuses << campus }
      end
    end
    
    # 既存の生徒を関連付けるtrait
    trait :with_existing_students do
      transient do
        students { [] }
      end
      
      after(:create) do |campus, evaluator|
        evaluator.students.each { |student| student.campuses << campus }
      end
    end
  end
end
