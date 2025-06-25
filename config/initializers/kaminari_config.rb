# frozen_string_literal: true

Kaminari.configure do |config|
  # デフォルトの1ページあたりの件数
  config.default_per_page = 20
  # 最大表示件数（nil = 制限なし）
  # config.max_per_page = nil
  # 現在のページの前後に表示するページ数
  config.window = 2
  # 最初と最後のページ周辺に表示するページ数
  config.outer_window = 1
  # 左端に表示するページ数
  # config.left = 0
  # 右端に表示するページ数
  # config.right = 0
  # ページメソッド名
  # config.page_method_name = :page
  # パラメータ名
  # config.param_name = :page
  # 最大ページ数（nil = 制限なし）
  # config.max_pages = nil
  # 最初のページでもパラメータを含めるか
  # config.params_on_first_page = false
end
