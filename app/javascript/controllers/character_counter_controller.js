import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["input", "counter"];
  static values = { min: Number, max: Number };

  connect() {
    this.updateCount();
  }

  updateCount() {
    const text = this.inputTarget.value;
    const count = text.length;

    this.counterTarget.textContent = count;

    // 文字数に応じてスタイルを変更
    if (count < this.minValue) {
      this.counterTarget.className = "text-red-600";
    } else if (count > this.maxValue) {
      this.counterTarget.className = "text-red-600";
    } else {
      this.counterTarget.className = "text-green-600";
    }
  }
}
