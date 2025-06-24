# 役割：全メールの共通設定
class ApplicationMailer < ActionMailer::Base
  default from: "noreply@quick-mendan.com"  # 送信者
  layout "mailer"  # メールのレイアウト
end

# 何をするファイル？
# 送信者のメールアドレス設定
# 全メールの共通設定