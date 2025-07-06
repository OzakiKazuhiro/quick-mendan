# 役割：全メールの共通設定
class ApplicationMailer < ActionMailer::Base
  default from: ENV['SMTP_FROM_ADDRESS'] || 'noreply@quick-mendan.com'  # 環境変数または固定値
  layout "mailer"  # メールのレイアウト
end

# 何をするファイル？
# 送信者のメールアドレス設定（環境変数から取得）
# 全メールの共通設定