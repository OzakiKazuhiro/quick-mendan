# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

puts "🌱 シードデータの作成を開始します..."

# 校舎データの作成
puts "📍 校舎データを作成中..."
campus_mikunigaoka = Campus.find_or_create_by!(name: "三国ヶ丘本部校")
campus_izumigaoka = Campus.find_or_create_by!(name: "泉ヶ丘駅前校")
campus_kishiwada = Campus.find_or_create_by!(name: "岸和田校")
campus_otori = Campus.find_or_create_by!(name: "鳳駅前校")

puts "✅ 校舎データ作成完了: #{Campus.count}校舎"

# 講師データの作成（管理者も講師として作成）
puts "👨‍🏫 講師データを作成中..."

# 管理者権限を持つ講師
admin_teacher = Teacher.find_or_create_by!(user_login_name: "admin_test") do |t|
  t.name = "テスト管理者"
  t.email = "admin@example.com"
  t.password = "password123"
  t.password_confirmation = "password123"
  t.role = :admin
end

teacher1 = Teacher.find_or_create_by!(user_login_name: "shibaguchi") do |t|
  t.name = "柴口太郎先生"
  t.email = "shibaguchi@example.com"
  t.password = "okkrskz-shibaguchi"
  t.password_confirmation = "okkrskz-shibaguchi"
  t.notification_email = "shibaguchi@example.com"
  t.notification_time = "09:00"
  t.role = :teacher
end

teacher2 = Teacher.find_or_create_by!(user_login_name: "tanaka_a") do |t|
  t.name = "田中花子先生"
  t.email = "tanaka@example.com"
  t.password = "okkrskz-tanaka"
  t.password_confirmation = "okkrskz-tanaka"
  t.role = :teacher
end

puts "✅ 講師データ作成完了: #{Teacher.count}名"
puts "  - #{admin_teacher.name} (ログイン名: #{admin_teacher.user_login_name}) ※管理者"
puts "  - #{teacher1.name} (ログイン名: #{teacher1.user_login_name})"
puts "  - #{teacher2.name} (ログイン名: #{teacher2.user_login_name})"

# 生徒データの作成
puts "👨‍🎓 生徒データを作成中..."
student1 = Student.find_or_create_by!(student_number: "2024001") do |s|
  s.name = "山田太郎"
  s.grade = "高校2年"
  s.school_name = "大阪府立○○高等学校"
  s.campus = campus_mikunigaoka
  s.password = "9999"
  s.password_confirmation = "9999"
end

student2 = Student.find_or_create_by!(student_number: "2024002") do |s|
  s.name = "佐藤花子"
  s.grade = "高校1年"
  s.school_name = "私立△△高等学校"
  s.campus = campus_izumigaoka
  s.password = "9999"
  s.password_confirmation = "9999"
end

student3 = Student.find_or_create_by!(student_number: "2024003") do |s|
  s.name = "鈴木次郎"
  s.grade = "高校3年"
  s.school_name = "府立□□高等学校"
  s.campus = campus_kishiwada
  s.password = "9999"
  s.password_confirmation = "9999"
end

puts "✅ 生徒データ作成完了: #{Student.count}名"
puts "  - #{student1.name} (生徒番号: #{student1.student_number}, 校舎: #{student1.campus&.name})"
puts "  - #{student2.name} (生徒番号: #{student2.student_number}, 校舎: #{student2.campus&.name})"
puts "  - #{student3.name} (生徒番号: #{student3.student_number}, 校舎: #{student3.campus&.name})"

puts ""
puts "🎉 シードデータの作成が完了しました！"
puts ""
puts "=== ログイン情報 ==="
puts "【管理者】"
puts "  ログイン名: admin_test"
puts "  パスワード: password123"
puts ""
puts "【講師】"
puts "  ログイン名: shibaguchi / パスワード: okkrskz-shibaguchi"
puts "  ログイン名: tanaka_a / パスワード: okkrskz-tanaka"
puts ""
puts "【生徒】"
puts "  生徒番号: 2024001 / パスワード: 9999"
puts "  生徒番号: 2024002 / パスワード: 9999"
puts "  生徒番号: 2024003 / パスワード: 9999"
puts "==================="
