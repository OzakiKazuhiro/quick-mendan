# AuthControllerの詳細解説

# クラス定義
class AuthController < ApplicationController
  # ↑ AuthControllerクラスを定義し、ApplicationControllerを継承
  # ApplicationControllerはRailsのコントローラの基底クラス
  # Webリクエストの処理やレスポンス生成の基本機能を提供

  # 講師権限が必要なアクションの前に実行
  before_action :require_staff,
                only: [:staff_dashboard, :proxy_booking, :create_proxy_appointment, :interview_record, :save_interview_record, :students_index,
                       :students_new, :students_create, :students_show, :students_edit, :students_update, :students_destroy, :bulk_assign_teacher]
  # ダッシュボードページのキャッシュを無効化（セキュリティ対策）
  before_action :prevent_caching, only: [:staff_dashboard]
  before_action :set_appointment, only: [:interview_record, :save_interview_record]
  before_action :set_student, only: [:students_show, :students_edit, :students_update, :students_destroy]
  before_action :set_teacher, only: [:teachers_show, :teachers_edit, :teachers_update, :teachers_destroy]

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

    # 講師選択機能（管理者・講師ともに利用可能）
    @selected_teacher_id = params[:teacher_id]&.to_i
    @selected_teacher = if @selected_teacher_id
                          Teacher.find(@selected_teacher_id)
                        else
                          @current_user # デフォルトは自分
                        end

    # 全講師リストを取得（管理者・講師ともに）
    @available_teachers = Teacher.all.order(:name)

    # 講師の場合は予約情報も取得
    return unless current_user_is_teacher?

    @tab = params[:tab] || 'my_appointments'

    case @tab
    when 'my_appointments'
      load_teacher_appointments(@selected_teacher)
    when 'all_appointments'
      load_all_appointments
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
    # ↑{email: "shibaguti"} として渡されてteacherモデルのfind_for_database_authenticationメソッドが実行される

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

    return unless @selected_student

    load_available_time_slots_for_proxy
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
      flash[:success] = '面談記録を保存しました'
      redirect_to staff_dashboard_path
    else
      flash[:error] = '面談記録の保存に失敗しました'
      render :interview_record
    end
  end

  # 生徒管理機能
  def students_index
    # 基本クエリ（担当講師も含める）
    @students = Student.includes(:campuses, :assigned_teacher)

    # 検索キーワード（生徒番号・氏名・高校名）
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @students = @students.where(
        'student_number LIKE ? OR name LIKE ? OR school_name LIKE ?',
        search_term, search_term, search_term
      )
    end

    # 校舎フィルタ
    @selected_campuses = params[:campuses] || []
    if @selected_campuses.any?
      @students = @students.joins(:student_campus_affiliations)
                           .where(student_campus_affiliations: { campus_id: @selected_campuses })
                           .distinct
    end

    # 学年フィルタ
    @selected_grade = params[:grade]
    @students = @students.where(grade: @selected_grade) if @selected_grade.present?

    # 担当講師フィルタ
    @selected_teacher = params[:assigned_teacher_id]
    if @selected_teacher.present?
      @students = if @selected_teacher == 'unassigned'
                    @students.where(assigned_teacher_id: nil)
                  else
                    @students.where(assigned_teacher_id: @selected_teacher)
                  end
    end

    # 最終的な並び順
    @students = @students.order(:student_number)

    # フィルタ用データ
    @campuses = Campus.all
    @grades = Student.where.not(grade: [nil, '']).distinct.pluck(:grade).compact.sort
    @teachers = Teacher.all.order(:name) # 一括操作とフィルタ用

    # 検索条件の保持
    @search_keyword = params[:search]
  end

  def students_new
    @student = Student.new
    @campuses = Campus.all
    @teachers = Teacher.all.order(:name) # 担当講師選択用
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
      @teachers = Teacher.all.order(:name)  # 担当講師選択用
      flash.now[:error] = '生徒の登録に失敗しました'
      render :students_new
    end
  end

  def students_show
    # @studentはbefore_actionで設定済み
  end

  def students_edit
    @campuses = Campus.all
    @teachers = Teacher.all.order(:name) # 担当講師選択用
  end

  def students_update
    if @student.update(student_params)
      flash[:success] = "生徒「#{@student.name}」の情報を更新しました"
      redirect_to staff_student_path(@student)
    else
      @campuses = Campus.all
      @teachers = Teacher.all.order(:name) # 担当講師選択用
      flash.now[:error] = '生徒情報の更新に失敗しました'
      render :students_edit
    end
  end

  def students_destroy
    student_name = @student.name
    if @student.destroy
      flash[:success] = "生徒「#{student_name}」を削除しました"
    else
      flash[:error] = '生徒の削除に失敗しました'
    end
    redirect_to staff_students_path
  end

  # 生徒の一括担当講師設定
  def bulk_assign_teacher
    student_ids_string = params[:student_ids]
    teacher_id = params[:teacher_id]

    # student_idsを文字列から配列に変換
    student_ids = student_ids_string.present? ? student_ids_string.split(',').map(&:to_i) : []

    if student_ids.empty?
      flash[:error] = '生徒を選択してください'
      redirect_to staff_students_path
      return
    end

    if teacher_id.present?
      teacher = Teacher.find(teacher_id)
      Student.where(id: student_ids).update_all(assigned_teacher_id: teacher_id)
      flash[:success] = "#{student_ids.length}名の生徒を#{teacher.name}先生の担当に設定しました"
    else
      Student.where(id: student_ids).update_all(assigned_teacher_id: nil)
      flash[:success] = "#{student_ids.length}名の生徒の担当を外しました"
    end

    redirect_to staff_students_path
  end

  # 面談記録モーダル表示用アクション
  def show_interview_record_modal
    @appointment = Appointment.find(params[:id])
    @record = @appointment.interview_record
    render partial: 'auth/interview_record_modal_content', locals: { appointment: @appointment, record: @record }
  end

  def save_interview_record_in_modal
    @appointment = Appointment.find(params[:id])
    @record = @appointment.interview_record || @appointment.build_interview_record

    if @record.update(interview_record_params)
      # 成功した場合、更新されたパーシャルを返す
      render partial: 'auth/interview_record_modal_content', locals: { appointment: @appointment, record: @record }
    else
      # 失敗した場合、エラー情報を含んだパーシャルを返す（もしくはエラーメッセージを返す）
      # ここでは簡単化のため、同じパーシャルを再描画
      render partial: 'auth/interview_record_modal_content', locals: { appointment: @appointment, record: @record },
             status: :unprocessable_entity
    end
  end

  # 講師管理機能
  def teachers_index
    @teachers = Teacher.order(:name)
  end

  def teachers_new
    @teacher = Teacher.new
  end

  def teachers_create
    @teacher = Teacher.new(teacher_params)

    if @teacher.save
      flash[:success] = "講師「#{@teacher.name}」を登録しました"
      redirect_to staff_teachers_path
    else
      flash.now[:error] = '講師の登録に失敗しました'
      render :teachers_new
    end
  end

  def teachers_show
    # @teacherはbefore_actionで設定済み
    load_teacher_statistics
  end

  def teachers_edit
    # @teacherはbefore_actionで設定済み
  end

  def teachers_update
    # パスワードが空の場合は更新しない
    teacher_update_params = if teacher_params[:password].blank?
                              teacher_params.except(:password, :password_confirmation)
                            else
                              teacher_params
                            end

    if @teacher.update(teacher_update_params)
      flash[:success] = "講師「#{@teacher.name}」の情報を更新しました"
      redirect_to staff_teacher_path(@teacher)
    else
      flash.now[:error] = '講師情報の更新に失敗しました'
      render :teachers_edit
    end
  end

  def teachers_destroy
    teacher_name = @teacher.name

    # 現在ログイン中の講師は削除できない
    if @teacher.id == current_staff_user.id
      flash[:error] = '現在ログイン中の講師は削除できません'
      redirect_to staff_teachers_path
      return
    end

    if @teacher.destroy
      flash[:success] = "講師「#{teacher_name}」を削除しました"
    else
      flash[:error] = '講師の削除に失敗しました'
    end
    redirect_to staff_teachers_path
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
    return if current_staff_user

    redirect_to staff_login_path, alert: 'ログインが必要です'
  end

  # キャッシュ無効化
  def prevent_caching
    response.headers['Cache-Control'] = 'no-cache, no-store, max-age=0, must-revalidate'
    response.headers['Pragma'] = 'no-cache'
    response.headers['Expires'] = 'Fri, 01 Jan 1990 00:00:00 GMT'
  end

  def after_sign_in_path_for(resource)
    staff_dashboard_path
  end

  def load_teacher_appointments(teacher = nil)
    # 選択された講師の面談枠に対する予約を取得
    target_teacher = teacher || current_staff_user

    @today_appointments = target_teacher.time_slots
                                        .joins(:appointment)
                                        .includes(appointment: { student: :campuses })
                                        .where('time_slots.date = ?', Date.current)
                                        .order(:start_time)

    @upcoming_appointments = target_teacher.time_slots
                                           .joins(:appointment)
                                           .includes(appointment: { student: :campuses })
                                           .where('time_slots.date > ?', Date.current)
                                           .order(:date, :start_time)

    @past_appointments = target_teacher.time_slots
                                       .joins(:appointment)
                                       .includes(appointment: [{ student: :campuses }, :interview_record])
                                       .where('time_slots.date < ?', Date.current)
                                       .order(date: :desc, start_time: :desc)
                                       .limit(20)
  end

  def load_all_appointments
    @campuses = Campus.all
    @selected_campuses = params[:campuses] || []

    # 全講師の予約を取得
    appointments_query = Appointment.joins(:time_slot, :student)
                                    .includes(time_slot: :teacher, student: :campuses)

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
    params.require(:student).permit(:name, :student_number, :grade, :school_name, :assigned_teacher_id, campus_ids: [])
  end

  def teacher_params
    params.require(:teacher).permit(:name, :user_login_name, :email, :password, :password_confirmation, :role, :notification_time)
  end

  def load_teacher_statistics
    # 講師の統計情報を取得
    @time_slots_count = @teacher.time_slots.count
    @appointments_count = Appointment.joins(:time_slot).where(time_slots: { teacher_id: @teacher.id }).count
    @upcoming_appointments = Appointment.joins(:time_slot)
                                        .where(time_slots: { teacher_id: @teacher.id })
                                        .where('time_slots.date >= ?', Date.current)
                                        .includes(:student, time_slot: :campus)
                                        .order('time_slots.date', 'time_slots.start_time')
    @past_appointments = Appointment.joins(:time_slot)
                                    .where(time_slots: { teacher_id: @teacher.id })
                                    .where('time_slots.date < ?', Date.current)
                                    .includes(:student, :interview_record, time_slot: :campus)
                                    .order('time_slots.date DESC', 'time_slots.start_time DESC')
                                    .limit(20)
  end

  def set_teacher
    @teacher = Teacher.find(params[:id])
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
# 5. 両方失敗 → エラーメッセージと共に再表示
