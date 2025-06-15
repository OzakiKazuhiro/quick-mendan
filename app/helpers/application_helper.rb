module ApplicationHelper
  # 現在ログインしている管理者を取得
  def current_admin
    @current_admin ||= session[:admin_id] && Admin.find_by(id: session[:admin_id])
  end
  
  # 現在ログインしている教師を取得
  def current_teacher
    @current_teacher ||= session[:teacher_id] && Teacher.find_by(id: session[:teacher_id])
    # 上記と同じ動作（展開形）
    # @current_admin = @current_admin || Admin.find_by(id: session[:admin_id])
  end

  # @current_adminは最初はnil
  # @current_admin  # => nil
 # ||= により、右側が実行される
# session[:admin_id] && Admin.find_by(id: session[:admin_id])
# 例：session[:admin_id] = 1 の場合
# Admin.find_by(id: 1) が実行され、Adminオブジェクトを取得
  # @current_adminに保存
  # @current_admin  # => #<Admin id:1, name:"田中太郎">


  # 現在ログインしているスタッフ（管理者または教師）を取得
  def current_staff_user
    current_admin || current_teacher
  end
  
  # 管理者がログインしているかチェック
  def admin_signed_in?
    current_admin.present?
  end
  
  # 教師がログインしているかチェック
  def teacher_signed_in?
    current_teacher.present?
  end
  
  # スタッフ（管理者または教師）がログインしているかチェック
  def staff_signed_in?
    current_staff_user.present?
  end
end
