class AuthController < ApplicationController
  def staff_login
    # 講師統合ログイン画面
  end

  def staff_authenticate
    username = params[:username]
    password = params[:password]
    remember_me = params[:remember_me] == '1'

    # まず管理者として認証を試行
    admin = Admin.find_for_database_authentication(email: username)
    if admin && admin.valid_password?(password)
      sign_in(admin, remember: remember_me)
      redirect_to after_sign_in_path_for(admin), notice: 'ログインしました'
      return
    end

    # 次に教師として認証を試行
    teacher = Teacher.find_for_database_authentication(email: username)
    if teacher && teacher.valid_password?(password)
      sign_in(teacher, remember: remember_me)
      redirect_to after_sign_in_path_for(teacher), notice: 'ログインしました'
      return
    end

    # 認証失敗
    flash.now[:alert] = 'ユーザー名またはパスワードが正しくありません'
    render :staff_login
  end

  private

  def after_sign_in_path_for(resource)
    # 管理者も教師も同じダッシュボードへ
    # 管理者権限の判定は各機能で行う
    root_path # 後で講師用ダッシュボードに変更
  end
end 