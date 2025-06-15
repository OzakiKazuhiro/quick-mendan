class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  
  # ApplicationHelperのメソッドをコントローラーでも使用可能にする
  include ApplicationHelper

  # app/helpers/application_helper.rbを上の１行でやっている感じです
# module ApplicationHelper
#   def current_admin
#     # メソッドの定義
#   end
  
#   def current_teacher
#     # メソッドの定義
#   end
# end

  # Deviseのログイン後のリダイレクト先を設定
  def after_sign_in_path_for(resource)
    case resource
    when Student
      student_dashboard_path
    else
      root_path
    end
  end

  protected

  # ダッシュボードページのキャッシュを完全に無効化
  # ログアウト後に戻るボタンでアクセスできないようにする
  def prevent_caching
    response.headers['Cache-Control'] = 'no-cache, no-store, must-revalidate, private'
    response.headers['Pragma'] = 'no-cache'
    response.headers['Expires'] = '0'
  end

  # 現在のユーザーが管理者かどうかをチェック
  def current_user_is_admin?
    current_admin.present?
  end

  # 現在のユーザーが講師（管理者または教師）かどうかをチェック
  def current_user_is_staff?
    current_admin.present? || current_teacher.present?
  end

  # 現在のユーザー（管理者または教師）を取得
  def current_staff_user
    current_admin || current_teacher
  end

  # 管理者権限が必要なアクションの前に実行
  def require_admin
    unless current_user_is_admin?
      redirect_to root_path, alert: '管理者権限が必要です'
    end
  end

  # 講師権限が必要なアクションの前に実行
  def require_staff
    unless current_user_is_staff?
      redirect_to root_path, alert: 'ログインが必要です'
    end
  end
end
