puts "🌱 シードデータの作成を開始します..."
puts "📝 担当講師機能対応版のテストデータを作成します"

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
  t.name = "柴口太郎"
  t.email = "shibaguchi@quick-mendan.com"
  t.password = "password-shibaguchi"
  t.password_confirmation = "password-shibaguchi"
  t.notification_time = "09:00"
  t.role = :teacher
end

teacher2 = Teacher.find_or_create_by!(user_login_name: "tanaka_a") do |t|
  t.name = "田中花子"
  t.email = "tanaka@quick-mendan.com"
  t.password = "password-tanaka"
  t.password_confirmation = "password-tanaka"
  t.notification_time = "18:00"
  t.role = :teacher
end

teacher3 = Teacher.find_or_create_by!(user_login_name: "yamamoto") do |t|
  t.name = "山本次郎"
  t.email = "yamamoto@quick-mendan.com"
  t.password = "password-yamamoto"
  t.password_confirmation = "password-yamamoto"
  t.role = :teacher
end

teacher4 = Teacher.find_or_create_by!(user_login_name: "watanabe") do |t|
  t.name = "渡辺美咲"
  t.email = "watanabe@quick-mendan.com"
  t.password = "password-watanabe"
  t.password_confirmation = "password-watanabe"
  t.role = :teacher
end

puts "✅ 講師データ作成完了: #{Teacher.count}名"
puts "  - #{teacher1.name} (ログイン名: #{teacher1.user_login_name})"
puts "  - #{teacher2.name} (ログイン名: #{teacher2.user_login_name})"
puts "  - #{teacher3.name} (ログイン名: #{teacher3.user_login_name})"
puts "  - #{teacher4.name} (ログイン名: #{teacher4.user_login_name})"

# ===================================================================
# 生徒データの作成（多対多リレーション + 担当講師対応）
# ===================================================================
puts "\n👨‍🎓 生徒データを作成中..."

# 三国ヶ丘本部校の生徒（柴口先生担当）
student1 = Student.find_or_initialize_by(student_number: "2024001")
student1.assign_attributes(
  name: "山田太郎",
  grade: "高校2年",
  school_name: "泉陽高校",
  password: "9999",
  password_confirmation: "9999",
  assigned_teacher: teacher1  # 柴口先生担当
)
student1.save!

student2 = Student.find_or_initialize_by(student_number: "2024002")
student2.assign_attributes(
  name: "田中花子",
  grade: "高校1年",
  school_name: "清教学園高校",
  password: "9999",
  password_confirmation: "9999",
  assigned_teacher: teacher1  # 柴口先生担当
)
student2.save!

# 泉ヶ丘駅前校の生徒（田中先生担当）
student3 = Student.find_or_initialize_by(student_number: "2024003")
student3.assign_attributes(
  name: "佐藤次郎",
  grade: "高校3年",
  school_name: "鳳高校",
  password: "9999",
  password_confirmation: "9999",
  assigned_teacher: teacher2  # 田中先生担当
)
student3.save!

student4 = Student.find_or_initialize_by(student_number: "2024004")
student4.assign_attributes(
  name: "鈴木美咲",
  grade: "高校2年",
  school_name: "三国丘高校",
  password: "9999",
  password_confirmation: "9999",
  assigned_teacher: teacher2  # 田中先生担当
)
student4.save!

# 岸和田校の生徒（山本先生担当）
student5 = Student.find_or_initialize_by(student_number: "2024005")
student5.assign_attributes(
  name: "高橋健太",
  grade: "高校3年",
  school_name: "天王寺高校",
  password: "9999",
  password_confirmation: "9999",
  assigned_teacher: teacher3  # 山本先生担当
)
student5.save!

student6 = Student.find_or_initialize_by(student_number: "2024006")
student6.assign_attributes(
  name: "伊藤さくら",
  grade: "高校1年",
  school_name: "四天王寺高校",
  password: "9999",
  password_confirmation: "9999",
  assigned_teacher: teacher3  # 山本先生担当
)
student6.save!

# 鳳駅前校の生徒（渡辺先生担当）
student7 = Student.find_or_initialize_by(student_number: "2024007")
student7.assign_attributes(
  name: "渡辺大輔",
  grade: "高校2年",
  school_name: "近大泉州高校",
  password: "9999",
  password_confirmation: "9999",
  assigned_teacher: teacher4  # 渡辺先生担当
)
student7.save!

# 複数校舎に所属する生徒（担当講師なし）
student8 = Student.find_or_initialize_by(student_number: "2024008")
student8.assign_attributes(
  name: "中村優子",
  grade: "高校3年",
  school_name: "登美丘高校",
  password: "9999",
  password_confirmation: "9999",
  assigned_teacher: nil  # 担当講師なし
)
student8.save!

# 担当講師なしの生徒（追加）
student9 = Student.find_or_initialize_by(student_number: "2024009")
student9.assign_attributes(
  name: "小林正人",
  grade: "高校1年",
  school_name: "関西大倉高校",
  password: "9999",
  password_confirmation: "9999",
  assigned_teacher: nil  # 担当講師なし
)
student9.save!

student10 = Student.find_or_initialize_by(student_number: "2024010")
student10.assign_attributes(
  name: "松本彩乃",
  grade: "高校3年",
  school_name: "大阪女学院高校",
  password: "9999",
  password_confirmation: "9999",
  assigned_teacher: teacher1  # 柴口先生担当（複数生徒担当の例）
)
student10.save!

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
unless student10.campuses.include?(campus_mikunigaoka)
  student10.campuses << campus_mikunigaoka
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
unless student9.campuses.include?(campus_otori)
  student9.campuses << campus_otori
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
puts "\n🎉 担当講師機能対応版シードデータの作成が完了しました！"
puts ""
puts "=== 作成されたデータ ==="
puts "📍 校舎: #{Campus.count}件"
Campus.all.each do |campus|
  puts "  - #{campus.name} (生徒数: #{campus.student_count}名)"
end

puts "\n👨‍🏫 講師: #{Teacher.count}名"
Teacher.all.each do |teacher|
  role_text = teacher.role == "admin" ? " ※管理者" : ""
  assigned_count = teacher.assigned_students.count
  assigned_text = assigned_count > 0 ? " (担当生徒: #{assigned_count}名)" : ""
  puts "  - #{teacher.name} (#{teacher.user_login_name})#{role_text}#{assigned_text}"
end

puts "\n👨‍🎓 生徒: #{Student.count}名"
Student.all.each do |student|
  campus_info = student.campuses.any? ? student.campus_names : "未所属"
  teacher_info = student.assigned_teacher ? student.assigned_teacher.name + "先生" : "担当なし"
  puts "  - #{student.name} (#{student.student_number}) - 校舎: #{campus_info} - 担当: #{teacher_info}"
end

puts "\n🔗 生徒-校舎関連: #{StudentCampusAffiliation.count}件"

puts "\n📊 担当講師別生徒数:"
Teacher.all.each do |teacher|
  count = teacher.assigned_students.count
  puts "  - #{teacher.name}先生: #{count}名"
end

puts ""
puts "=== ログイン情報 ==="
puts "【管理者】"
puts "  ログイン名: admin_master"
puts "  パスワード: AdminPass2024!"
puts ""
puts "【講師】"
puts "  ログイン名: shibaguchi / パスワード: password-shibaguchi (担当生徒: 3名)"
puts "  ログイン名: tanaka_a / パスワード: password-tanaka (担当生徒: 2名)"
puts "  ログイン名: yamamoto / パスワード: password-yamamoto (担当生徒: 2名)"
puts "  ログイン名: watanabe / パスワード: password-watanabe (担当生徒: 1名)"
puts ""
puts "【生徒】"
puts "  すべての生徒のパスワード: 9999"
puts "  生徒番号: 2024001〜2024010"
puts "  担当講師ありの生徒: 8名"
puts "  担当講師なしの生徒: 2名"
puts "==================="
