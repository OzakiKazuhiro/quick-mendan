import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["modal", "confirmButton", "cancelButton", "studentName"];
  static values = {
    studentName: String,
    studentId: Number,
  };

  connect() {
    // モーダルが表示された時の処理
    this.modalTarget.addEventListener("click", (e) => {
      if (e.target === this.modalTarget) {
        this.close();
      }
    });

    // ESCキーでモーダルを閉じる
    document.addEventListener("keydown", (e) => {
      if (
        e.key === "Escape" &&
        !this.modalTarget.classList.contains("hidden")
      ) {
        this.close();
      }
    });
  }

  open(event) {
    event.preventDefault();

    // 生徒名とIDを設定
    const studentName = event.currentTarget.getAttribute("data-student-name");
    const studentId = event.currentTarget.getAttribute("data-student-id");

    this.studentNameValue = studentName;
    this.studentIdValue = studentId;

    // モーダル内の生徒名を更新
    this.studentNameTarget.textContent = studentName;

    // モーダルを表示
    this.modalTarget.classList.remove("hidden");
    document.body.classList.add("overflow-hidden");

    // 確認ボタンにフォーカス
    setTimeout(() => {
      this.confirmButtonTarget.focus();
    }, 100);
  }

  close() {
    this.modalTarget.classList.add("hidden");
    document.body.classList.remove("overflow-hidden");
  }

  confirm() {
    // 実際の削除リクエストを送信
    const form = document.createElement("form");
    form.method = "POST";
    form.action = `/staff/students/${this.studentIdValue}`;

    // メソッドオーバーライド
    const methodInput = document.createElement("input");
    methodInput.type = "hidden";
    methodInput.name = "_method";
    methodInput.value = "DELETE";
    form.appendChild(methodInput);

    // CSRFトークン
    const csrfToken = document.querySelector('meta[name="csrf-token"]');
    if (csrfToken) {
      const csrfInput = document.createElement("input");
      csrfInput.type = "hidden";
      csrfInput.name = "authenticity_token";
      csrfInput.value = csrfToken.getAttribute("content");
      form.appendChild(csrfInput);
    }

    document.body.appendChild(form);
    form.submit();
  }
}
