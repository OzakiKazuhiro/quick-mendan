class StudentsController < ApplicationController
  # ダッシュボードページのキャッシュを無効化（セキュリティ対策）
  before_action :prevent_caching, only: [:dashboard]
  # ダッシュボードのみ認証チェック
  before_action :require_student_login, only: [:dashboard]

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
    @campus = @student.campus
    @teachers_count = Teacher.count
    @campuses_count = Campus.count
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
end 