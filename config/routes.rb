# Railsルーティング設定の詳細解説

Rails.application.routes.draw do
  # 面談枠設定（講師用）
  resources :time_slots, only: [:index, :create, :update, :destroy] do
    collection do
      get :weekly, to: 'time_slots#weekly'
      post :bulk_update, to: 'time_slots#bulk_update'
    end
  end

  # 統合ログイン（管理者・教師）
  # ↑ コメント：管理者と教師が共通で使用するログイン機能の説明

  get 'staff/login', to: 'auth#staff_login', as: 'staff_login'
  # ↑ GETリクエスト用のルート設定
  # 'staff/login' → URLパス（http://domain.com/staff/login）
  # to: 'auth#staff_login' → AuthControllerのstaff_loginアクションにルーティング
  # as: 'staff_login' → ヘルパーメソッド名（staff_login_pathで参照可能）

  post 'staff/login', to: 'auth#staff_authenticate'
  # ↑ POSTリクエスト用のルート設定（ログインフォーム送信時）
  # 同じ'staff/login'URLでもHTTPメソッドがPOSTの場合
  # AuthControllerのstaff_authenticateアクションで処理
  # asオプションなし → デフォルトのヘルパー名を使用

  get 'staff/dashboard', to: 'auth#staff_dashboard', as: 'staff_dashboard'
  # ↑ 講師・管理者用ダッシュボード画面
  # ログイン後のメイン画面

  delete 'staff/logout', to: 'auth#staff_logout', as: 'staff_logout'
  get 'staff/logout', to: 'auth#staff_logout'
  # ↑ ログアウト用のルート設定（DELETEとGETの両方に対応）
  # AuthControllerのstaff_logoutアクションで処理

  # 代理予約機能
  get 'staff/proxy_booking', to: 'auth#proxy_booking', as: 'proxy_booking'
  post 'staff/create_proxy_appointment', to: 'auth#create_proxy_appointment', as: 'create_proxy_appointment'
  
  # 面談記録機能
  get 'staff/appointments/:id/interview_record', to: 'auth#interview_record', as: 'interview_record'
  patch 'staff/appointments/:id/interview_record', to: 'auth#save_interview_record', as: 'save_interview_record'

  # 面談記録モーダル用のルート
  get 'staff/appointments/:id/interview_record_modal', to: 'auth#show_interview_record_modal', as: 'show_interview_record_modal'
  patch 'staff/appointments/:id/interview_record_modal', to: 'auth#save_interview_record_in_modal', as: 'save_interview_record_in_modal'

  # 生徒管理機能（講師・管理者共通）
  get 'staff/students', to: 'auth#students_index', as: 'staff_students'
  get 'staff/students/new', to: 'auth#students_new', as: 'new_staff_student'
  
  # CSV インポート・エクスポート機能（:idより前に配置）
  get 'staff/students/export', to: 'auth#students_export', as: 'export_staff_students'
  post 'staff/students/import', to: 'auth#students_import', as: 'import_staff_students'
  
  # 生徒一括操作
  post 'staff/students/bulk_assign_teacher', to: 'auth#bulk_assign_teacher', as: 'bulk_assign_teacher'
  
  post 'staff/students', to: 'auth#students_create', as: 'create_staff_student'
  get 'staff/students/:id', to: 'auth#students_show', as: 'staff_student'
  get 'staff/students/:id/edit', to: 'auth#students_edit', as: 'edit_staff_student'
  patch 'staff/students/:id', to: 'auth#students_update', as: 'update_staff_student'
  delete 'staff/students/:id', to: 'auth#students_destroy', as: 'destroy_staff_student'

  # 講師管理機能（管理者のみ）
  get 'staff/teachers', to: 'auth#teachers_index', as: 'staff_teachers'
  get 'staff/teachers/new', to: 'auth#teachers_new', as: 'new_staff_teacher'
  post 'staff/teachers', to: 'auth#teachers_create', as: 'create_staff_teacher'
  get 'staff/teachers/:id', to: 'auth#teachers_show', as: 'staff_teacher'
  get 'staff/teachers/:id/edit', to: 'auth#teachers_edit', as: 'edit_staff_teacher'
  patch 'staff/teachers/:id', to: 'auth#teachers_update', as: 'update_staff_teacher'
  delete 'staff/teachers/:id', to: 'auth#teachers_destroy', as: 'destroy_staff_teacher'

  # Devise認証ルーティング
  # ↑ コメント：Deviseを使用した各種ユーザー認証の設定

  # シンプルな生徒認証（Devise不使用）
  get 'student/login', to: 'students#login', as: 'student_login'
  post 'student/login', to: 'students#authenticate'
  delete 'student/logout', to: 'students#logout', as: 'student_logout'
  
  # 生徒用ダッシュボード
  get 'student/dashboard', to: 'students#dashboard', as: 'student_dashboard'
  
  # 生徒用講師一覧
  get 'student/teachers', to: 'students#teachers', as: 'student_teachers'
  
  # 生徒用予約機能
  get 'student/teachers/:teacher_id/booking', to: 'students#booking', as: 'student_teacher_booking'
  post 'student/appointments', to: 'students#create_appointment', as: 'student_appointments'
  get 'student/appointments', to: 'students#appointments', as: 'student_appointments_list'
  delete 'student/appointments/:id', to: 'students#cancel_appointment', as: 'student_cancel_appointment'
  # JSON API用の予約削除ルート
  delete 'student/api/appointments/:id', to: 'students#destroy_appointment', as: 'student_destroy_appointment_api'

  # 以下は削除（シンプル版では不要）
  # devise_for :students, path: 'student', path_names: {
  #   sign_in: 'login',
  #   sign_out: 'logout',
  #   sign_up: 'register'
  # }, controllers: {
  #   sessions: 'students/sessions'
  # }

  get "up" => "rails/health#show", as: :rails_health_check
  # ↑ ヘルスチェック用のルート
  # get "up" → /upへのGETリクエスト
  # => "rails/health#show" → Rails内蔵のヘルスチェック機能
  # as: :rails_health_check → rails_health_check_pathヘルパーを生成
  # サーバーの稼働状況を確認するためのエンドポイント

  root "home#index"
  # ↑ ルートURL（/）の設定
  # root → アプリケーションのトップページ
  # "home#index" → HomeControllerのindexアクションにルーティング
  # 自動的にroot_pathヘルパーを生成

  # Home routes
  # ↑ コメント：ホーム関連のルート設定

  get "home", to: "home#index"
  # ↑ /homeへのGETリクエストの設定
  # to: "home#index" → HomeControllerのindexアクションにルーティング
  # rootと同じアクションを指定（/と/homeが同じページを表示）
  # 自動的にhome_pathヘルパーを生成
end
# ↑ ルーティング設定の終了

# 【生成される主要なURL一覧】
# 統合ログイン:
#   GET  /staff/login     → ログイン画面表示
#   POST /staff/login     → ログイン処理
#   GET  /staff/dashboard → ダッシュボード画面
#   DELETE /staff/logout  → ログアウト

# 学生用Devise:
#   GET  /student/login     → 学生ログイン画面
#   POST /student/login     → 学生ログイン処理
#   DELETE /student/logout  → 学生ログアウト
#   GET  /student/register  → 学生登録画面
#   POST /student/register  → 学生登録処理
#   GET  /student/dashboard → 学生ダッシュボード画面

# その他:
#   GET / → トップページ
#   GET /home → ホームページ（トップページと同じ）
#   GET /up → ヘルスチェック

# 【設計上の特徴】
# 1. 役割別の明確なURL構造（/student/、/staff/）
# 2. 統合ログイン機能で利便性向上
# 3. Deviseの個別ログインも維持（選択肢を提供）
# 4. 日本語に親しみやすいURL名（login、logout、dashboard）