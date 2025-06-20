import { Controller } from "@hotwired/stimulus";

// Stimulusコントローラーのクラス定義（面談枠の作成・削除を担当）
// data-controller="time-slots" がついた要素で動作する
export default class extends Controller {
  // 通知メッセージ用のDOM要素を定義（使用していないが将来の拡張用）
  static targets = ["notification", "notificationIcon", "notificationMessage"];

  // コントローラーが接続された時に実行される初期化メソッド
  connect() {
    // CSRF（Cross-Site Request Forgery）攻撃防止用のトークンを取得
    // Railsではフォーム送信時にこのトークンが必要
    this.csrfToken = document
      .querySelector('meta[name="csrf-token"]') // HTMLのmetaタグからトークンを取得
      ?.getAttribute("content"); // 安全にcontent属性を取得（存在しない場合はundefined）

    // 面談枠のクリックイベントを設定する関数を呼び出し
    this.setupTimeSlotClicks();
  }

  // 面談枠のクリックイベントを設定する関数
  setupTimeSlotClicks() {
    // data-clickable="true" がついた全ての要素を取得
    // これらの要素がクリック可能な面談枠セル
    const clickableCells = this.element.querySelectorAll(
      '[data-clickable="true"]'
    );

    // 取得した各セルに対してクリックイベントを設定
    clickableCells.forEach((cell) => {
      // クリックされた時の処理を定義
      cell.addEventListener("click", (event) => {
        // クリックされた要素（セル）を引数として処理関数を呼び出し
        this.handleTimeSlotClick(event.currentTarget);
      });
    });
  }

  // 面談枠がクリックされた時の処理を行う関数
  handleTimeSlotClick(cell) {
    // クリックされたセルのdata属性から必要な情報を取得
    const date = cell.dataset.date; // 日付（例：2025-01-15）
    const time = cell.dataset.time; // 時刻（例：14:00）
    const campusId = cell.dataset.campusId; // 校舎ID
    const existingId = cell.dataset.existingId; // 既存の面談枠ID（ある場合）
    const currentStatus = cell.dataset.currentStatus; // 現在のステータス

    // 校舎が選択されていない場合のエラーハンドリング
    if (!campusId) {
      // エラーメッセージを表示して処理を中断
      this.showNotification("error", "校舎を選択してください");
      return;
    }

    // 別校舎で設定済みの場合をチェック
    // セル内のテキストに他校舎の設定が含まれているかチェック
    const statusSymbolEl = cell.querySelector("div:last-child"); // セル内の最後のdiv要素（シンボル表示部分）
    const cellContent = statusSymbolEl ? statusSymbolEl.textContent.trim() : ""; // テキスト内容を取得

    // 他校舎の設定が表示されているが、選択校舎では未設定の場合
    if (
      cellContent && // セルに何かしらの内容がある
      cellContent !== "" && // 空文字ではない
      cellContent !== "○" && // 単純な予約可能マークではない
      cellContent !== "×" && // 単純な利用不可マークではない
      currentStatus === "none" // 選択校舎では未設定
    ) {
      // 確認メッセージを表示
      this.showNotification(
        "info",
        "他校舎で面談枠が設定されています。この校舎でも設定する場合はもう一度クリックしてください。"
      );

      // 確認フラグを設定（次回クリック時に実際の処理を実行するため）
      cell.dataset.confirmOtherCampus = "true";
      return; // 処理を中断
    }

    // 確認済みの場合はフラグをクリア
    if (cell.dataset.confirmOtherCampus === "true") {
      cell.dataset.confirmOtherCampus = "false";
    }

    // ローディング状態を表示（処理中であることをユーザーに示す）
    cell.style.opacity = "0.5"; // 半透明にする
    cell.style.pointerEvents = "none"; // クリックを無効にする

    // 現在のステータスに応じて処理を分岐
    if (currentStatus === "none") {
      // 新規作成の場合
      this.createTimeSlot(date, time, campusId, cell);
    } else {
      // 既存の削除の場合
      this.deleteTimeSlot(existingId, cell);
    }
  }

  // 面談枠を新規作成する関数
  createTimeSlot(date, time, campusId, cell) {
    // フォームデータを作成（サーバーに送信するデータ）
    const formData = new FormData();
    formData.append("time_slot[date]", date); // 日付
    formData.append("time_slot[start_time]", time); // 開始時刻
    formData.append("time_slot[campus_id]", campusId); // 校舎ID
    formData.append("time_slot[status]", "available"); // ステータス（予約可能）

    // サーバーにPOSTリクエストを送信
    fetch("/time_slots", {
      method: "POST", // HTTPメソッド
      headers: {
        "X-CSRF-Token": this.csrfToken, // CSRF防止トークン
        Accept: "application/json", // JSONレスポンスを期待
      },
      body: formData, // 送信データ
    })
      .then((response) => response.json()) // レスポンスをJSONに変換
      .then((data) => {
        // サーバーからのレスポンスを処理
        if (data.status === "success") {
          // 成功の場合：セルの見た目を更新
          this.updateCellAppearance(
            cell, // 対象のセル
            "available", // 新しいステータス
            data.slot.id, // 作成された面談枠のID
            data.slot.campus_display // 校舎の短縮表示名
          );
          // 成功メッセージは表示しない（UIの邪魔にならないように）
        } else {
          // エラーの場合：エラーメッセージを表示
          this.showNotification("error", data.message);
        }
      })
      .catch((error) => {
        // 通信エラーの場合の処理
        console.error("Error:", error); // コンソールにエラーログを出力
        this.showNotification("error", "通信エラーが発生しました");
      })
      .finally(() => {
        // 成功・失敗に関わらず最後に実行される処理
        // ローディング状態を解除
        cell.style.opacity = "1"; // 透明度を元に戻す
        cell.style.pointerEvents = "auto"; // クリックを有効にする
      });
  }

  // 面談枠を削除する関数
  deleteTimeSlot(slotId, cell) {
    // サーバーにDELETEリクエストを送信
    fetch(`/time_slots/${slotId}`, {
      method: "DELETE", // HTTPメソッド
      headers: {
        "X-CSRF-Token": this.csrfToken, // CSRF防止トークン
        Accept: "application/json", // JSONレスポンスを期待
      },
    })
      .then((response) => response.json()) // レスポンスをJSONに変換
      .then((data) => {
        // サーバーからのレスポンスを処理
        if (data.status === "success") {
          // 成功の場合：セルの見た目を更新（削除する校舎名を渡す）
          const campusName = cell.dataset.campusName; // 削除対象の校舎名を取得
          this.updateCellAppearance(cell, "none", null, null, campusName);
          // 成功メッセージは表示しない（UIの邪魔にならないように）
        } else {
          // エラーの場合：エラーメッセージを表示
          this.showNotification("error", data.message);
        }
      })
      .catch((error) => {
        // 通信エラーの場合の処理
        console.error("Error:", error); // コンソールにエラーログを出力
        this.showNotification("error", "通信エラーが発生しました");
      })
      .finally(() => {
        // 成功・失敗に関わらず最後に実行される処理
        // ローディング状態を解除
        cell.style.opacity = "1"; // 透明度を元に戻す
        cell.style.pointerEvents = "auto"; // クリックを有効にする
      });
  }

  // セルの見た目を更新する関数（作成・削除後の表示を変更）
  updateCellAppearance(
    cell, // 対象のセル
    status, // 新しいステータス
    slotId, // 面談枠ID
    campusDisplay, // 校舎の短縮表示名
    campusNameToRemove // 削除する校舎名（削除時のみ使用）
  ) {
    // 既存のTailwind CSSクラスを削除（色やボーダーのクラス）
    cell.className = cell.className
      .replace(/bg-\w+-\d+/g, "") // 背景色クラスを削除
      .replace(/border-\w+-\d+/g, "") // ボーダー色クラスを削除
      .replace(/hover:bg-\w+-\d+/g, ""); // ホバー時の背景色クラスを削除

    // ステータスシンボル要素を取得（新しい構造に対応）
    const statusSymbolEl = cell.querySelector("div:last-child");

    if (status === "available") {
      // 予約可能状態の場合の処理

      // 緑色のスタイルを適用
      cell.className += " bg-green-100 border-green-300 hover:bg-green-200";

      if (statusSymbolEl && campusDisplay) {
        // シンボル表示の更新処理

        // 既存の他校舎の表示がある場合はそれを保持し、新しい校舎の設定を追加
        const currentContent = statusSymbolEl.textContent.trim(); // 現在の表示内容
        let newContent = ""; // 新しい表示内容

        if (currentContent && !currentContent.includes(campusDisplay)) {
          // 他校舎の設定がある場合は追加（例：鳳● → 鳳● 三国○）
          newContent = `${currentContent} ${campusDisplay}○`;
        } else if (currentContent.includes(campusDisplay)) {
          // 既に同じ校舎の設定がある場合は更新（例：三国× → 三国○）
          newContent = currentContent.replace(
            new RegExp(`${campusDisplay}[○●×]`), // 正規表現で既存の校舎設定を検索
            `${campusDisplay}○` // 新しい設定で置換
          );
        } else {
          // 新規設定の場合（例：空 → 三国○）
          newContent = `${campusDisplay}○`;
        }

        // 更新した内容を表示
        statusSymbolEl.textContent = newContent;
      }

      // ツールチップとデータ属性を更新
      cell.title = "予約可能（クリックで解除）";
      cell.dataset.existingId = slotId; // 面談枠IDを保存
      cell.dataset.currentStatus = "available"; // ステータスを更新
    } else if (status === "none") {
      // 未設定状態の場合の処理

      // グレーのスタイルを適用
      cell.className += " bg-gray-50 border-gray-300 hover:bg-green-100";

      if (statusSymbolEl && campusNameToRemove) {
        // 削除時：該当校舎の表示のみを削除し、他校舎の表示は保持

        const currentContent = statusSymbolEl.textContent.trim(); // 現在の表示内容
        if (currentContent) {
          // 校舎名から短縮名を生成（TimeSlotモデルのcampus_displayと同じロジック）
          const campusShortName = this.getCampusShortName(campusNameToRemove);

          // 該当校舎の表示を削除（正規表現を使用）
          let newContent = currentContent
            .replace(new RegExp(`\\s*${campusShortName}[○●×]`, "g"), "") // 中間や末尾の削除
            .replace(new RegExp(`^${campusShortName}[○●×]\\s*`, "g"), "") // 先頭の削除
            .trim(); // 余分な空白を削除

          // 更新した内容を表示
          statusSymbolEl.textContent = newContent;
        }
      }

      // ツールチップとデータ属性を更新
      cell.title = "未設定（クリックで予約可能に設定）";
      cell.dataset.existingId = ""; // 面談枠IDをクリア
      cell.dataset.currentStatus = "none"; // ステータスを更新
    }
  }

  // 校舎名から短縮名を生成する関数（TimeSlotモデルのcampus_displayと同じロジック）
  getCampusShortName(campusName) {
    // 校舎名が存在しない場合は空文字を返す
    if (!campusName) return "";

    // 各校舎名に応じて短縮名を生成
    if (
      campusName.includes("三国") &&
      (campusName.includes("本部") || campusName.includes("三国ヶ丘本部"))
    ) {
      return "三国"; // 三国ヶ丘本部校 → 三国
    } else if (campusName.includes("鳳駅前") || campusName.includes("鳳")) {
      return "鳳"; // 鳳駅前校 → 鳳
    } else if (
      campusName.includes("泉ヶ丘駅前") ||
      campusName.includes("泉ヶ丘")
    ) {
      return "泉ヶ丘"; // 泉ヶ丘駅前校 → 泉ヶ丘
    } else if (campusName.includes("岸和田")) {
      return "岸和田"; // 岸和田校 → 岸和田
    } else {
      // フォールバック：最初の3文字を使用
      return campusName.slice(0, 3);
    }
  }

  // 通知メッセージを表示する関数
  showNotification(type, message) {
    // 通知用のDOM要素を取得
    const notification = document.getElementById("notification");
    const icon = document.getElementById("notification-icon");
    const messageEl = document.getElementById("notification-message");

    // メッセージタイプに応じてアイコンを設定
    if (type === "success") {
      // 成功時：緑色のチェックマークアイコン
      icon.innerHTML =
        '<svg class="w-5 h-5 text-green-500" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"></path></svg>';
    } else if (type === "info") {
      // 情報時：青色の情報アイコン
      icon.innerHTML =
        '<svg class="w-5 h-5 text-blue-500" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd"></path></svg>';
    } else {
      // エラー時：赤色のXマークアイコン
      icon.innerHTML =
        '<svg class="w-5 h-5 text-red-500" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd"></path></svg>';
    }

    // メッセージテキストを設定
    messageEl.textContent = message;

    // 通知を表示（hiddenクラスを削除）
    notification.classList.remove("hidden");

    // 3秒後に自動で非表示にする
    setTimeout(() => {
      notification.classList.add("hidden");
    }, 3000);
  }
}
