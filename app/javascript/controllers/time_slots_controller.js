import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="time-slots"
export default class extends Controller {
  static targets = ["notification", "notificationIcon", "notificationMessage"];

  connect() {
    // CSRF トークンを取得
    this.csrfToken = document
      .querySelector('meta[name="csrf-token"]')
      ?.getAttribute("content");

    // 面談枠のクリックイベントを設定
    this.setupTimeSlotClicks();
  }

  // 面談枠のクリックイベントを設定
  setupTimeSlotClicks() {
    const clickableCells = this.element.querySelectorAll(
      '[data-clickable="true"]'
    );

    clickableCells.forEach((cell) => {
      cell.addEventListener("click", (event) => {
        this.handleTimeSlotClick(event.currentTarget);
      });
    });
  }

  // 面談枠クリック処理
  handleTimeSlotClick(cell) {
    const date = cell.dataset.date;
    const time = cell.dataset.time;
    const campusId = cell.dataset.campusId;
    const existingId = cell.dataset.existingId;
    const currentStatus = cell.dataset.currentStatus;

    // 校舎が選択されていない場合
    if (!campusId) {
      this.showNotification("error", "校舎を選択してください");
      return;
    }

    // 別校舎で設定済みの場合をチェック
    // セル内のテキストに他校舎の設定が含まれているかチェック
    const statusSymbolEl = cell.querySelector("div:last-child");
    const cellContent = statusSymbolEl ? statusSymbolEl.textContent.trim() : "";

    // 他校舎の設定が表示されているが、選択校舎では未設定の場合
    if (
      cellContent &&
      cellContent !== "" &&
      cellContent !== "○" &&
      cellContent !== "×" &&
      currentStatus === "none"
    ) {
      this.showNotification(
        "info",
        "他校舎で面談枠が設定されています。この校舎でも設定する場合はもう一度クリックしてください。"
      );

      // 確認フラグを設定
      cell.dataset.confirmOtherCampus = "true";
      return;
    }

    // 確認済みの場合はフラグをクリア
    if (cell.dataset.confirmOtherCampus === "true") {
      cell.dataset.confirmOtherCampus = "false";
    }

    // ローディング状態を表示
    cell.style.opacity = "0.5";
    cell.style.pointerEvents = "none";

    if (currentStatus === "none") {
      // 新規作成
      this.createTimeSlot(date, time, campusId, cell);
    } else {
      // 既存の削除
      this.deleteTimeSlot(existingId, cell);
    }
  }

  // 面談枠作成
  createTimeSlot(date, time, campusId, cell) {
    const formData = new FormData();
    formData.append("time_slot[date]", date);
    formData.append("time_slot[start_time]", time);
    formData.append("time_slot[campus_id]", campusId);
    formData.append("time_slot[status]", "available");

    fetch("/time_slots", {
      method: "POST",
      headers: {
        "X-CSRF-Token": this.csrfToken,
        Accept: "application/json",
      },
      body: formData,
    })
      .then((response) => response.json())
      .then((data) => {
        if (data.status === "success") {
          // セルの見た目を更新
          this.updateCellAppearance(cell, "available", data.slot.id);
          this.showNotification("success", data.message);
        } else {
          this.showNotification("error", data.message);
        }
      })
      .catch((error) => {
        console.error("Error:", error);
        this.showNotification("error", "通信エラーが発生しました");
      })
      .finally(() => {
        // ローディング状態を解除
        cell.style.opacity = "1";
        cell.style.pointerEvents = "auto";
      });
  }

  // 面談枠削除
  deleteTimeSlot(slotId, cell) {
    fetch(`/time_slots/${slotId}`, {
      method: "DELETE",
      headers: {
        "X-CSRF-Token": this.csrfToken,
        Accept: "application/json",
      },
    })
      .then((response) => response.json())
      .then((data) => {
        if (data.status === "success") {
          // セルの見た目を更新
          this.updateCellAppearance(cell, "none", null);
          this.showNotification("success", data.message);
        } else {
          this.showNotification("error", data.message);
        }
      })
      .catch((error) => {
        console.error("Error:", error);
        this.showNotification("error", "通信エラーが発生しました");
      })
      .finally(() => {
        // ローディング状態を解除
        cell.style.opacity = "1";
        cell.style.pointerEvents = "auto";
      });
  }

  // セルの見た目を更新
  updateCellAppearance(cell, status, slotId) {
    // 既存のクラスを削除
    cell.className = cell.className
      .replace(/bg-\w+-\d+/g, "")
      .replace(/border-\w+-\d+/g, "")
      .replace(/hover:bg-\w+-\d+/g, "");

    // ステータスシンボル要素を取得（新しい構造に対応）
    const statusSymbolEl = cell.querySelector("div:last-child");

    if (status === "available") {
      cell.className += " bg-green-100 border-green-300 hover:bg-green-200";
      if (statusSymbolEl) {
        statusSymbolEl.textContent = "○";
      }
      cell.title = "予約可能（クリックで解除）";
      cell.dataset.existingId = slotId;
      cell.dataset.currentStatus = "available";
    } else if (status === "none") {
      cell.className += " bg-gray-50 border-gray-300 hover:bg-green-100";
      if (statusSymbolEl) {
        statusSymbolEl.textContent = "";
      }
      cell.title = "未設定（クリックで予約可能に設定）";
      cell.dataset.existingId = "";
      cell.dataset.currentStatus = "none";
    }
  }

  // 通知メッセージを表示
  showNotification(type, message) {
    const notification = document.getElementById("notification");
    const icon = document.getElementById("notification-icon");
    const messageEl = document.getElementById("notification-message");

    // アイコンを設定
    if (type === "success") {
      icon.innerHTML =
        '<svg class="w-5 h-5 text-green-500" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"></path></svg>';
    } else if (type === "info") {
      icon.innerHTML =
        '<svg class="w-5 h-5 text-blue-500" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd"></path></svg>';
    } else {
      icon.innerHTML =
        '<svg class="w-5 h-5 text-red-500" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd"></path></svg>';
    }

    messageEl.textContent = message;
    notification.classList.remove("hidden");

    // 3秒後に自動で非表示
    setTimeout(() => {
      notification.classList.add("hidden");
    }, 3000);
  }
}
