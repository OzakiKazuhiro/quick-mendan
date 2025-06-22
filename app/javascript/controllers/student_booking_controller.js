import { Controller } from "@hotwired/stimulus";

// 生徒の面談予約機能を管理するStimulusコントローラー
// このクラスは予約の作成・変更・削除を担当する
export default class extends Controller {
  // Stimulusのtargets機能：HTMLの特定の要素を参照するための名前を定義
  // data-student-booking-target="modal" のような属性で要素を指定できる
  static targets = [
    "modal", // 通常の予約モーダル（新規予約用）
    "modalDatetime", // モーダル内の日時表示エリア
    "modalCampus", // モーダル内の校舎表示エリア
    "appointmentNotes", // 予約時のメモ入力フィールド
    "changeModal", // 予約変更モーダル（既存予約がある場合）
    "currentBookingInfo", // 現在の予約情報表示エリア
    "newBookingInfo", // 新しい予約情報表示エリア
    "changeAppointmentNotes", // 予約変更時のメモ入力フィールド
  ];

  // Stimulusのvalues機能：HTMLのdata属性から値を受け取るための定義
  static values = {
    studentBookings: Object, // 生徒の既存予約情報（JSON形式）
    appointmentsPath: String, // 予約作成用のAPIエンドポイントURL
  };

  // Stimulusコントローラーが読み込まれた時に自動実行される初期化メソッド
  connect() {
    // CSRFトークンを取得
    // CSRFトークンはセキュリティ対策で、不正なリクエストを防ぐために必要
    this.csrfToken = document
      .querySelector('meta[name="csrf-token"]') // HTMLのmeta要素からCSRFトークンを取得
      ?.getAttribute("content"); // ?演算子でnullチェック（要素がない場合エラーを防ぐ）

    // 選択された時間枠のIDを保存する変数（初期値はnull）
    this.selectedSlotId = null;
    // 現在の予約ID（予約変更時に使用、初期値はnull）
    this.currentAppointmentId = null;
  }

  // 時間枠がクリックされた時の処理を行うアクション
  // HTMLで data-action="click->student-booking#handleCellClick" として使用
  handleCellClick(event) {
    // クリックされた時間枠の情報を取得
    // HTML要素のdata-*属性から値を取得
    const cell = event.currentTarget; // クリックされたセル要素を取得

    // data-*属性から予約に必要な情報を取得
    this.selectedSlotId = cell.dataset.slotId; // data-slot-id属性の値（時間枠ID）
    const date = cell.dataset.date; // data-date属性の値（日付）
    const time = cell.dataset.time; // data-time属性の値（時刻）
    const campus = cell.dataset.campus; // data-campus属性の値（校舎名）

    // 既存の予約があるかチェック
    // Object.keys()でオブジェクトのキーの配列を取得し、lengthで個数を確認
    // 0より大きければ既存予約あり、0なら既存予約なし
    const hasExistingBooking =
      Object.keys(this.studentBookingsValue).length > 0;

    // 既存予約の有無で処理を分岐
    if (hasExistingBooking) {
      // 既存予約がある場合：予約変更モーダルを表示
      this.showChangeModal(date, time, campus);
    } else {
      // 既存予約がない場合：通常の予約モーダルを表示
      this.showBookingModal(date, time, campus);
    }
  }

  // 通常の予約モーダルを表示するメソッド（新規予約用）
  showBookingModal(date, time, campus) {
    // querySelectorを使ってモーダル内の各要素を取得
    // モーダル内の日時表示エリアを取得
    const modalDatetime = document.querySelector(
      '[data-student-booking-target="modalDatetime"]'
    );
    // モーダル内の校舎表示エリアを取得
    const modalCampus = document.querySelector(
      '[data-student-booking-target="modalCampus"]'
    );
    // 予約時のメモ入力フィールドを取得
    const appointmentNotes = document.querySelector(
      '[data-student-booking-target="appointmentNotes"]'
    );
    // 予約モーダル本体を取得
    const modal = document.querySelector(
      '[data-student-booking-target="modal"]'
    );

    // 各要素に予約情報を設定
    if (modalDatetime) {
      // 日時情報を「2024-01-15 14:30〜」の形式で表示
      modalDatetime.textContent = `${date} ${time}〜`;
    } else {
      console.error("modalDatetime element not found!");
    }

    if (modalCampus) {
      // 校舎名を設定
      modalCampus.textContent = campus;
    } else {
      console.error("modalCampus element not found!");
    }

    if (appointmentNotes) {
      // メモ入力フィールドを空にする（前回の入力をクリア）
      appointmentNotes.value = "";
    } else {
      console.error("appointmentNotes element not found!");
    }

    // モーダルを表示
    if (modal) {
      // CSSクラスを操作してモーダルを表示
      modal.classList.remove("hidden"); // hiddenクラスを削除（非表示解除）
      modal.classList.add("flex"); // flexクラスを追加（表示）
    } else {
      console.error("modal element not found!");
    }
  }

  // 予約変更モーダルを表示するメソッド（既存予約がある場合）
  showChangeModal(date, time, campus) {
    // 既存予約の情報を取得
    // Object.values()でオブジェクトの値の配列を取得し、[0]で最初の要素を取得
    const existingBooking = Object.values(this.studentBookingsValue)[0];

    // 既存予約のIDを保存（削除時に使用）
    this.currentAppointmentId = existingBooking.id;

    // querySelectorを使って予約変更モーダル内の各要素を取得
    // 現在の予約情報表示エリアを取得
    const currentBookingInfo = document.querySelector(
      '[data-student-booking-target="currentBookingInfo"]'
    );
    // 新しい予約情報表示エリアを取得
    const newBookingInfo = document.querySelector(
      '[data-student-booking-target="newBookingInfo"]'
    );
    // 予約変更時のメモ入力フィールドを取得
    const changeAppointmentNotes = document.querySelector(
      '[data-student-booking-target="changeAppointmentNotes"]'
    );
    // 予約変更モーダル本体を取得
    const changeModal = document.querySelector(
      '[data-student-booking-target="changeModal"]'
    );

    // 現在の予約情報を設定
    if (currentBookingInfo) {
      // 既存予約の情報を「2024-01-15 14:30〜 @ 三国ヶ丘本部校」の形式で表示
      currentBookingInfo.textContent = `${existingBooking.date} ${existingBooking.time}〜 @ ${existingBooking.campus}`;
    } else {
      console.error("currentBookingInfo element not found!");
    }

    // 新しい予約情報を設定
    if (newBookingInfo) {
      // 新しい予約の情報を「2024-01-16 15:00〜 @ 泉ヶ丘駅前校」の形式で表示
      newBookingInfo.textContent = `${date} ${time}〜 @ ${campus}`;
    } else {
      console.error("newBookingInfo element not found!");
    }

    // 変更時のメモ入力フィールドを空にする
    if (changeAppointmentNotes) {
      changeAppointmentNotes.value = "";
    } else {
      console.error("changeAppointmentNotes element not found!");
    }

    // 予約変更モーダルを表示
    if (changeModal) {
      // CSSクラスを操作してモーダルを表示
      changeModal.classList.remove("hidden"); // hiddenクラスを削除（非表示解除）
      changeModal.classList.add("flex"); // flexクラスを追加（表示）
    } else {
      console.error("changeModal element not found!");
    }
  }

  // 通常予約モーダルをキャンセル（閉じる）するアクション
  // HTMLで data-action="click->student-booking#cancelBooking" として使用
  cancelBooking() {
    // IDで直接モーダルを取得（確実に動作する方法）
    const modal = document.getElementById("booking-modal");
    if (modal) {
      modal.classList.add("hidden");
      modal.classList.remove("flex");
    }
    // 選択された時間枠IDをリセット
    this.selectedSlotId = null;
  }

  // 新規予約を確定するアクション
  // HTMLで data-action="click->student-booking#confirmBooking" として使用
  confirmBooking() {
    // 時間枠が選択されていない場合は処理を中断
    if (!this.selectedSlotId) {
      return;
    }

    // 予約確定ボタンをローディング状態にする（連続クリック防止）
    this.setLoading("予約中...");

    // querySelectorを使ってメモ入力フィールドを取得
    const appointmentNotes = document.querySelector(
      '[data-student-booking-target="appointmentNotes"]'
    );
    // メモの値を取得（入力がない場合は空文字）
    const notesValue = appointmentNotes ? appointmentNotes.value : "";

    // 新規予約APIを呼び出し
    // fetch()はHTTPリクエストを送信するJavaScriptの関数
    fetch(this.appointmentsPathValue, {
      method: "POST", // POSTメソッドでデータを送信
      headers: {
        "Content-Type": "application/json", // JSON形式でデータを送信することを宣言
        "X-CSRF-Token": this.csrfToken, // CSRFトークンをヘッダーに追加（セキュリティ対策）
      },
      body: JSON.stringify({
        // JavaScriptオブジェクトをJSON文字列に変換して送信
        time_slot_id: this.selectedSlotId, // 選択された時間枠のID
        notes: notesValue, // メモ（入力があれば）
      }),
    })
      .then((response) => response.json()) // サーバーからのレスポンスをJSON形式で解析
      .then((data) => {
        // 解析されたデータを処理
        if (data.status === "success") {
          // サーバーから成功レスポンスが返ってきた場合
          alert(data.message); // 成功メッセージを表示
          window.location.reload(); // ページをリロードして最新状態に更新
        } else {
          // エラーレスポンスの場合
          alert(data.message); // エラーメッセージを表示
        }
      })
      .catch((error) => {
        // ネットワークエラーなどの例外処理
        console.error("Error:", error); // エラーをコンソールに出力
        alert("予約処理中にエラーが発生しました");
      })
      .finally(() => {
        // 成功・失敗に関わらず最後に実行される処理
        this.resetLoading("予約確定"); // ボタンを元の状態に戻す
        this.cancelBooking(); // モーダルを閉じる
      });
  }

  // 予約変更モーダルをキャンセル（閉じる）するアクション
  // HTMLで data-action="click->student-booking#cancelChangeBooking" として使用
  cancelChangeBooking() {
    // IDで直接モーダルを取得（確実に動作する方法）
    const changeModal = document.getElementById("change-booking-modal");
    if (changeModal) {
      changeModal.classList.add("hidden");
      changeModal.classList.remove("flex");
    }
    // 選択された時間枠IDと現在の予約IDをリセット
    this.selectedSlotId = null;
    this.currentAppointmentId = null;
  }

  // 予約変更を確定するアクション（既存予約削除 + 新規予約作成）
  // HTMLで data-action="click->student-booking#confirmChangeBooking" として使用
  confirmChangeBooking() {
    // 必要な情報が揃っていない場合は処理を中断
    if (!this.selectedSlotId || !this.currentAppointmentId) return;

    // 変更確定ボタンをローディング状態にする（連続クリック防止）
    this.setChangeLoading("変更中...");

    // querySelectorを使って変更時のメモ入力フィールドを取得
    const changeAppointmentNotes = document.querySelector(
      '[data-student-booking-target="changeAppointmentNotes"]'
    );
    // メモの値を取得（入力がない場合は空文字）
    const notesValue = changeAppointmentNotes
      ? changeAppointmentNotes.value
      : "";

    // 既存予約の削除と新規予約の作成を並行実行
    // Promise.all()は複数の非同期処理を同時に実行し、全て完了するまで待つ
    Promise.all([
      // 1. 既存予約を削除（JSON API）
      fetch(`/student/api/appointments/${this.currentAppointmentId}`, {
        method: "DELETE", // DELETEメソッドで削除リクエスト
        headers: {
          "X-CSRF-Token": this.csrfToken, // CSRFトークンを送信
        },
      }),
      // 2. 新規予約を作成
      fetch(this.appointmentsPathValue, {
        method: "POST", // POSTメソッドで作成リクエスト
        headers: {
          "Content-Type": "application/json", // JSON形式でデータを送信
          "X-CSRF-Token": this.csrfToken, // CSRFトークン
        },
        body: JSON.stringify({
          // 予約データをJSON形式で送信
          time_slot_id: this.selectedSlotId, // 新しい時間枠のID
          notes: notesValue, // メモ
        }),
      }),
    ])
      .then((responses) => {
        // 両方のAPIレスポンスを受け取る
        // レスポンスのステータスをチェック
        responses.forEach((response, index) => {
          if (!response.ok) {
            // HTTPステータスが200番台以外の場合（エラー）
            // エラーを投げて処理を中断
            throw new Error(
              `API ${index + 1} failed: ${response.status} ${
                response.statusText
              }`
            );
          }
        });

        // 両方のレスポンスをJSONとして解析
        // map()で配列の各要素に対してresponse.json()を実行
        return Promise.all(responses.map((r) => r.json()));
      })
      .then((results) => {
        // 解析されたJSONデータを受け取る
        // 配列の分割代入で削除結果と作成結果を取得
        const [deleteResult, createResult] = results;

        // 両方の処理が成功した場合のみ成功とする
        if (
          deleteResult.status === "success" &&
          createResult.status === "success"
        ) {
          alert("予約を変更しました"); // 成功メッセージ
          window.location.reload(); // ページリロード
        } else {
          // どちらかが失敗した場合
          // 三項演算子を使って失敗した処理を特定
          const errorMessage =
            deleteResult.status !== "success"
              ? `削除エラー: ${deleteResult.message}` // 削除が失敗
              : `作成エラー: ${createResult.message}`; // 作成が失敗
          alert(errorMessage);
        }
      })
      .catch((error) => {
        // エラーハンドリング
        console.error("Error:", error); // エラーをコンソールに出力
        alert("予約変更処理中にエラーが発生しました: " + error.message);
      })
      .finally(() => {
        // 処理完了後のクリーンアップ
        this.resetChangeLoading("予約変更"); // ボタンを元に戻す
        this.cancelChangeBooking(); // モーダルを閉じる
      });
  }

  // モーダル背景がクリックされた時の処理
  // HTMLで data-action="click->student-booking#closeOnBackdrop" として使用
  closeOnBackdrop(event) {
    // event.targetは実際にクリックされた要素
    // event.currentTargetはイベントリスナーが設定された要素
    if (event.target === event.currentTarget) {
      // 通常の予約モーダルかチェック
      const modal = document.querySelector(
        '[data-student-booking-target="modal"]'
      );
      if (modal && event.currentTarget === modal) {
        this.cancelBooking(); // 通常予約モーダルを閉じる
      }

      // 予約変更モーダルかチェック
      const changeModal = document.querySelector(
        '[data-student-booking-target="changeModal"]'
      );
      if (changeModal && event.currentTarget === changeModal) {
        this.cancelChangeBooking(); // 予約変更モーダルを閉じる
      }
    }
  }

  // 通常予約ボタンをローディング状態にするメソッド
  setLoading(text) {
    // querySelectorを使って予約確定ボタンを取得
    const confirmBtn = document.querySelector(
      '[data-action*="confirmBooking"]'
    );
    if (confirmBtn) {
      confirmBtn.disabled = true; // ボタンを無効化（クリック不可）
      confirmBtn.textContent = text; // ボタンのテキストを変更（例：「予約中...」）
    }
  }

  // 通常予約ボタンのローディング状態を解除するメソッド
  resetLoading(text) {
    // querySelectorを使って予約確定ボタンを取得
    const confirmBtn = document.querySelector(
      '[data-action*="confirmBooking"]'
    );
    if (confirmBtn) {
      confirmBtn.disabled = false; // ボタンを有効化（クリック可能）
      confirmBtn.textContent = text; // ボタンのテキストを元に戻す
    }
  }

  // 予約変更ボタンをローディング状態にするメソッド
  setChangeLoading(text) {
    // querySelectorを使って予約変更確定ボタンを取得
    const confirmChangeBtn = document.querySelector(
      '[data-action*="confirmChangeBooking"]'
    );
    if (confirmChangeBtn) {
      confirmChangeBtn.disabled = true; // ボタンを無効化（クリック不可）
      confirmChangeBtn.textContent = text; // ボタンのテキストを変更（例：「変更中...」）
    }
  }

  // 予約変更ボタンのローディング状態を解除するメソッド
  resetChangeLoading(text) {
    // querySelectorを使って予約変更確定ボタンを取得
    const confirmChangeBtn = document.querySelector(
      '[data-action*="confirmChangeBooking"]'
    );
    if (confirmChangeBtn) {
      confirmChangeBtn.disabled = false; // ボタンを有効化（クリック可能）
      confirmChangeBtn.textContent = text; // ボタンのテキストを元に戻す
    }
  }
}

// 生徒面談予約処理フロー
//     A[時間枠クリック] --> B{既存予約あり？}
//     B -->|なし| C[通常予約モーダル]
//     B -->|あり| D[予約変更モーダル]

//     C --> E[新規予約API]
//     E --> F[予約完了]

//     D --> G[Promise.all]
//     G --> H[削除API + 新規予約API]
//     H --> I{両方成功？}
//     I -->|Yes| J[予約変更完了]
//     I -->|No| K[エラー表示]
