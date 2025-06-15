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
    # ログイン後のダッシュボード画面
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
    
    password = params[:password]
    # ↑ フォームから送信されたパスワードを取得
    
    remember_me = params[:remember_me] == '1'
    # ↑ 「ログイン状態を保持」チェックボックスの状態を取得
    # '1'の場合true、それ以外（nil含む）はfalseになる

    # まず管理者として認証を試行
    
    # 管理者の検索
    admin = Admin.find_for_database_authentication(email: username)
    # ↑ 先ほど解説したAdminモデルのメソッドを使用
    # usernameを使って管理者を検索（実際はuser_login_nameで検索）
    
    # 管理者認証の条件分岐
    if admin && admin.valid_password?(password)
      # ↑ 2つの条件をチェック
      # admin → 管理者が見つかったか（nilでないか）
      # admin.valid_password?(password) → パスワードが正しいか
      # Deviseが提供するメソッドでハッシュ化されたパスワードと比較

      # セッションに管理者IDを保存
      session[:admin_id] = admin.id
      session[:teacher_id] = nil  # 教師セッションをクリア
      redirect_to after_sign_in_path_for(admin), notice: 'ログインしました'
      # ↑ Deviseのsign_inメソッドでセッションを開始
      # remember: remember_me → ログイン状態保持の設定を反映

      # メソッド終了
      return
      # ↑ ここで処理を終了（以降の教師認証処理をスキップ）
    end

    # コメント（教師認証の説明）
    # 次に教師として認証を試行
    
    # 教師の検索
    teacher = Teacher.find_for_database_authentication(email: username)
    # ↑ Teacherモデルで同様の検索を実行
    # TeacherモデルもAdminと同様のカスタマイズがされていると想定

    # 教師認証の条件分岐
    if teacher && teacher.valid_password?(password)
      # ↑ 管理者と同様の認証チェック
      # teacher → 教師が見つかったか
      # teacher.valid_password?(password) → パスワードが正しいか

      # セッションに教師IDを保存
      session[:teacher_id] = teacher.id
      session[:admin_id] = nil  # 管理者セッションをクリア
      redirect_to after_sign_in_path_for(teacher), notice: 'ログインしました'
      # ↑ Deviseのsign_inメソッドで教師としてセッション開始

      # メソッド終了
      return
      # ↑ 認証成功のため処理終了
    end

    # 認証失敗
    
    # エラーメッセージ設定
    flash.now[:alert] = 'ユーザー名またはパスワードが正しくありません'
    # ↑ flash.now → 現在のリクエストでのみ表示されるフラッシュメッセージ
    # :alert → エラーメッセージ用のキー

    # ログイン画面を再表示
    render :staff_login
    # ↑ リダイレクトではなく、同じページを再レンダリング
    # エラーメッセージと共にログインフォームを再表示
  end

  def staff_logout
    # セッションをクリア
    session[:admin_id] = nil
    session[:teacher_id] = nil
    redirect_to root_path, notice: 'ログアウトしました'
  end

  # 29行目: privateメソッドの開始
  private
  # ↑ 以降のメソッドはクラス外部から呼び出し不可
  # コントローラ内部でのみ使用される補助メソッド

  # 31行目: ログイン後の遷移先を決定するメソッド
  def after_sign_in_path_for(resource)
    # ↑ Deviseが提供するフック用メソッドをオーバーライド
    # resource → ログインしたユーザー（AdminまたはTeacher）

    # 32-33行目: コメント（権限管理の説明）
    # 管理者も教師も同じダッシュボードへ
    # 管理者権限の判定は各機能で行う
    # ↑ 設計思想の説明
    # ログイン後は同じページに遷移し、機能ごとで権限チェック

    # 34行目: 遷移先の指定
    staff_dashboard_path # ログイン後はダッシュボードへ
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