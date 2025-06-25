# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

# リマインダーメール送信チェック（14時〜22時まで1時間おき）
# 営業時間に合わせて設定（講師の設定可能時間と同じ）
every 1.hour, at: [14, 15, 16, 17, 18, 19, 20, 21, 22] do
  rake "reminder:check_and_send"
end

# 設定例：
# 14:00, 15:00, 16:00, 17:00, 18:00, 19:00, 20:00, 21:00, 22:00 に実行
# 
# 各時刻に以下の処理を実行：
# 1. 現在時刻（例：18時）にリマインダー設定している講師を検索
# 2. 該当講師の翌日面談予定をチェック
# 3. 面談予定がある場合のみメール送信
# 4. ログ出力とエラーハンドリング

# ログ出力先を設定（開発環境用）
set :output, "#{path}/log/cron.log"

# 環境変数を設定
set :environment, :development 