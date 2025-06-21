import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["modal", "content"];

  connect() {
    this.modalTarget.addEventListener("click", (e) => {
      if (e.target === this.modalTarget) {
        this.close();
      }
    });

    document.addEventListener("keydown", (e) => {
      if (
        e.key === "Escape" &&
        !this.modalTarget.classList.contains("hidden")
      ) {
        this.close();
      }
    });
  }

  async open(event) {
    event.preventDefault();
    const appointmentId = event.currentTarget.dataset.appointmentId;
    const url = `/staff/appointments/${appointmentId}/interview_record_modal`;

    try {
      const response = await fetch(url, {
        headers: {
          "X-Requested-With": "XMLHttpRequest",
        },
      });
      if (!response.ok) throw new Error("Network response was not ok.");
      const html = await response.text();
      this.contentTarget.innerHTML = html;
      this.modalTarget.classList.remove("hidden");
      document.body.classList.add("overflow-hidden");
    } catch (error) {
      console.error("Could not fetch interview record:", error);
      alert("面談記録の読み込みに失敗しました。");
    }
  }

  async submitForm(event) {
    event.preventDefault();
    const form = event.target;
    const formData = new FormData(form);

    try {
      const response = await fetch(form.action, {
        method: form.method,
        body: formData,
        headers: {
          "X-Requested-With": "XMLHttpRequest",
          Accept:
            "text/vnd.turbo-stream.html, text/html, application/xhtml+xml",
        },
      });

      if (!response.ok) {
        const errorHtml = await response.text();
        this.contentTarget.innerHTML = errorHtml;
        throw new Error("Form submission failed.");
      }

      const newHtml = await response.text();
      this.contentTarget.innerHTML = newHtml;

      // 親コンポーネントに更新を通知（任意）
      this.dispatch("recordUpdated");
    } catch (error) {
      console.error("Could not submit form:", error);
      // エラーメッセージの表示などはここで調整
    }
  }

  close() {
    this.modalTarget.classList.add("hidden");
    document.body.classList.remove("overflow-hidden");
    this.contentTarget.innerHTML = ""; // モーダルを閉じる時に内容をクリア
  }
}
