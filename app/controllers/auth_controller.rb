# AuthControllerの詳細解説

# クラス定義
class AuthController < ApplicationController
  # ↑ AuthControllerクラスを定義し、ApplicationControllerを継承
  # ApplicationControllerはRailsのコントローラの基底クラス
  # Webリクエストの処理やレスポンス生成の基本機能を提供

  # 講師権限が必要なアクションの前に実行
  before_action :require_staff, only: [:staff_dashboard]
  # ダッシュボードページのキャッシュを無効化（セキュリティ対策）
  before_action :prevent_caching, only: [:staff_dashboard]

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