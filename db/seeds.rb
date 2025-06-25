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
  t.notification_time = "18:00"  # 14:00-22:00の1時間刻み
  t.role = :admin
end

# 副管理者も作成
sub_admin = Teacher.find_or_create_by!(user_login_name: "admin_sub") do |t|
  t.name = "副管理者 山田"
  t.email = "sub-admin@quick-mendan.com"
  t.password = "SubAdmin2024!"
  t.password_confirmation = "SubAdmin2024!"
  t.notification_time = "19:00"  # 14:00-22:00の1時間刻み
  t.role = :admin
end

puts "✅ 管理者データ作成完了"
puts "  - #{admin_teacher.name} (ログイン名: #{admin_teacher.user_login_name}) ※管理者"
puts "  - #{sub_admin.name} (ログイン名: #{sub_admin.user_login_name}) ※副管理者"

# ===================================================================
# 講師データの作成（リアルなテストデータ）
# ===================================================================
puts "\n👨‍🏫 講師データを作成中..."

# 三国ヶ丘本部校の講師陣
teacher1 = Teacher.find_or_create_by!(user_login_name: "shibaguchi") do |t|
  t.name = "柴口太郎"
  t.email = "shibaguchi@quick-mendan.com"
  t.password = "password-shibaguchi"
  t.password_confirmation = "password-shibaguchi"
  t.notification_time = "14:00"  # 14:00-22:00の1時間刻み
  t.role = :teacher
end

teacher2 = Teacher.find_or_create_by!(user_login_name: "tanaka_hanako") do |t|
  t.name = "田中花子"
  t.email = "tanaka.h@quick-mendan.com"
  t.password = "password-tanaka"
  t.password_confirmation = "password-tanaka"
  t.notification_time = "18:00"  # 14:00-22:00の1時間刻み
  t.role = :teacher
end

teacher3 = Teacher.find_or_create_by!(user_login_name: "yamamoto_jiro") do |t|
  t.name = "山本次郎"
  t.email = "yamamoto@quick-mendan.com"
  t.password = "password-yamamoto"
  t.password_confirmation = "password-yamamoto"
  t.notification_time = "17:00"  # 14:00-22:00の1時間刻み
  t.role = :teacher
end

teacher4 = Teacher.find_or_create_by!(user_login_name: "suzuki_mai") do |t|
  t.name = "鈴木舞"
  t.email = "suzuki.mai@quick-mendan.com"
  t.password = "password-suzuki"
  t.password_confirmation = "password-suzuki"
  t.notification_time = "19:00"  # 14:00-22:00の1時間刻み
  t.role = :teacher
end

teacher5 = Teacher.find_or_create_by!(user_login_name: "watanabe_ken") do |t|
  t.name = "渡辺健"
  t.email = "watanabe.k@quick-mendan.com"
  t.password = "password-watanabe"
  t.password_confirmation = "password-watanabe"
  t.notification_time = "15:00"  # 14:00-22:00の1時間刻み
  t.role = :teacher
end

# 泉ヶ丘駅前校の講師陣
teacher6 = Teacher.find_or_create_by!(user_login_name: "sato_yuki") do |t|
  t.name = "佐藤雪"
  t.email = "sato.yuki@quick-mendan.com"
  t.password = "password-sato"
  t.password_confirmation = "password-sato"
  t.notification_time = "16:00"  # 14:00-22:00の1時間刻み
  t.role = :teacher
end

teacher7 = Teacher.find_or_create_by!(user_login_name: "takahashi_m") do |t|
  t.name = "高橋誠"
  t.email = "takahashi@quick-mendan.com"
  t.password = "password-takahashi"
  t.password_confirmation = "password-takahashi"
  t.notification_time = "20:00"  # 14:00-22:00の1時間刻み
  t.role = :teacher
end

teacher8 = Teacher.find_or_create_by!(user_login_name: "ito_sakura") do |t|
  t.name = "伊藤さくら"
  t.email = "ito.sakura@quick-mendan.com"
  t.password = "password-ito"
  t.password_confirmation = "password-ito"
  t.notification_time = "17:00"  # 14:00-22:00の1時間刻み
  t.role = :teacher
end

teacher9 = Teacher.find_or_create_by!(user_login_name: "kobayashi_ryu") do |t|
  t.name = "小林龍"
  t.email = "kobayashi@quick-mendan.com"
  t.password = "password-kobayashi"
  t.password_confirmation = "password-kobayashi"
  t.notification_time = "21:00"  # 14:00-22:00の1時間刻み
  t.role = :teacher
end

# 岸和田校の講師陣
teacher10 = Teacher.find_or_create_by!(user_login_name: "matsuda_ai") do |t|
  t.name = "松田愛"
  t.email = "matsuda@quick-mendan.com"
  t.password = "password-matsuda"
  t.password_confirmation = "password-matsuda"
  t.notification_time = "14:00"  # 14:00-22:00の1時間刻み
  t.role = :teacher
end

teacher11 = Teacher.find_or_create_by!(user_login_name: "nakamura_taro") do |t|
  t.name = "中村太郎"
  t.email = "nakamura@quick-mendan.com"
  t.password = "password-nakamura"
  t.password_confirmation = "password-nakamura"
  t.notification_time = "18:00"  # 14:00-22:00の1時間刻み
  t.role = :teacher
end

teacher12 = Teacher.find_or_create_by!(user_login_name: "hayashi_yuka") do |t|
  t.name = "林由香"
  t.email = "hayashi@quick-mendan.com"
  t.password = "password-hayashi"
  t.password_confirmation = "password-hayashi"
  t.notification_time = "16:00"  # 14:00-22:00の1時間刻み
  t.role = :teacher
end

teacher13 = Teacher.find_or_create_by!(user_login_name: "mori_shin") do |t|
  t.name = "森真"
  t.email = "mori@quick-mendan.com"
  t.password = "password-mori"
  t.password_confirmation = "password-mori"
  t.notification_time = "19:00"  # 14:00-22:00の1時間刻み
  t.role = :teacher
end

# 鳳駅前校の講師陣
teacher14 = Teacher.find_or_create_by!(user_login_name: "kimura_emi") do |t|
  t.name = "木村恵美"
  t.email = "kimura@quick-mendan.com"
  t.password = "password-kimura"
  t.password_confirmation = "password-kimura"
  t.notification_time = "15:00"  # 14:00-22:00の1時間刻み
  t.role = :teacher
end

teacher15 = Teacher.find_or_create_by!(user_login_name: "yoshida_kenta") do |t|
  t.name = "吉田健太"
  t.email = "yoshida@quick-mendan.com"
  t.password = "password-yoshida"
  t.password_confirmation = "password-yoshida"
  t.notification_time = "22:00"  # 14:00-22:00の1時間刻み
  t.role = :teacher
end

teacher16 = Teacher.find_or_create_by!(user_login_name: "ishii_nao") do |t|
  t.name = "石井直"
  t.email = "ishii@quick-mendan.com"
  t.password = "password-ishii"
  t.password_confirmation = "password-ishii"
  t.notification_time = "17:00"  # 14:00-22:00の1時間刻み
  t.role = :teacher
end

# 複数校舎対応講師（ベテラン講師）
teacher17 = Teacher.find_or_create_by!(user_login_name: "okamoto_sensei") do |t|
  t.name = "岡本浩二"
  t.email = "okamoto@quick-mendan.com"
  t.password = "password-okamoto"
  t.password_confirmation = "password-okamoto"
  t.notification_time = "20:00"  # 14:00-22:00の1時間刻み
  t.role = :teacher
end

teacher18 = Teacher.find_or_create_by!(user_login_name: "fujita_mari") do |t|
  t.name = "藤田真理"
  t.email = "fujita@quick-mendan.com"
  t.password = "password-fujita"
  t.password_confirmation = "password-fujita"
  t.notification_time = "14:00"  # 14:00-22:00の1時間刻み
  t.role = :teacher
end

# メール通知なしの講師例
teacher19 = Teacher.find_or_create_by!(user_login_name: "noguchi_yuto") do |t|
  t.name = "野口勇人"
  t.email = nil  # メールアドレス設定なし
  t.password = "password-noguchi"
  t.password_confirmation = "password-noguchi"
  t.notification_time = nil  # 通知時刻設定なし
  t.role = :teacher
end

teacher20 = Teacher.find_or_create_by!(user_login_name: "hashimoto_rei") do |t|
  t.name = "橋本玲"
  t.email = "hashimoto@quick-mendan.com"
  t.password = "password-hashimoto"
  t.password_confirmation = "password-hashimoto"
  t.notification_time = "21:00"  # 14:00-22:00の1時間刻み
  t.role = :teacher
end

puts "✅ 講師データ作成完了: #{Teacher.count}名"

# 校舎別講師一覧を表示
puts "\n📍 校舎別講師配置:"
puts "【三国ヶ丘本部校】"
puts "  - #{teacher1.name} (#{teacher1.user_login_name})"
puts "  - #{teacher2.name} (#{teacher2.user_login_name})"
puts "  - #{teacher3.name} (#{teacher3.user_login_name})"
puts "  - #{teacher4.name} (#{teacher4.user_login_name})"
puts "  - #{teacher5.name} (#{teacher5.user_login_name})"

puts "【泉ヶ丘駅前校】"
puts "  - #{teacher6.name} (#{teacher6.user_login_name})"
puts "  - #{teacher7.name} (#{teacher7.user_login_name})"
puts "  - #{teacher8.name} (#{teacher8.user_login_name})"
puts "  - #{teacher9.name} (#{teacher9.user_login_name})"

puts "【岸和田校】"
puts "  - #{teacher10.name} (#{teacher10.user_login_name})"
puts "  - #{teacher11.name} (#{teacher11.user_login_name})"
puts "  - #{teacher12.name} (#{teacher12.user_login_name})"
puts "  - #{teacher13.name} (#{teacher13.user_login_name})"

puts "【鳳駅前校】"
puts "  - #{teacher14.name} (#{teacher14.user_login_name})"
puts "  - #{teacher15.name} (#{teacher15.user_login_name})"
puts "  - #{teacher16.name} (#{teacher16.user_login_name})"

puts "【複数校舎対応】"
puts "  - #{teacher17.name} (#{teacher17.user_login_name})"
puts "  - #{teacher18.name} (#{teacher18.user_login_name})"
puts "  - #{teacher19.name} (#{teacher19.user_login_name}) ※メール通知なし"
puts "  - #{teacher20.name} (#{teacher20.user_login_name})"

# ===================================================================
# 生徒データの作成（多対多リレーション + 担当講師対応）
# ===================================================================
puts "\n👨‍🎓 生徒データを作成中..."

# 三国ヶ丘本部校の生徒
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
  assigned_teacher: teacher2  # 田中花子先生担当
)
student2.save!

student3 = Student.find_or_initialize_by(student_number: "2024003")
student3.assign_attributes(
  name: "佐藤次郎",
  grade: "高校3年",
  school_name: "三国丘高校",
  password: "9999",
  password_confirmation: "9999",
  assigned_teacher: teacher3  # 山本先生担当
)
student3.save!

student4 = Student.find_or_initialize_by(student_number: "2024004")
student4.assign_attributes(
  name: "鈴木美咲",
  grade: "高校2年",
  school_name: "帝塚山学院高校",
  password: "9999",
  password_confirmation: "9999",
  assigned_teacher: teacher4  # 鈴木舞先生担当
)
student4.save!

student5 = Student.find_or_initialize_by(student_number: "2024005")
student5.assign_attributes(
  name: "高橋健太",
  grade: "高校3年",
  school_name: "住吉高校",
  password: "9999",
  password_confirmation: "9999",
  assigned_teacher: teacher5  # 渡辺健先生担当
)
student5.save!

# 泉ヶ丘駅前校の生徒
student6 = Student.find_or_initialize_by(student_number: "2024006")
student6.assign_attributes(
  name: "伊藤さくら",
  grade: "高校1年",
  school_name: "鳳高校",
  password: "9999",
  password_confirmation: "9999",
  assigned_teacher: teacher6  # 佐藤雪先生担当
)
student6.save!

student7 = Student.find_or_initialize_by(student_number: "2024007")
student7.assign_attributes(
  name: "渡辺大輔",
  grade: "高校2年",
  school_name: "和泉高校",
  password: "9999",
  password_confirmation: "9999",
  assigned_teacher: teacher7  # 高橋誠先生担当
)
student7.save!

student8 = Student.find_or_initialize_by(student_number: "2024008")
student8.assign_attributes(
  name: "中村優子",
  grade: "高校3年",
  school_name: "登美丘高校",
  password: "9999",
  password_confirmation: "9999",
  assigned_teacher: teacher8  # 伊藤さくら先生担当
)
student8.save!

student9 = Student.find_or_initialize_by(student_number: "2024009")
student9.assign_attributes(
  name: "小林正人",
  grade: "高校1年",
  school_name: "関西大倉高校",
  password: "9999",
  password_confirmation: "9999",
  assigned_teacher: teacher9  # 小林龍先生担当
)
student9.save!

# 岸和田校の生徒
student10 = Student.find_or_initialize_by(student_number: "2024010")
student10.assign_attributes(
  name: "松本彩乃",
  grade: "高校3年",
  school_name: "岸和田高校",
  password: "9999",
  password_confirmation: "9999",
  assigned_teacher: teacher10  # 松田愛先生担当
)
student10.save!

student11 = Student.find_or_initialize_by(student_number: "2024011")
student11.assign_attributes(
  name: "青木翔太",
  grade: "高校2年",
  school_name: "和泉大宮高校",
  password: "9999",
  password_confirmation: "9999",
  assigned_teacher: teacher11  # 中村太郎先生担当
)
student11.save!

student12 = Student.find_or_initialize_by(student_number: "2024012")
student12.assign_attributes(
  name: "森川美穂",
  grade: "高校1年",
  school_name: "久米田高校",
  password: "9999",
  password_confirmation: "9999",
  assigned_teacher: teacher12  # 林由香先生担当
)
student12.save!

student13 = Student.find_or_initialize_by(student_number: "2024013")
student13.assign_attributes(
  name: "大西一郎",
  grade: "高校3年",
  school_name: "貝塚南高校",
  password: "9999",
  password_confirmation: "9999",
  assigned_teacher: teacher13  # 森真先生担当
)
student13.save!

# 鳳駅前校の生徒
student14 = Student.find_or_initialize_by(student_number: "2024014")
student14.assign_attributes(
  name: "加藤恵",
  grade: "高校2年",
  school_name: "泉大津高校",
  password: "9999",
  password_confirmation: "9999",
  assigned_teacher: teacher14  # 木村恵美先生担当
)
student14.save!

student15 = Student.find_or_initialize_by(student_number: "2024015")
student15.assign_attributes(
  name: "西村拓也",
  grade: "高校1年",
  school_name: "高石高校",
  password: "9999",
  password_confirmation: "9999",
  assigned_teacher: teacher15  # 吉田健太先生担当
)
student15.save!

student16 = Student.find_or_initialize_by(student_number: "2024016")
student16.assign_attributes(
  name: "平田麻衣",
  grade: "高校3年",
  school_name: "信太高校",
  password: "9999",
  password_confirmation: "9999",
  assigned_teacher: teacher16  # 石井直先生担当
)
student16.save!

# 複数校舎対応講師の担当生徒
student17 = Student.find_or_initialize_by(student_number: "2024017")
student17.assign_attributes(
  name: "竹内悠太",
  grade: "高校2年",
  school_name: "天王寺高校",
  password: "9999",
  password_confirmation: "9999",
  assigned_teacher: teacher17  # 岡本浩二先生担当
)
student17.save!

student18 = Student.find_or_initialize_by(student_number: "2024018")
student18.assign_attributes(
  name: "長谷川愛美",
  grade: "高校1年",
  school_name: "四天王寺高校",
  password: "9999",
  password_confirmation: "9999",
  assigned_teacher: teacher18  # 藤田真理先生担当
)
student18.save!

# 担当講師なしの生徒（転校予定・検討中など）
student19 = Student.find_or_initialize_by(student_number: "2024019")
student19.assign_attributes(
  name: "池田直人",
  grade: "高校3年",
  school_name: "近大泉州高校",
  password: "9999",
  password_confirmation: "9999",
  assigned_teacher: nil  # 担当講師なし
)
student19.save!

student20 = Student.find_or_initialize_by(student_number: "2024020")
student20.assign_attributes(
  name: "荒木菜々子",
  grade: "高校2年",
  school_name: "大阪女学院高校",
  password: "9999",
  password_confirmation: "9999",
  assigned_teacher: nil  # 担当講師なし
)
student20.save!

# 複数生徒を担当する講師の例（人気講師）
student21 = Student.find_or_initialize_by(student_number: "2024021")
student21.assign_attributes(
  name: "藤原智也",
  grade: "高校1年",
  school_name: "三国丘高校",
  password: "9999",
  password_confirmation: "9999",
  assigned_teacher: teacher1  # 柴口先生（複数生徒担当）
)
student21.save!

student22 = Student.find_or_initialize_by(student_number: "2024022")
student22.assign_attributes(
  name: "村上咲良",
  grade: "高校3年",
  school_name: "清教学園高校",
  password: "9999",
  password_confirmation: "9999",
  assigned_teacher: teacher2  # 田中花子先生（複数生徒担当）
)
student22.save!

puts "✅ 生徒アカウント作成完了: #{Student.count}名"

# ===================================================================
# 生徒と校舎の関連付け（多対多リレーション）
# ===================================================================
puts "\n🔗 生徒と校舎の関連付けを作成中..."

# 三国ヶ丘本部校の生徒を配置
unless student1.campuses.include?(campus_mikunigaoka)
  student1.campuses << campus_mikunigaoka
end
unless student2.campuses.include?(campus_mikunigaoka)
  student2.campuses << campus_mikunigaoka
end
unless student3.campuses.include?(campus_mikunigaoka)
  student3.campuses << campus_mikunigaoka
end
unless student4.campuses.include?(campus_mikunigaoka)
  student4.campuses << campus_mikunigaoka
end
unless student5.campuses.include?(campus_mikunigaoka)
  student5.campuses << campus_mikunigaoka
end
unless student21.campuses.include?(campus_mikunigaoka)
  student21.campuses << campus_mikunigaoka
end
unless student22.campuses.include?(campus_mikunigaoka)
  student22.campuses << campus_mikunigaoka
end

# 泉ヶ丘駅前校の生徒を配置
unless student6.campuses.include?(campus_izumigaoka)
  student6.campuses << campus_izumigaoka
end
unless student7.campuses.include?(campus_izumigaoka)
  student7.campuses << campus_izumigaoka
end
unless student8.campuses.include?(campus_izumigaoka)
  student8.campuses << campus_izumigaoka
end
unless student9.campuses.include?(campus_izumigaoka)
  student9.campuses << campus_izumigaoka
end

# 岸和田校の生徒を配置
unless student10.campuses.include?(campus_kishiwada)
  student10.campuses << campus_kishiwada
end
unless student11.campuses.include?(campus_kishiwada)
  student11.campuses << campus_kishiwada
end
unless student12.campuses.include?(campus_kishiwada)
  student12.campuses << campus_kishiwada
end
unless student13.campuses.include?(campus_kishiwada)
  student13.campuses << campus_kishiwada
end

# 鳳駅前校の生徒を配置
unless student14.campuses.include?(campus_otori)
  student14.campuses << campus_otori
end
unless student15.campuses.include?(campus_otori)
  student15.campuses << campus_otori
end
unless student16.campuses.include?(campus_otori)
  student16.campuses << campus_otori
end

# 複数校舎対応講師の担当生徒（複数校舎に配置）
unless student17.campuses.include?(campus_mikunigaoka)
  student17.campuses << campus_mikunigaoka
end
unless student17.campuses.include?(campus_izumigaoka)
  student17.campuses << campus_izumigaoka
end

unless student18.campuses.include?(campus_kishiwada)
  student18.campuses << campus_kishiwada
end
unless student18.campuses.include?(campus_otori)
  student18.campuses << campus_otori
end

# 担当講師なしの生徒（複数校舎対応例）
unless student19.campuses.include?(campus_otori)
  student19.campuses << campus_otori
end
unless student19.campuses.include?(campus_mikunigaoka)
  student19.campuses << campus_mikunigaoka
end

unless student20.campuses.include?(campus_izumigaoka)
  student20.campuses << campus_izumigaoka
end
unless student20.campuses.include?(campus_kishiwada)
  student20.campuses << campus_kishiwada
end

puts "✅ 生徒と校舎の関連付け完了: #{StudentCampusAffiliation.count}件"

# ===================================================================
# 結果表示
# ===================================================================
puts "\n🎉 リニューアル版シードデータの作成が完了しました！"
puts ""
puts "=== 作成されたデータ ==="
puts "📍 校舎: #{Campus.count}件"
Campus.all.each do |campus|
  puts "  - #{campus.name} (生徒数: #{campus.student_count}名)"
end

puts "\n👨‍🏫 講師: #{Teacher.count}名"
puts "【管理者】"
Teacher.where(role: :admin).each do |admin|
  puts "  - #{admin.name} (#{admin.user_login_name})"
end

puts "【一般講師】"
Teacher.where(role: :teacher).each do |teacher|
  assigned_count = teacher.assigned_students.count
  assigned_text = assigned_count > 0 ? " (担当生徒: #{assigned_count}名)" : " (担当生徒なし)"
  notification_text = teacher.reminder_enabled? ? " 📧" : ""
  puts "  - #{teacher.name} (#{teacher.user_login_name})#{assigned_text}#{notification_text}"
end

puts "\n👨‍🎓 生徒: #{Student.count}名"
puts "【校舎別生徒数】"
Campus.all.each do |campus|
  puts "  - #{campus.name}: #{campus.student_count}名"
end

puts "\n📊 担当講師別生徒数:"
Teacher.where(role: :teacher).each do |teacher|
  count = teacher.assigned_students.count
  if count > 0
    puts "  - #{teacher.name}先生: #{count}名"
  end
end

# 担当講師なしの生徒をカウント
unassigned_count = Student.where(assigned_teacher: nil).count
puts "  - 担当講師なし: #{unassigned_count}名"

puts "\n🔗 生徒-校舎関連: #{StudentCampusAffiliation.count}件"

puts ""
puts "=== ログイン情報 ==="
puts "【管理者】"
puts "  ログイン名: admin_master / パスワード: AdminPass2024!"
puts "  ログイン名: admin_sub / パスワード: SubAdmin2024!"

puts "\n【講師（抜粋）】"
puts "  ログイン名: shibaguchi / パスワード: password-shibaguchi"
puts "  ログイン名: tanaka_hanako / パスワード: password-tanaka"
puts "  ログイン名: yamamoto_jiro / パスワード: password-yamamoto"
puts "  ログイン名: okamoto_sensei / パスワード: password-okamoto"
puts "  ※その他の講師ログイン名は上記の表示を参照"

puts "\n【生徒】"
puts "  すべての生徒のパスワード: 9999"
puts "  生徒番号: 2024001〜2024022"
puts "  担当講師ありの生徒: #{Student.where.not(assigned_teacher: nil).count}名"
puts "  担当講師なしの生徒: #{unassigned_count}名"

puts "\n📋 機能テスト用データ:"
puts "  - 複数生徒担当講師: #{teacher1.name}、#{teacher2.name}"
puts "  - メール通知設定講師: #{Teacher.where.not(email: nil).count}名"
puts "  - メール通知なし講師: #{Teacher.where(email: nil).count}名"
puts "  - 複数校舎所属生徒: #{Student.joins(:campuses).group('students.id').having('COUNT(campus.id) > 1').count.size}名"
puts "  - 通知時刻設定: 14:00〜22:00の1時間刻み（システム制限準拠）"
puts "  - パスワード形式: password-講師名（統一形式）"
puts "==================="
