# 役割：全メールの共通設定
class ApplicationMailer < ActionMailer::Base
  default from: Rails.application.credentials.smtp[:from_address]  # credentialsから送信者を取得
  layout "mailer"  # メールのレイアウト
end

# 何をするファイル？
# 送信者のメールアドレス設定（credentialsから取得）
# 全メールの共通設定