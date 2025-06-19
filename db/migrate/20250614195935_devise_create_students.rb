# frozen_string_literal: true

class DeviseCreateStudents < ActiveRecord::Migration[8.0]
  def change
    create_table :students do |t|
      ## Database authenticatable
      t.string :student_number,     null: false, default: ""
      t.string :encrypted_password, null: false, default: ""
      t.string :name,               null: false, default: ""
      t.string :grade,              null: true                # 学年（任意・CSVインポート用）
      t.string :school_name,        null: true                # 高校名（任意・CSVインポート用）
      # t.references :campus, null: true, foreign_key: true    # 所属校舎（任意）- 多対多リレーション用に削除

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

    add_index :students, :student_number,       unique: true  # 生徒番号での検索高速化 + 重複防止
    add_index :students, :reset_password_token, unique: true  # パスワードリセット用
    # add_index :students, :confirmation_token,   unique: true
    # add_index :students, :unlock_token,         unique: true
  end
end
