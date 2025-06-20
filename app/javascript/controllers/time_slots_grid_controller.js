import { Controller } from "@hotwired/stimulus";

// Stimulusコントローラーのクラス定義（面談枠グリッドの固定ヘッダー機能を担当）
// data-controller="time-slots-grid" がついた要素で動作する
export default class extends Controller {
  // 操作対象となるDOM要素を定義
  static targets = ["table", "tableHeader", "fixedHeader"];

  // コントローラーが接続された時に実行される初期化メソッド
  connect() {
    // 必要な要素が存在しない場合は処理を中止（エラー防止）
    // hasTableTarget等はStimulusが自動生成するプロパティ
    if (
      !this.hasTableTarget || // メインテーブルが存在しない
      !this.hasTableHeaderTarget || // テーブルヘッダーが存在しない
      !this.hasFixedHeaderTarget // 固定ヘッダーが存在しない
    ) {
      return; // 処理を中断
    }

    // イベントリスナー関数をthisコンテキストにバインド
    // これにより、イベント内でthis.handleScrollのようにアクセス可能
    this.handleScroll = this.handleScroll.bind(this);
    this.handleResize = this.handleResize.bind(this);

    // ウィンドウのスクロールイベントにリスナーを追加
    window.addEventListener("scroll", this.handleScroll);
    // ウィンドウのリサイズイベントにリスナーを追加
    window.addEventListener("resize", this.handleResize);

    // ページ読み込み直後にも一度チェック実行（初期状態の設定）
    this.handleScroll();
  }

  // コントローラーが切断される時に実行されるクリーンアップメソッド
  disconnect() {
    // イベントリスナーを削除（メモリリーク防止）
    window.removeEventListener("scroll", this.handleScroll);
    window.removeEventListener("resize", this.handleResize);
  }

  // 列幅を同期させる関数（元のテーブルと固定ヘッダーの幅を合わせる）
  syncColumnWidths() {
    // 元のテーブルのヘッダー列を取得
    const originalHeaders = this.tableHeaderTarget.querySelectorAll("th");
    // 固定ヘッダーの列を取得
    const fixedHeaders = this.fixedHeaderTarget.querySelectorAll("th");

    // 各列の幅を元のテーブルから固定ヘッダーにコピー
    originalHeaders.forEach((originalHeader, index) => {
      // 対応する固定ヘッダーの列が存在するかチェック
      if (fixedHeaders[index]) {
        // 元のヘッダーの実際の幅を取得（ピクセル単位）
        const width = originalHeader.getBoundingClientRect().width;
        // 固定ヘッダーの対応する列に同じ幅を設定
        fixedHeaders[index].style.width = width + "px"; // 幅を設定
        fixedHeaders[index].style.minWidth = width + "px"; // 最小幅を設定
        fixedHeaders[index].style.maxWidth = width + "px"; // 最大幅を設定
      }
    });

    // 固定ヘッダーのテーブル全体の幅も同期
    const fixedTable = this.fixedHeaderTarget.querySelector("table");
    if (fixedTable) {
      // 元のテーブルの幅を取得
      const originalWidth = this.tableTarget.getBoundingClientRect().width;
      // 固定ヘッダーのテーブルに同じ幅を設定
      fixedTable.style.width = originalWidth + "px";
    }
  }

  // スクロール時の処理を定義する関数（固定ヘッダーの表示/非表示を制御）
  handleScroll() {
    // 各要素の画面上での位置とサイズを取得
    const tableRect = this.tableTarget.getBoundingClientRect(); // テーブル全体の位置とサイズ
    const headerRect = this.tableHeaderTarget.getBoundingClientRect(); // 元のヘッダーの位置とサイズ

    // 条件判定：固定ヘッダーを表示するかどうか決める
    // headerRect.top <= 0 → 元のヘッダーが画面上部を通り過ぎた（スクロールで隠れた）
    // tableRect.bottom > 0 → テーブルの一部がまだ画面に見えている
    if (headerRect.top <= 0 && tableRect.bottom > 0) {
      // 条件を満たす場合：固定ヘッダーを表示する

      // 列幅を同期してからヘッダーを表示（ズレを防ぐ）
      this.syncColumnWidths();

      // 'hidden'クラスを削除して固定ヘッダーを表示
      this.fixedHeaderTarget.classList.remove("hidden");
    } else {
      // 条件を満たさない場合：固定ヘッダーを隠す
      // 'hidden'クラスを追加して固定ヘッダーを非表示
      this.fixedHeaderTarget.classList.add("hidden");
    }
  }

  // ウィンドウサイズが変更された時の処理（レスポンシブ対応）
  handleResize() {
    // リサイズ時は列幅を再計算
    // 固定ヘッダーが表示されている場合のみ実行（パフォーマンス向上）
    if (!this.fixedHeaderTarget.classList.contains("hidden")) {
      this.syncColumnWidths();
    }
  }
}
