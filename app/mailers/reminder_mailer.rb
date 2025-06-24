  # 何をするファイル？
  # 講師の翌日面談予定を取得
  # メール送信の実行
  # 面談がない場合は送信しない判断

class ReminderMailer < ApplicationMailer
  
  def daily_reminder(teacher)
    # ①講師の情報を受け取る
    # ②翌日の面談予定を取得
    # ③メールを送信
    # ④面談がない場合はメール送信しない
    @teacher = teacher
    @tomorrow = Date.tomorrow
    @appointments = get_tomorrow_appointments(teacher)
    
    # 面談がない場合はメール送信しない
    return if @appointments.empty?
    
    mail(
      to: teacher.email,
      subject: "【面談リマインダー】明日の面談予定（#{@tomorrow.strftime('%m/%d')}）- #{teacher.name}先生"
    )
  end
  
  private
  def get_tomorrow_appointments(teacher)
    # 講師の翌日の面談予定を取得
    teacher.time_slots
           .joins(:appointment)
           .includes(appointment: [:student, :interview_record], campus: [])
           .where(date: Date.tomorrow)
           .order(:start_time)
  end

  # ===================================================================
  # 翌日の面談予定取得メソッド
  # ===================================================================
  # 
  # 【重要】joinsとincludesの違いと必要性について
  # 
  # ■ joins(:appointment)の役割 → データの絞り込み
  #   - 予約が入っている面談枠のみに絞り込む
  #   - 空き枠（予約なし）は除外される
  #   - 例：面談枠4つあるが予約は2つ → 2つの面談枠のみ取得
  #   
  # ■ includes(...)の役割 → 関連データの事前読み込み（N+1問題対策）
  #   - 関連テーブルのデータを最初にまとめて取得
  #   - 後で関連データにアクセスしても追加SQLが発生しない
  #   - パフォーマンスを大幅に向上させる
  #
  # ■ なぜ両方必要？
  #   1. joins(:appointment)がないと：
  #      → 予約がない空き枠も取得される
  #      → 予約がない日でもメールが送信されてしまう
  #   
  #   2. includes(...)がないと：
  #      → N+1問題が発生（面談枠の数だけ追加SQLが実行される）
  #      → 面談枠が5個あると、5×3=15回の追加SQLが発生
  #      → パフォーマンスが大幅に悪化
  #
  # ■ 実際のSQL実行例（面談枠3個、予約2個の場合）
  #   
  #   【joinsなし、includesなしの場合】
  #   - 1回目：SELECT * FROM time_slots WHERE teacher_id = 1 AND date = '2025-06-25'
  #     → 3個の面談枠を取得（予約なしも含む）
  #   - 2回目以降：各面談枠ごとに関連データを取得
  #     → 3×3 = 9回の追加SQL
  #   - 合計：10回のSQL実行
  #
  #   【joins + includes の場合（今回の実装）】
  #   - 1回目：SELECT time_slots.* FROM time_slots INNER JOIN appointments ON ... 
  #     → 2個の面談枠を取得（予約ありのみ）
  #   - 2回目：SELECT appointments.* FROM appointments WHERE time_slot_id IN (1,2)
  #   - 3回目：SELECT students.* FROM students WHERE id IN (101,102)
  #   - 4回目：SELECT interview_records.* FROM interview_records WHERE appointment_id IN (1,2)
  #   - 5回目：SELECT campus.* FROM campus WHERE id IN (1,2)
  #   - 合計：5回のSQL実行（50%の効率化）
  #
  # ■ includes の詳細構文説明
  #   appointment: [:student, :interview_record] の意味：
  #   - appointmentに紐づくstudentテーブルのデータを事前読み込み
  #   - appointmentに紐づくinterview_recordテーブルのデータを事前読み込み
  #   
  #   campus: [] の意味：
  #   - campusテーブルのデータを事前読み込み
  #   - []は「さらにネストした関連はない」という意味
  #
  # ===================================================================
end
