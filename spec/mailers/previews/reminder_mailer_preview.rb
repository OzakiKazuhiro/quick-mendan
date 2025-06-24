# 何をするファイル？
# ブラウザでメールの見た目を確認
# 実際に送信せずに確認できる
# http://localhost:3000/rails/mailers/reminder_mailer/daily_reminder にアクセスすると、メールの見た目を確認できる

class ReminderMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/reminder_mailer/daily_reminder
  def daily_reminder
    # テスト用の講師データを取得（メールアドレスが設定されている講師）
    teacher = Teacher.where.not(email: [nil, '']).first

    # 講師が見つからない場合はサンプルデータを作成
    if teacher.nil?
      teacher = Teacher.new(
        name: '田中太郎',
        email: 'tanaka@example.com',
        notification_time: '17:00'
      )
    end

    ReminderMailer.daily_reminder(teacher)
  end
end
