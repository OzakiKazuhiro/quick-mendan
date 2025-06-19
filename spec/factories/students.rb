FactoryBot.define do
  factory :student do
    sequence(:student_number) { |n| "2024#{n.to_s.rjust(3, '0')}" }
    sequence(:name) { |n| "生徒#{n}" }
    password { "9999" }
    password_confirmation { "9999" }
    grade { "高校1年" }
    school_name { "テスト高校" }
    # NOTE: 多対多リレーションのため、campus属性は削除

    # 有効なstudentのtrait
    trait :valid do
      student_number { "2024001" }
      name { "有効な生徒" }
    end

    # 単一校舎に所属するtrait（多対多対応）
    trait :with_campus do
      after(:create) do |student|
        campus = create(:campus)
        student.campuses << campus
      end
    end

    # 複数校舎に所属するtrait（多対多リレーションの利点を活用）
    trait :with_multiple_campuses do
      after(:create) do |student|
        campus1 = create(:campus, name: "校舎A")
        campus2 = create(:campus, name: "校舎B")
        student.campuses << [campus1, campus2]
      end
    end

    # 特定の校舎を指定するtrait
    trait :with_specific_campus do
      transient do
        campus { nil }
      end
      
      after(:create) do |student, evaluator|
        if evaluator.campus
          student.campuses << evaluator.campus
        end
      end
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
