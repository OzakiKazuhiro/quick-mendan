module ApplicationHelper
  # 現在ログインしている講師を取得
  def current_teacher
    @current_teacher ||= session[:teacher_id] && Teacher.find_by(id: session[:teacher_id])
  end

  # 現在ログインしているスタッフ（講師）を取得
  def current_staff_user
    current_teacher
  end
  
  # 管理者がログインしているかチェック
  def admin_signed_in?
    current_teacher&.admin?
  end
  
  # 講師がログインしているかチェック
  def teacher_signed_in?
    current_teacher.present?
  end
  
  # スタッフ（講師）がログインしているかチェック
  def staff_signed_in?
    current_teacher.present?
  end
  
  # 現在のユーザーが管理者かどうか
  def current_user_is_admin?
    current_teacher&.admin?
  end
end
