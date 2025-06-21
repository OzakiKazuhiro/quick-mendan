class Appointment < ApplicationRecord
  belongs_to :student
  belongs_to :time_slot
  has_one :interview_record, dependent: :destroy

  # ====================================================================
  # Delegateメソッド - 関連モデルのメソッドを委譲（移譲）する
  # ===================================================================
  # 文法: delegate :メソッド名1, :メソッド名2, ..., to: :関連名, オプション
  # 
  # 【仕組みの説明】
  # `to: :time_slot` は、このAppointmentモデルの `time_slot` アソシエーション（belongs_to :time_slot）を指している
  # つまり、TimeSlotモデルから直接呼び出すのではなく、
  # 「このAppointmentインスタンスが持つtime_slotオブジェクト」のメソッドを呼び出している
  #
  # 【この行の意味】
  # TimeSlotモデルの以下のメソッドを、Appointmentモデルから直接呼び出せるようにする：
  # - teacher    (講師情報)
  # - date       (面談日)
  # - start_time (開始時刻)
  # - end_time   (終了時刻)
  #
  # 【delegateを使わない場合との比較】
  # 
  # ■ delegateを使わない場合（従来の書き方）:
  # appointment = Appointment.find(1)
  # teacher_name = appointment.time_slot.teacher.name      # 長い
  # meeting_date = appointment.time_slot.date              # 長い
  # start_time = appointment.time_slot.start_time          # 長い
  # 
  # # さらに、time_slotがnilの場合はエラーになる
  # appointment.time_slot = nil
  # appointment.time_slot.teacher  # => NoMethodError: undefined method `teacher' for nil:NilClass
  #
  # ■ delegateを使った場合（簡潔な書き方）:
  # appointment = Appointment.find(1)
  # teacher_name = appointment.teacher.name                # 短い！
  # meeting_date = appointment.date                        # 短い！
  # start_time = appointment.start_time                    # 短い！
  # 
  # # allow_nil: true があるので、time_slotがnilでもエラーにならない
  # appointment.time_slot = nil
  # appointment.teacher  # => nil（エラーにならない）
  #
  # 【allow_nil: trueの意味】
  # time_slotがnilの場合でもエラーを出さず、nilを返す
  # これがないと time_slot が nil の時に NoMethodError が発生する
  # つまり、delegateはショートカットのようなもので、長いメソッドチェーンを短く書けるようにしてくれる便利な機能
  delegate :teacher, :date, :start_time, :end_time, to: :time_slot, allow_nil: true

  # ====================================================================
  # バリデーション（Validation） - データの整合性をチェック
  # ====================================================================
  # 文法: validates :カラム名, 検証ルール: オプション
  # 
  # 【presence: true】
  # 指定したカラムが空でないことをチェック（必須項目）
  # nil、空文字列、空白文字のみの場合はエラーになる
  validates :student_id, presence: true
  validates :time_slot_id, presence: true, uniqueness: true
  # 【uniqueness: true】
  # 指定したカラムの値が一意（重複しない）ことをチェック
  # time_slot_idが重複する場合はエラー → 同じ時間枠に複数予約を防ぐ

  # 【カスタムバリデーション】
  # 文法: validate :メソッド名, on: :実行タイミング
  # 独自の検証ロジックを定義したメソッドを呼び出す
  validate :time_slot_must_be_bookable, on: :create    # 作成時のみ実行
  validate :cancellation_deadline_check, on: :destroy  # 削除時のみ実行

  # ====================================================================
  # スコープ（Scope） - よく使う検索条件を定義
  # ====================================================================
  # 文法: scope :名前, -> { 検索条件 }
  # または: scope :名前, ->(引数) { 検索条件 }
  # 
  # 【使用例】
  # Appointment.by_student(student)  # 特定の生徒の予約を取得
  # Appointment.upcoming            # 今日以降の予約を取得
  # Appointment.past.limit(10)      # 過去の予約を10件取得
  scope :by_student, ->(student) { where(student: student) }
  scope :by_teacher, ->(teacher) { joins(:time_slot).where(time_slots: { teacher: teacher }) }
  scope :by_time_slot, ->(time_slot) { where(time_slot: time_slot) }
  
  # 【joinsメソッド】
  # 関連テーブルを結合してクエリを実行
  # joins(:time_slot) → time_slotsテーブルと結合
  scope :upcoming, -> { joins(:time_slot).where('time_slots.date >= ?', Date.current).order('time_slots.date, time_slots.start_time') }
  scope :past, -> { joins(:time_slot).where('time_slots.date < ?', Date.current).order('time_slots.date DESC, time_slots.start_time DESC') }
  scope :today, -> { joins(:time_slot).where('time_slots.date = ?', Date.current).order('time_slots.start_time') }

  # ====================================================================
  # コールバック（Callback） - 特定のタイミングで自動実行されるメソッド
  # ====================================================================
  # 文法: コールバック名 :メソッド名, オプション
  # 
  # 【after_create】 - レコード作成後に実行
  # 【before_destroy】 - レコード削除前に実行
  # 【after_destroy】 - レコード削除後に実行
  # 
  # 【unless: -> { Rails.env.test? }】
  # テスト環境では実行しない条件
  # ラムダ式（->）を使って条件を指定
  after_create :mark_time_slot_as_booked
  before_destroy :check_cancellation_deadline, unless: -> { Rails.env.test? }
  after_destroy :mark_time_slot_as_available

  # ====================================================================
  # インスタンスメソッド - このモデルのインスタンスから呼び出せるメソッド
  # ====================================================================
  
  # 【return文とunless文】
  # return nil unless time_slot → time_slotがnilなら即座にnilを返して終了
  # unless は if の逆（条件が偽の場合に実行）
  def appointment_datetime
    return nil unless time_slot
    
    # 【DateTime.new】
    # 年、月、日、時、分を指定してDateTimeオブジェクトを作成
    DateTime.new(
      time_slot.date.year,
      time_slot.date.month,
      time_slot.date.day,
      time_slot.start_time.hour,
      time_slot.start_time.min
    )
  end

  # 【安全ナビゲーション演算子 &.】
  # time_slot&.teacher → time_slotがnilでなければteacherメソッドを呼ぶ
  # nilの場合は全体がnilになる（エラーにならない）
  def appointment_display
    return "予約情報なし" unless time_slot&.teacher
    
    # 【文字列補間 #{}】
    # 文字列内に変数や式の値を埋め込む
    # 【strftimeメソッド】
    # 日付や時刻を指定した形式で文字列に変換
    "#{time_slot.teacher.name}先生 #{time_slot.date.strftime('%m/%d')} #{time_slot.start_time.strftime('%H:%M')}"
  end

  # 【論理演算】
  # return false unless 条件 → 条件が偽なら即座にfalseを返す
  def cancellable?
    return false unless time_slot&.date
    
    # 【日付計算】
    # time_slot.date - 1.day → 1日前の日付
    # end_of_day → その日の23:59:59
    # change(hour: 22, min: 15) → 22:15に変更
    deadline = (time_slot.date - 1.day).end_of_day.change(hour: 22, min: 15)
    Time.current <= deadline
  end

  # 【メソッドの再利用】
  # 他のメソッドを呼び出して同じ条件を使用
  def modifiable?
    cancellable? # キャンセル可能な条件と同じ
  end

  # 【常にtrueを返すメソッド】
  # 講師は制限なしで変更・キャンセル可能
  def teacher_modifiable?
    true
  end

  # 【時刻比較】
  # 面談日時が現在時刻より前かどうか（過去かどうか）
  def can_add_interview_record?
    appointment_datetime < Time.current
  end

  # 【安全ナビゲーション演算子とinclude?メソッド】
  # notes&.include?("代理予約") → notesがnilでなければinclude?を実行
  # include?メソッド → 文字列に指定した文字列が含まれているかチェック
  def proxy_booking?
    notes&.include?("代理予約")
  end

  # 【present?メソッド】
  # オブジェクトが存在し、空でないかをチェック
  # nil、false、空文字列、空配列、空ハッシュの場合はfalse
  def has_interview_record?
    interview_record.present?
  end

  # 【エイリアスメソッド】
  # 同じ機能を別名で提供（テスト用の命名規則に対応）
  def can_be_cancelled?
    cancellable?
  end

  # ====================================================================
  # プライベートメソッド - クラス内部でのみ使用可能
  # ====================================================================
  # private以下のメソッドは外部から直接呼び出せない
  # 主にバリデーションやコールバックで使用される内部処理
  private

  # 【カスタムバリデーションメソッド】
  # return unless 条件 → 条件が偽なら何もしないで終了
  def time_slot_must_be_bookable
    return unless time_slot
    
    # 【unless文とerrors.add】
    # 条件が偽の場合にエラーメッセージを追加
    # errors.add(:属性名, "エラーメッセージ")
    unless time_slot.bookable?
      errors.add(:time_slot, "選択された時間枠は予約できません")
    end
  end

  # 【throw :abort】
  # コールバックチェーンを中断してデータベースの変更をロールバック
  # 削除処理を強制的に停止する
  def cancellation_deadline_check
    unless cancellable?
      errors.add(:base, "予約変更・キャンセルの締切時間を過ぎています（前日22:15まで）")
      throw :abort
    end
  end

  # 【メソッドの委譲】
  # 別のメソッドを呼び出すだけのシンプルなメソッド
  def check_cancellation_deadline
    cancellation_deadline_check
  end

  # 【条件付きupdate!】
  # if 条件 → 条件が真の場合のみ実行
  # update!メソッド → データベースを更新（失敗時は例外発生）
  def mark_time_slot_as_booked
    time_slot.update!(status: :booked) if time_slot.available?
  end

  def mark_time_slot_as_available
    time_slot.update!(status: :available) if time_slot.booked?
  end
end
