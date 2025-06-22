FactoryBot.define do
  factory :teacher do
    sequence(:user_login_name) { |n| "teacher#{n}" }
    sequence(:name) { |n| "講師#{n}" }
    sequence(:email) { |n| "teacher#{n}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }
    notification_time { nil }

    # 有効なteacherのtrait
    trait :valid do
      user_login_name { "valid_teacher" }
      name { "有効な講師" }
      email { "valid_teacher@example.com" }
    end

    # 担当生徒ありのtrait
    trait :with_assigned_students do
      after(:create) do |teacher|
        create_list(:student, 3, assigned_teacher: teacher)
      end
    end

    # 特定の担当生徒数を設定するtrait
    trait :with_students do
      transient do
        students_count { 2 }
      end

      after(:create) do |teacher, evaluator|
        create_list(:student, evaluator.students_count, assigned_teacher: teacher)
      end
    end

    # 担当生徒なしのtrait（明示的）
    trait :without_assigned_students do
      # デフォルトの状態（何もしない）
    end

    # メールアドレスなしのtrait
    trait :without_email do
      email { nil }
    end

    # リマインダー設定ありのtrait
    trait :with_reminder do
      email { "reminder@example.com" }
      notification_time { "09:00" }
    end

    # リマインダー部分設定のtrait（メールのみ）
    trait :partial_reminder do
      email { "partial@example.com" }
      notification_time { nil }
    end

    # 無効なログイン名のtrait
    trait :invalid_login_name do
      user_login_name { "invalid-login!" }
    end

    # 無効なメールアドレスのtrait
    trait :invalid_email do
      email { "invalid-email" }
    end
  end
end
