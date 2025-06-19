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
puts "📝 多対多リレーション対応版のテストデータを作成します"

# ===================================================================
# 校舎データの作成
# ===================================================================
puts "\n📍 校舎データを作成中..."
campus_mikunigaoka = Campus.find_or_create_by!(name: "三国ヶ丘本部校")
campus_izumigaoka = Campus.find_or_create_by!(name: "泉ヶ丘駅前校")
campus_kishiwada = Campus.find_or_create_by!(name: "岸和田校")
campus_otori = Campus.find_or_create_by!(name: "鳳駅前校")

puts "✅ 校舎データ作成完了: #{Campus.count}校舎"
puts "  - #{campus_mikunigaoka.name}"
puts "  - #{campus_izumigaoka.name}"
puts "  - #{campus_kishiwada.name}"
puts "  - #{campus_otori.name}"

# ===================================================================
# 管理者データの作成（Adminモデルがある場合は使用、なければTeacherで管理者権限）
# ===================================================================
puts "\n👑 管理者データを作成中..."

# 管理者権限を持つ講師として作成
admin_teacher = Teacher.find_or_create_by!(user_login_name: "admin_master") do |t|
  t.name = "システム管理者"
  t.email = "admin@quick-mendan.com"
  t.password = "AdminPass2024!"
  t.password_confirmation = "AdminPass2024!"
  t.notification_time = "09:00"
  t.role = :admin
end

puts "✅ 管理者データ作成完了"
puts "  - #{admin_teacher.name} (ログイン名: #{admin_teacher.user_login_name}) ※管理者"

# ===================================================================
# 講師データの作成
# ===================================================================
puts "\n👨‍🏫 講師データを作成中..."

teacher1 = Teacher.find_or_create_by!(user_login_name: "shibaguchi") do |t|
  t.name = "柴口太郎先生"
  t.email = "shibaguchi@quick-mendan.com"
  t.password = "okkrskz-shibaguchi"
  t.password_confirmation = "okkrskz-shibaguchi"
  t.notification_time = "09:00"
  t.role = :teacher
end

teacher2 = Teacher.find_or_create_by!(user_login_name: "tanaka_a") do |t|
  t.name = "田中花子先生"
  t.email = "tanaka@quick-mendan.com"
  t.password = "okkrskz-tanaka"
  t.password_confirmation = "okkrskz-tanaka"
  t.notification_time = "18:00"
  t.role = :teacher
end

teacher3 = Teacher.find_or_create_by!(user_login_name: "yamamoto") do |t|
  t.name = "山本次郎先生"
  t.email = "yamamoto@quick-mendan.com"
  t.password = "okkrskz-yamamoto"
  t.password_confirmation = "okkrskz-yamamoto"
  t.role = :teacher
end

teacher4 = Teacher.find_or_create_by!(user_login_name: "watanabe") do |t|
  t.name = "渡辺美咲先生"
  t.email = "watanabe@quick-mendan.com"
  t.password = "okkrskz-watanabe"
  t.password_confirmation = "okkrskz-watanabe"
  t.role = :teacher
end

puts "✅ 講師データ作成完了: #{Teacher.count}名"
puts "  - #{teacher1.name} (ログイン名: #{teacher1.user_login_name})"
puts "  - #{teacher2.name} (ログイン名: #{teacher2.user_login_name})"
puts "  - #{teacher3.name} (ログイン名: #{teacher3.user_login_name})"
puts "  - #{teacher4.name} (ログイン名: #{teacher4.user_login_name})"

# ===================================================================
# 生徒データの作成（多対多リレーション対応）
# ===================================================================
puts "\n👨‍🎓 生徒データを作成中..."

# 三国ヶ丘本部校の生徒
student1 = Student.find_or_create_by!(student_number: "2024001") do |s|
  s.name = "山田太郎"
  s.grade = "高校2年"
  s.school_name = "大阪府立○○高等学校"
  s.password = "9999"
  s.password_confirmation = "9999"
end

student2 = Student.find_or_create_by!(student_number: "2024002") do |s|
  s.name = "田中花子"
  s.grade = "高校1年"
  s.school_name = "私立△△高等学校"
  s.password = "9999"
  s.password_confirmation = "9999"
end

# 泉ヶ丘駅前校の生徒
student3 = Student.find_or_create_by!(student_number: "2024003") do |s|
  s.name = "佐藤次郎"
  s.grade = "高校3年"
  s.school_name = "府立□□高等学校"
  s.password = "9999"
  s.password_confirmation = "9999"
end

student4 = Student.find_or_create_by!(student_number: "2024004") do |s|
  s.name = "鈴木美咲"
  s.grade = "高校2年"
  s.school_name = "私立◇◇高等学校"
  s.password = "9999"
  s.password_confirmation = "9999"
end

# 岸和田校の生徒
student5 = Student.find_or_create_by!(student_number: "2024005") do |s|
  s.name = "高橋健太"
  s.grade = "高校3年"
  s.school_name = "府立▽▽高等学校"
  s.password = "9999"
  s.password_confirmation = "9999"
end

student6 = Student.find_or_create_by!(student_number: "2024006") do |s|
  s.name = "伊藤さくら"
  s.grade = "高校1年"
  s.school_name = "私立◎◎高等学校"
  s.password = "9999"
  s.password_confirmation = "9999"
end

# 鳳駅前校の生徒
student7 = Student.find_or_create_by!(student_number: "2024007") do |s|
  s.name = "渡辺大輔"
  s.grade = "高校2年"
  s.school_name = "府立※※高等学校"
  s.password = "9999"
  s.password_confirmation = "9999"
end

# 複数校舎に所属する生徒（多対多の利点を活用）
student8 = Student.find_or_create_by!(student_number: "2024008") do |s|
  s.name = "中村優子"
  s.grade = "高校3年"
  s.school_name = "私立☆☆高等学校"
  s.password = "9999"
  s.password_confirmation = "9999"
end

puts "✅ 生徒アカウント作成完了: #{Student.count}名"

# ===================================================================
# 生徒と校舎の関連付け（多対多リレーション）
# ===================================================================
puts "\n🔗 生徒と校舎の関連付けを作成中..."

# 各校舎に生徒を配置
unless student1.campuses.include?(campus_mikunigaoka)
  student1.campuses << campus_mikunigaoka
end
unless student2.campuses.include?(campus_mikunigaoka)
  student2.campuses << campus_mikunigaoka
end

unless student3.campuses.include?(campus_izumigaoka)
  student3.campuses << campus_izumigaoka
end
unless student4.campuses.include?(campus_izumigaoka)
  student4.campuses << campus_izumigaoka
end

unless student5.campuses.include?(campus_kishiwada)
  student5.campuses << campus_kishiwada
end
unless student6.campuses.include?(campus_kishiwada)
  student6.campuses << campus_kishiwada
end

unless student7.campuses.include?(campus_otori)
  student7.campuses << campus_otori
end

# 複数校舎に所属する生徒の例（多対多の利点）
unless student8.campuses.include?(campus_mikunigaoka)
  student8.campuses << campus_mikunigaoka
end
unless student8.campuses.include?(campus_izumigaoka)
  student8.campuses << campus_izumigaoka
end

puts "✅ 生徒と校舎の関連付け完了: #{StudentCampusAffiliation.count}件"

# ===================================================================
# 結果表示
# ===================================================================
puts "\n🎉 シードデータの作成が完了しました！"
puts ""
puts "=== 作成されたデータ ==="
puts "📍 校舎: #{Campus.count}件"
Campus.all.each do |campus|
  puts "  - #{campus.name} (生徒数: #{campus.student_count}名)"
end

puts "\n👨‍🏫 講師: #{Teacher.count}名"
Teacher.all.each do |teacher|
  role_text = teacher.role == "admin" ? " ※管理者" : ""
  puts "  - #{teacher.name} (#{teacher.user_login_name})#{role_text}"
end

puts "\n👨‍🎓 生徒: #{Student.count}名"
Student.all.each do |student|
  campus_info = student.campuses.any? ? student.campus_names : "未所属"
  puts "  - #{student.name} (#{student.student_number}) - 校舎: #{campus_info}"
end

puts "\n🔗 生徒-校舎関連: #{StudentCampusAffiliation.count}件"

puts ""
puts "=== ログイン情報 ==="
puts "【管理者】"
puts "  ログイン名: admin_master"
puts "  パスワード: AdminPass2024!"
puts ""
puts "【講師】"
puts "  ログイン名: shibaguchi / パスワード: okkrskz-shibaguchi"
puts "  ログイン名: tanaka_a / パスワード: okkrskz-tanaka"
puts "  ログイン名: yamamoto / パスワード: okkrskz-yamamoto"
puts "  ログイン名: watanabe / パスワード: okkrskz-watanabe"
puts ""
puts "【生徒】"
puts "  すべての生徒のパスワード: 9999"
puts "  生徒番号: 2024001〜2024008"
puts "==================="
