class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  protected

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
