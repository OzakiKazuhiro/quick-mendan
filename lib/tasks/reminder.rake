namespace :reminder do
  desc 'リマインダーメール送信チェック（毎時実行）'
  task check_and_send: :environment do
    current_hour = Time.current.hour
    puts "=== リマインダーメール送信チェック開始 #{Time.current.strftime('%Y-%m-%d %H:%M:%S')} ==="
    puts "現在時刻: #{current_hour}時"

    # 現在時刻にリマインダー送信設定している講師を取得（SQLite対応）
    target_teachers = Teacher.where(
      "email IS NOT NULL AND email != '' AND notification_time IS NOT NULL AND strftime('%H', notification_time) = ?",
      format('%02d', current_hour)
    )

    puts "#{current_hour}時に送信設定している講師: #{target_teachers.count}名"

    if target_teachers.empty?
      puts '送信対象の講師がいません。'
      puts '=== リマインダーメール送信チェック完了 ==='
      return
    end

    sent_count = 0
    error_count = 0

    target_teachers.each do |teacher|
      puts "#{teacher.name}先生 (#{teacher.email}) への送信をチェック中..."

      # 翌日の面談予定を事前チェック
      tomorrow_appointments = teacher.time_slots
                                     .joins(:appointment)
                                     .includes(appointment: [:student, :interview_record], campus: [])
                                     .where(date: Date.tomorrow)
                                     .order(:start_time)

      if tomorrow_appointments.empty?
        puts '  → 翌日の面談予定なし。メール送信スキップ。'
        next
      end

      # メール送信実行
      ReminderMailer.daily_reminder(teacher).deliver_now
      sent_count += 1
      puts "  ✅ 送信完了 (面談予定: #{tomorrow_appointments.count}件)"
    rescue StandardError => e
      error_count += 1
      puts "  ❌ 送信エラー: #{e.message}"
      Rails.logger.error "ReminderMailer Error for #{teacher.name}: #{e.message}"
    end

    puts '=== リマインダーメール送信チェック完了 ==='
    puts "送信成功: #{sent_count}件"
    puts "送信エラー: #{error_count}件" if error_count > 0
    puts "処理時間: #{Time.current.strftime('%Y-%m-%d %H:%M:%S')}"
  end

  desc 'リマインダーメール送信テスト（手動実行用）'
  task test_send: :environment do
    puts '=== リマインダーメール送信テスト ==='

    # リマインダー設定済みの講師を全て取得
    test_teachers = Teacher.where("email IS NOT NULL AND email != '' AND notification_time IS NOT NULL")

    if test_teachers.empty?
      puts 'リマインダー設定済みの講師がいません。'
      return
    end

    puts 'テスト対象講師:'
    test_teachers.each do |teacher|
      puts "  - #{teacher.name}先生 (#{teacher.email}) 設定時刻: #{teacher.notification_time.strftime('%H:%M')}"
    end

    print "\n送信テストを実行しますか？ (y/N): "
    input = STDIN.gets.chomp.downcase

    if %w[y yes].include?(input)
      test_teachers.each do |teacher|
        ReminderMailer.daily_reminder(teacher).deliver_now
        puts "✅ #{teacher.name}先生への送信完了"
      rescue StandardError => e
        puts "❌ #{teacher.name}先生への送信エラー: #{e.message}"
      end
    else
      puts 'テスト送信をキャンセルしました。'
    end
  end

  desc 'リマインダー設定状況の確認'
  task status: :environment do
    puts '=== リマインダー設定状況 ==='

    all_teachers = Teacher.all
    enabled_teachers = Teacher.where("email IS NOT NULL AND email != '' AND notification_time IS NOT NULL")

    puts "全講師数: #{all_teachers.count}名"
    puts "リマインダー設定済み: #{enabled_teachers.count}名"
    puts ''

    if enabled_teachers.any?
      puts '設定済み講師一覧:'
      enabled_teachers.order(:notification_time).each do |teacher|
        puts "  #{teacher.notification_time.strftime('%H:%M')} - #{teacher.name}先生 (#{teacher.email})"
      end
    end

    puts ''
    puts '時間帯別設定数（営業時間：14:00-22:00）:'
    (14..22).each do |hour|
      count = enabled_teachers.where("strftime('%H', notification_time) = ?", format('%02d', hour)).count
      puts "  #{format('%02d', hour)}:00 - #{count}名"
    end
  end
end
