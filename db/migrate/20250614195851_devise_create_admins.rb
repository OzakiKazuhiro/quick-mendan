# frozen_string_literal: true

class DeviseCreateAdmins < ActiveRecord::Migration[8.0]
  def change
    create_table :admins do |t|
      ## Database authenticatable
      t.string :user_login_name,    null: false, default: ""  # ログイン用名前
      t.string :email,              null: true                # 任意フィールドに変更
      t.string :encrypted_password, null: false, default: ""
      t.string :name,               null: false, default: ""  # 実名

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      # t.integer  :sign_in_count, default: 0, null: false
      # t.datetime :current_sign_in_at
      # t.datetime :last_sign_in_at
      # t.string   :current_sign_in_ip
      # t.string   :last_sign_in_ip

      ## Confirmable
      # t.string   :confirmation_token
      # t.datetime :confirmed_at
      # t.datetime :confirmation_sent_at
      # t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      # t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      # t.string   :unlock_token # Only if unlock strategy is :email or :both
      # t.datetime :locked_at


      t.timestamps null: false
    end

    add_index :admins, :user_login_name,      unique: true  # ログイン名での検索高速化 + 重複防止
    add_index :admins, :email,                unique: true  # メールアドレスでの検索高速化 + 重複防止
    add_index :admins, :reset_password_token, unique: true  # パスワードリセット用
    # add_index :admins, :confirmation_token,   unique: true
    # add_index :admins, :unlock_token,         unique: true
  end
end
