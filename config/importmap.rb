# Pin npm packages by running ./bin/importmap

# Rails アプリケーションのメインJavaScriptファイル
pin "application"

# Turboライブラリ（Rails 7のデフォルト）
pin "@hotwired/turbo-rails", to: "turbo.min.js"

# Stimulusライブラリ本体を読み込み（import { Controller } from "@hotwired/stimulus" で使用）
pin "@hotwired/stimulus", to: "stimulus.min.js"

# Stimulusコントローラーの自動読み込み機能（controllers/index.jsで使用）
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"

# app/javascript/controllers/ 配下のすべてのコントローラーファイルを自動登録
# 例：time_slots_controller.js → controllers/time_slots_controller として利用可能
pin_all_from "app/javascript/controllers", under: "controllers"
