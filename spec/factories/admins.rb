FactoryBot.define do
  factory :admin do
    sequence(:user_login_name) { |n| "admin#{n}" }
    sequence(:name) { |n| "管理者#{n}" }
    sequence(:email) { |n| "admin#{n}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }

    # 有効なadminのtrait
    trait :valid do
      user_login_name { "valid_admin" }
      name { "有効な管理者" }
      email { "valid@example.com" }
    end

    # メールアドレスなしのtrait
    trait :without_email do
      email { nil }
    end

    # 無効なログイン名のtrait
    trait :invalid_login_name do
      user_login_name { "invalid-login!" }
    end
  end
end
