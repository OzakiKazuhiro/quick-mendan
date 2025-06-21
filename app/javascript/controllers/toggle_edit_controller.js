import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["view", "form"];

  show() {
    this.viewTarget.classList.add("hidden");
    this.formTarget.classList.remove("hidden");
  }

  hide() {
    this.viewTarget.classList.remove("hidden");
    this.formTarget.classList.add("hidden");
  }
}
