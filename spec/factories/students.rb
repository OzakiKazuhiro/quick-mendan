FactoryBot.define do
  factory :student do
    sequence(:student_number) { |n| "2024#{n.to_s.rjust(3, '0')}" }
    sequence(:name) { |n| "生徒#{n}" }
    password { "9999" }
    password_confirmation { "9999" }
    grade { "高校1年" }
    school_name { "テスト高校" }
    campus { nil }

    # 有効なstudentのtrait
    trait :valid do
      student_number { "2024001" }
      name { "有効な生徒" }
    end

    # 校舎ありのtrait
    trait :with_campus do
      association :campus
    end

    # 詳細情報ありのtrait
    trait :with_details do
      grade { "高校2年" }
      school_name { "サンプル高等学校" }
    end

    # 無効な生徒番号のtrait
    trait :invalid_student_number do
      student_number { "invalid-number!" }
    end

    # 英数字のみの生徒番号のtrait
    trait :alphanumeric_student_number do
      student_number { "ABC123" }
    end
  end
end
