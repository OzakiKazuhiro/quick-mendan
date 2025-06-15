# Adminモデルの詳細解説
# クラス定義
class Admin < ApplicationRecord
  # ↑ Adminクラスを定義し、ApplicationRecordを継承
  # ApplicationRecordはRailsのモデルの基底クラス
  # これによりデータベースとの連携機能を使用可能になる

  # Deviseの設定
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  # ↑ Devise（認証gem）の機能を有効化
  # :database_authenticatable → データベースでの認証
  # :registerable → ユーザー登録機能
  # :recoverable → パスワードリセット機能
  # :rememberable → ログイン状態記憶機能
  # :validatable → メール・パスワードの基本バリデーション

  # バリデーション
  # user_login_nameのバリデーション
  validates :user_login_name, presence: true, uniqueness: true, 
            format: { with: /\A[a-zA-Z0-9_]+\z/, message: "英数字とアンダースコアのみ使用可能です" }
  # ↑ user_login_nameフィールドに対する3つのバリデーション
  # presence: true → 必須入力
  # uniqueness: true → 一意性（重複不可）
  # format: → 正規表現による文字種制限
  #   /\A[a-zA-Z0-9_]+\z/ → 英数字とアンダースコアのみ許可
  #   \A → 文字列の開始、\z → 文字列の終了

  # nameフィールドのバリデーション
  validates :name, presence: true
  # ↑ nameフィールドを必須入力に設定

  # emailフィールドのバリデーション
  validates :email, uniqueness: true, allow_blank: true
  # ↑ emailフィールドの一意性チェック
  # allow_blank: true → 空欄は許可（必須ではない）

  # Deviseでユーザー名認証を使用するための設定
  
  # emailを必須にしない設定
  def email_required?
    false
  end
  # ↑ Deviseのデフォルト動作を上書き
  # 通常Deviseはemailを必須とするが、ここでfalseを返して無効化

  # email変更検知を無効化
  def email_changed?
    false
  end
  # ↑ emailの変更を検知しないように設定
  # Deviseの内部処理でemailベースの処理をスキップ

  # email保存時の変更検知を無効化
  def will_save_change_to_email?
    false
  end
  # ↑ email保存時の変更チェックを無効化
  # Rails 5以降のDirty tracking機能に対応

  # ユーザー名でログインするための設定
  
  def self.find_for_database_authentication(login_conditions)
  # ↑ Deviseが認証時に呼び出すメソッドをオーバーライド
  # login_conditions → ログインフォームから送信された条件

    # 検索条件を複製
    search_conditions = login_conditions.dup
    # ↑ 元の条件を変更しないよう複製を作成

    # emailキーが存在するかチェック
    if (username_input = search_conditions.delete(:email))
    # ↑ :emailキーの値を取得し、同時にハッシュから削除
    # Deviseはデフォルトで:emailキーを使用するため

      # ユーザー名での検索実行
      where(search_conditions.to_h).where(["user_login_name = :username", { username: username_input }]).first
      # ↑ 2段階の検索
      # 1. search_conditions.to_h → 残りの条件で絞り込み
      # 2. user_login_nameで更に絞り込み
      # .first → 最初の1件を取得

    # user_login_nameキーが存在するかチェック
    elsif search_conditions.has_key?(:user_login_name)
    # ↑ 直接user_login_nameが指定された場合の処理

      # 通常の検索実行
      where(search_conditions.to_h).first
      # ↑ 与えられた条件で検索し、最初の1件を取得

    # 条件分岐とメソッド終了
    end
  end
# クラス定義終了
end

# 【このコードの全体的な目的】
# 1. 通常のメール認証ではなく、ユーザー名認証を実現
# 2. emailは任意項目、user_login_nameを認証に使用
# 3. Deviseの標準動作をカスタマイズして独自認証を実装