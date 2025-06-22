class StudentsController < ApplicationController
  # ダッシュボードページのキャッシュを無効化（セキュリティ対策）
  before_action :prevent_caching, only: [:dashboard]
  # ダッシュボードと講師一覧で認証チェック
  before_action :require_student_login, only: [:dashboard, :teachers, :booking, :create_appointment, :appointments, :cancel_appointment, :destroy_appointment]

  # ログインフォーム表示
  def login
    # 既にログイン済みの場合はダッシュボードにリダイレクト
    redirect_to student_dashboard_path if current_student
  end

  # 認証処理（講師方式と統一）
  def authenticate
    # パラメータの取得
    student_number = params[:student_number]
    # ↑ フォームから送信された生徒番号を取得　
    # 例 => "2024001"
    
    password = params[:password]
    # ↑ フォームから送信されたパスワードを取得
    
    remember_me = params[:remember_me] == '1'
    # ↑ 「ログイン状態を保持」チェックボックスの状態を取得

    # Studentモデルで認証を試行
    # Devise は :email キーで認証対象を検索することを前提としているので、ここで意図的にemailキーにstudent_numberを渡している
    student = Student.find_for_database_authentication(email: student_number)
    #↑{email: "2024001"} として渡されてstudentモデルのfind_for_database_authenticationメソッドが実行される
    
    if student && student.valid_password?(password)
      # セッションに生徒IDを保存（講師方式と統一）
      session[:student_id] = student.id
      redirect_to student_dashboard_path, notice: 'ログインしました'
    else
      # 認証失敗
      flash.now[:alert] = '生徒番号またはパスワードが正しくありません'
      render :login
    end
  end

  # ログアウト処理（講師方式と統一）
  def logout
    # セッションをクリア
    session[:student_id] = nil
    redirect_to root_path, notice: 'ログアウトしました'
  end
  
  def dashboard
    @student = current_student
    @campus = @student.campuses.first  # 多対多関連に対応
    @teachers_count = Teacher.count
    @campuses_count = Campus.count
    
    # 生徒の予約情報を取得
    @upcoming_appointments = @student.appointments.upcoming.includes(time_slot: [:teacher, :campus]).limit(5)
    @past_appointments = @student.appointments.past.includes(time_slot: [:teacher, :campus]).limit(3)
    @total_appointments_count = @student.appointments.count
  end

  # 講師一覧画面
  def teachers
    @student = current_student
    
    # 担当講師がいる場合はその講師のみ、いない場合は全講師を表示
    if @student.assigned_teacher
      @teachers = [@student.assigned_teacher].select do |teacher|
        teacher.time_slots.available.where('date >= ?', Date.current).exists?
      end
    else
      @teachers = Teacher.joins(:time_slots)
                        .where(time_slots: { status: :available })
                        .where('time_slots.date >= ?', Date.current)
                        .distinct
                        .includes(:time_slots)
                        .order(:name)
    end
  end

  # 講師別予約画面
  def booking
    @student = current_student
    @teacher = Teacher.find(params[:teacher_id])
    
    # 週の開始日を設定（今週の月曜日から）
    @start_date = params[:week_start].present? ? Date.parse(params[:week_start]) : Date.current.beginning_of_week(:monday)
    @week_dates = (@start_date..(@start_date + 6.days)).to_a
    
    # 営業時間の時間枠を生成（14:00-22:00、10分刻み）
    @time_slots_grid = generate_time_slots_grid
    
    # 既存の面談枠データを取得（available のみ）
    # 時刻文字列をキーにしたハッシュに変更
    available_time_slots = @teacher.time_slots.available
                                   .where(date: @week_dates)
                                   .includes(:campus)
    
    @available_slots = {}
    available_time_slots.each do |slot|
      key = "#{slot.date}-#{slot.start_time.strftime('%H:%M')}"
      @available_slots[key] = slot
    end
    
    # 生徒の予約状況を取得
    @student_bookings = {}
    @student.appointments.joins(:time_slot)
            .where(time_slots: { teacher: @teacher, date: @week_dates })
            .includes(time_slot: :campus)
            .each do |appointment|
      key = "#{appointment.time_slot.date}-#{appointment.time_slot.start_time.strftime('%H:%M')}"
      @student_bookings[key] = appointment
    end
    
    # JavaScript用のJSONデータを準備
    @student_bookings_json = @student_bookings.map do |key, appointment|
      [key, {
        id: appointment.id,
        date: appointment.time_slot.date.strftime('%Y年%m月%d日'),
        time: appointment.time_slot.start_time.strftime('%H:%M'),
        campus: appointment.time_slot.campus.name
      }]
    end.to_h.to_json
    
    # デバッグ情報（開発環境のみ）
    if Rails.env.development?
      Rails.logger.debug "=== Booking Debug Info ==="
      Rails.logger.debug "Teacher: #{@teacher.name}"
      Rails.logger.debug "Week dates: #{@week_dates}"
      Rails.logger.debug "Available slots count: #{@available_slots.keys.count}"
      Rails.logger.debug "Available slots keys: #{@available_slots.keys.first(3)}"
      Rails.logger.debug "Student bookings count: #{@student_bookings.keys.count}"
      Rails.logger.debug "Student bookings keys: #{@student_bookings.keys.first(3)}"
      Rails.logger.debug "Time slots grid sample: #{@time_slots_grid.first(3)}"
      Rails.logger.debug "=========================="
    end
  end

  # 予約作成
  def create_appointment
    @student = current_student
    @time_slot = TimeSlot.find(params[:time_slot_id])
    
    # 予約可能性チェック
    unless @time_slot.bookable?
      render json: { status: 'error', message: '選択された時間枠は予約できません' }
      return
    end
    
    # 重複予約チェック
    if @student.appointments.joins(:time_slot).where(time_slots: { date: @time_slot.date }).exists?
      render json: { status: 'error', message: 'その日には既に別の予約があります' }
      return
    end
    
    @appointment = @student.appointments.build(
      time_slot: @time_slot,
      notes: params[:notes]
    )
    
    if @appointment.save
      render json: { 
        status: 'success', 
        message: '予約が完了しました',
        appointment: {
          id: @appointment.id,
          teacher_name: @time_slot.teacher.name,
          date: @time_slot.date.strftime('%Y年%m月%d日'),
          time: @time_slot.start_time.strftime('%H:%M'),
          campus: @time_slot.campus.name
        }
      }
    else
      render json: { 
        status: 'error', 
        message: @appointment.errors.full_messages.join(', ')
      }
    end
  end

  # 予約一覧画面
  def appointments
    @student = current_student
    @upcoming_appointments = @student.appointments.upcoming.includes(time_slot: [:teacher, :campus])
    @past_appointments = @student.appointments.past.includes(time_slot: [:teacher, :campus])
  end

  # 予約キャンセル
  def cancel_appointment
    @student = current_student
    @appointment = @student.appointments.find(params[:id])
    
    if @appointment.destroy
      redirect_to student_appointments_list_path, notice: '予約をキャンセルしました'
    else
      redirect_to student_appointments_list_path, alert: @appointment.errors.full_messages.join(', ')
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to student_appointments_list_path, alert: '予約が見つかりません'
  end

  # 予約削除（JSON API用）
  def destroy_appointment
    @student = current_student
    @appointment = @student.appointments.find(params[:id])
    
    if @appointment.destroy
      render json: { status: 'success', message: '予約を削除しました' }
    else
      render json: { status: 'error', message: @appointment.errors.full_messages.join(', ') }
    end
  rescue ActiveRecord::RecordNotFound
    render json: { status: 'error', message: '予約が見つかりません' }
  end

  private

  # 現在ログイン中の生徒を取得（講師方式と統一）
  def current_student
    @current_student ||= session[:student_id] && Student.find_by(id: session[:student_id])
  end

  # 生徒ログイン認証チェック（講師方式と統一）
  def require_student_login
    unless current_student
      redirect_to student_login_path, alert: 'ログインが必要です'
    end
  end

  # 営業時間の時間枠グリッドを生成
  def generate_time_slots_grid
    # 時刻文字列の配列を生成（14:00-22:00、10分刻み）
    time_slots = []
    hour = 14
    minute = 0
    
    while hour < 22 || (hour == 22 && minute == 0)
      time_slots << sprintf('%02d:%02d', hour, minute)
      minute += 10
      if minute >= 60
        minute = 0
        hour += 1
      end
    end
    
    time_slots
  end
end 