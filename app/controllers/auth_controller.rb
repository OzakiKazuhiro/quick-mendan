# AuthControllerの詳細解説

# クラス定義
class AuthController < ApplicationController
  # ↑ AuthControllerクラスを定義し、ApplicationControllerを継承
  # ApplicationControllerはRailsのコントローラの基底クラス
  # Webリクエストの処理やレスポンス生成の基本機能を提供

  # 講師権限が必要なアクションの前に実行
  before_action :require_staff, only: [:staff_dashboard, :proxy_booking, :create_proxy_appointment, :interview_record, :save_interview_record, :students_index, :students_new, :students_create, :students_show, :students_edit, :students_update, :students_destroy]
  # ダッシュボードページのキャッシュを無効化（セキュリティ対策）
  before_action :prevent_caching, only: [:staff_dashboard]
  before_action :set_appointment, only: [:interview_record, :save_interview_record]
  before_action :set_student, only: [:students_show, :students_edit, :students_update, :students_destroy]

  # staff_loginアクション
  def staff_login
    # 講師統合ログイン画面
    # ↑ このアクションは講師（管理者・教師）共通のログイン画面を表示
    # 通常はstaff_login.html.erbなどのビューファイルをレンダリング
    # メソッド内に処理がないため、デフォルトでビューを表示
  end

  # staff_dashboardアクション
  def staff_dashboard
    @current_user = current_staff_user
    @is_admin = current_user_is_admin?
    @teachers_count = Teacher.count
    @students_count = Student.count
    @campuses_count = Campus.count
    
    # 講師の場合は予約情報も取得
    if current_user_is_teacher?
      @tab = params[:tab] || 'my_appointments'
      
      case @tab
      when 'my_appointments'
        load_teacher_appointments
      when 'all_appointments'
        load_all_appointments
      end
    end
  end

  # staff_authenticateアクション開始
  def staff_authenticate
    # ↑ ログインフォームから送信されたデータを処理する認証アクション

    # パラメータの取得
    username = params[:username]
    # ↑ フォームから送信されたユーザー名を取得　
    # 例 => "shibaguti"
    
    password = params[:password]
    # ↑ フォームから送信されたパスワードを取得
    
    remember_me = params[:remember_me] == '1'
    # ↑ 「ログイン状態を保持」チェックボックスの状態を取得
    # '1'の場合true、それ以外（nil含む）はfalseになる

    # Teacherモデルで認証を試行
    # Devise は :email キーで認証対象を検索することを前提としているので、ここで意図的にemailキーにusernameを渡している
    teacher = Teacher.find_for_database_authentication(email: username)
    #↑{email: "shibaguti"} として渡されてteacherモデルのfind_for_database_authenticationメソッドが実行される
    
    if teacher && teacher.valid_password?(password)
      session[:teacher_id] = teacher.id
      redirect_to after_sign_in_path_for(teacher), notice: 'ログインしました'
      return
    end

    # 認証失敗
    flash.now[:alert] = 'ユーザー名またはパスワードが正しくありません'
    render :staff_login
  end

  def staff_logout
    # セッションをクリア
    session[:teacher_id] = nil
    redirect_to root_path, notice: 'ログアウトしました'
  end

  # 代理予約画面
  def proxy_booking
    @students = Student.includes(:campuses).order(:name)
    @selected_student = Student.find(params[:student_id]) if params[:student_id].present?
    
    if @selected_student
      load_available_time_slots_for_proxy
    end
  end

  # 代理予約作成
  def create_proxy_appointment
    @student = Student.find(params[:student_id])
    @time_slot = TimeSlot.find(params[:time_slot_id])
    
    @appointment = Appointment.new(
      student: @student,
      time_slot: @time_slot,
      notes: "代理予約（#{current_staff_user.name}先生による）"
    )
    
    if @appointment.save
      flash[:success] = "#{@student.name}さんの予約を作成しました"
      redirect_to staff_dashboard_path(tab: 'my_appointments')
    else
      flash[:error] = "予約の作成に失敗しました: #{@appointment.errors.full_messages.join(', ')}"
      redirect_to proxy_booking_path(student_id: @student.id)
    end
  end

  # 面談記録表示・編集
  def interview_record
    @appointment = Appointment.find(params[:id])
    @record = @appointment.interview_record || @appointment.build_interview_record
  end

  # 面談記録保存・更新
  def save_interview_record
    @appointment = Appointment.find(params[:id])
    @record = @appointment.interview_record || @appointment.build_interview_record
    
    if @record.update(interview_record_params)
      flash[:success] = "面談記録を保存しました"
      redirect_to staff_dashboard_path
    else
      flash[:error] = "面談記録の保存に失敗しました"
      render :interview_record
    end
  end

  # 生徒管理機能
  def students_index
    @students = Student.includes(:campuses).order(:student_number)
    @campuses = Campus.all
  end

  def students_new
    @student = Student.new
    @campuses = Campus.all
  end

  def students_create
    @student = Student.new(student_params)
    @student.password = '9999' # 固定パスワード
    @student.password_confirmation = '9999' # パスワード確認も設定
    
    if @student.save
      flash[:success] = "生徒「#{@student.name}」を登録しました"
      redirect_to staff_students_path
    else
      @campuses = Campus.all
      flash.now[:error] = "生徒の登録に失敗しました"
      render :students_new
    end
  end

  def students_show
    # @studentはbefore_actionで設定済み
  end

  def students_edit
    @campuses = Campus.all
  end

  def students_update
    if @student.update(student_params)
      flash[:success] = "生徒「#{@student.name}」の情報を更新しました"
      redirect_to staff_student_path(@student)
    else
      @campuses = Campus.all
      flash.now[:error] = "生徒情報の更新に失敗しました"
      render :students_edit
    end
  end

  def students_destroy
    student_name = @student.name
    if @student.destroy
      flash[:success] = "生徒「#{student_name}」を削除しました"
    else
      flash[:error] = "生徒の削除に失敗しました"
    end
    redirect_to staff_students_path
  end

  # 29行目: privateメソッドの開始
  private
  # ↑ 以降のメソッドはクラス外部から呼び出し不可
  # コントローラ内部でのみ使用される補助メソッド

  # 現在ログイン中のユーザー（管理者または講師）
  def current_staff_user
    @current_staff_user ||= session[:teacher_id] && Teacher.find_by(id: session[:teacher_id])
  end

  # 現在のユーザーが管理者かどうか
  def current_user_is_admin?
    current_staff_user&.admin?
  end

  # 現在のユーザーが講師かどうか
  def current_user_is_teacher?
    current_staff_user&.teacher?
  end

  helper_method :current_user_is_teacher?

  # 講師権限チェック
  def require_staff
    unless current_staff_user
      redirect_to staff_login_path, alert: 'ログインが必要です'
    end
  end

  # キャッシュ無効化
  def prevent_caching
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end

  def after_sign_in_path_for(resource)
    staff_dashboard_path
  end

  def load_teacher_appointments
    # 自分の面談枠に対する予約を取得（TeachersControllerと同じロジック）
    current_teacher = current_staff_user
    
    @today_appointments = current_teacher.time_slots
                                        .joins(:appointment)
                                        .includes(:appointment => {:student => :campuses})
                                        .where('time_slots.date = ?', Date.current)
                                        .order(:start_time)

    @upcoming_appointments = current_teacher.time_slots
                                           .joins(:appointment)
                                           .includes(:appointment => {:student => :campuses})
                                           .where('time_slots.date > ?', Date.current)
                                           .order(:date, :start_time)

    @past_appointments = current_teacher.time_slots
                                       .joins(:appointment)
                                       .includes(:appointment => [{:student => :campuses}, :interview_record])
                                       .where('time_slots.date < ?', Date.current)
                                       .order(date: :desc, start_time: :desc)
                                       .limit(20)
  end

  def load_all_appointments
    @campuses = Campus.all
    @selected_campuses = params[:campuses] || []
    
    # 全講師の予約を取得
    appointments_query = Appointment.joins(:time_slot, :student)
                                   .includes(:time_slot => :teacher, :student => :campuses)
    
    # 校舎でフィルタリング
    if @selected_campuses.any?
      appointments_query = appointments_query.joins(student: :student_campus_affiliations)
                                           .where(student_campus_affiliations: { campus_id: @selected_campuses })
    end
    
    # 日付でグループ化
    @appointments_by_date = appointments_query.where('time_slots.date >= ?', Date.current)
                                             .order('time_slots.date', 'time_slots.start_time')
                                             .group_by { |apt| apt.time_slot.date }
  end

  def load_available_time_slots_for_proxy
    # 代理予約用の空き時間枠を取得（当日でも可能）
    @available_slots = current_staff_user.time_slots
                                        .where(status: :available)
                                        .where('date >= ?', Date.current)
                                        .order(:date, :start_time)
                                        .limit(50)
  end

  def set_appointment
    @appointment = Appointment.find(params[:id])
  end

  def set_student
    @student = Student.find(params[:id])
  end

  def interview_record_params
    params.require(:interview_record).permit(:content)
  end

  def student_params
    params.require(:student).permit(:name, :student_number, :grade, :school_name, campus_ids: [])
  end
# 35行目: クラス定義終了
end

# 【このコードの全体的な機能】
# 1. 管理者と教師が同じフォームでログイン可能
# 2. まず管理者として認証を試行し、失敗したら教師として試行
# 3. どちらも失敗した場合はエラーメッセージを表示
# 4. 成功した場合は適切なページにリダイレクト

# 【認証の流れ】
# 1. staff_login → ログイン画面表示
# 2. フォーム送信 → staff_authenticate実行
# 3. Admin認証 → 成功ならログイン完了
# 4. Teacher認証 → 成功ならログイン完了
# 5. 両方失敗 → エラーメッセージと共に再表示