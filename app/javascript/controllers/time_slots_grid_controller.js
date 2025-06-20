import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="time-slots-grid"
export default class extends Controller {
  static targets = ["table", "tableHeader", "fixedHeader"];

  connect() {
    // 必要な要素が存在しない場合は処理を中止（エラー防止）
    if (
      !this.hasTableTarget ||
      !this.hasTableHeaderTarget ||
      !this.hasFixedHeaderTarget
    ) {
      return;
    }

    // イベントリスナーを設定
    this.handleScroll = this.handleScroll.bind(this);
    this.handleResize = this.handleResize.bind(this);

    window.addEventListener("scroll", this.handleScroll);
    window.addEventListener("resize", this.handleResize);

    // ページ読み込み直後にも一度チェック実行（初期状態の設定）
    this.handleScroll();
  }

  disconnect() {
    // イベントリスナーを削除（メモリリーク防止）
    window.removeEventListener("scroll", this.handleScroll);
    window.removeEventListener("resize", this.handleResize);
  }

  // 列幅を同期させる関数
  syncColumnWidths() {
    // 元のテーブルのヘッダー列を取得
    const originalHeaders = this.tableHeaderTarget.querySelectorAll("th");
    // 固定ヘッダーの列を取得
    const fixedHeaders = this.fixedHeaderTarget.querySelectorAll("th");

    // 各列の幅を元のテーブルから固定ヘッダーにコピー
    originalHeaders.forEach((originalHeader, index) => {
      if (fixedHeaders[index]) {
        // 元のヘッダーの実際の幅を取得
        const width = originalHeader.getBoundingClientRect().width;
        // 固定ヘッダーの対応する列に同じ幅を設定
        fixedHeaders[index].style.width = width + "px";
        fixedHeaders[index].style.minWidth = width + "px";
        fixedHeaders[index].style.maxWidth = width + "px";
      }
    });

    // 固定ヘッダーのテーブル全体の幅も同期
    const fixedTable = this.fixedHeaderTarget.querySelector("table");
    if (fixedTable) {
      const originalWidth = this.tableTarget.getBoundingClientRect().width;
      fixedTable.style.width = originalWidth + "px";
    }
  }

  // スクロール時の処理を定義する関数
  handleScroll() {
    // 各要素の画面上での位置を取得
    const tableRect = this.tableTarget.getBoundingClientRect(); // テーブル全体の位置とサイズ
    const headerRect = this.tableHeaderTarget.getBoundingClientRect(); // 元のヘッダーの位置とサイズ

    // 条件判定：ヘッダーを固定表示するかどうか決める
    // headerRect.top <= 0 → 元のヘッダーが画面上部を通り過ぎた
    // tableRect.bottom > 0 → テーブルの一部がまだ画面に見えている
    if (headerRect.top <= 0 && tableRect.bottom > 0) {
      // 条件を満たす場合：固定ヘッダーを表示する

      // 列幅を同期してからヘッダーを表示（ズレを防ぐ）
      this.syncColumnWidths();

      this.fixedHeaderTarget.classList.remove("hidden"); // 'hidden'クラスを削除して表示
    } else {
      // 条件を満たさない場合：固定ヘッダーを隠す
      this.fixedHeaderTarget.classList.add("hidden"); // 'hidden'クラスを追加して非表示
    }
  }

  // ウィンドウサイズが変更された時の処理（レスポンシブ対応）
  handleResize() {
    // リサイズ時は列幅を再計算
    if (!this.fixedHeaderTarget.classList.contains("hidden")) {
      this.syncColumnWidths();
    }
  }
}
