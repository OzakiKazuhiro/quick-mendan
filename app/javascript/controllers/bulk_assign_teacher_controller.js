import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["toolbar", "studentIds", "selectedCount"];

  connect() {
    console.log("BulkAssignTeacher controller connected");
  }

  selectAll(event) {
    const selectAllCheckbox = event.target;
    const studentCheckboxes = this.element.querySelectorAll(
      'input[type="checkbox"][value]'
    );

    studentCheckboxes.forEach((checkbox) => {
      checkbox.checked = selectAllCheckbox.checked;
    });

    this.updateSelection();
  }

  selectStudent(event) {
    this.updateSelection();
  }

  updateSelection() {
    const selectedCheckboxes = this.element.querySelectorAll(
      'input[type="checkbox"][value]:checked'
    );
    const selectAllCheckbox = this.element.querySelector(
      'input[type="checkbox"]:not([value])'
    );

    if (selectedCheckboxes.length > 0) {
      this.showToolbar();
      this.updateStudentIds(selectedCheckboxes);
      this.updateSelectedCount(selectedCheckboxes.length);
    } else {
      this.hideToolbar();
    }

    // 全選択チェックボックスの状態を更新
    const allCheckboxes = this.element.querySelectorAll(
      'input[type="checkbox"][value]'
    );
    if (selectAllCheckbox) {
      selectAllCheckbox.checked =
        selectedCheckboxes.length === allCheckboxes.length;
      selectAllCheckbox.indeterminate =
        selectedCheckboxes.length > 0 &&
        selectedCheckboxes.length < allCheckboxes.length;
    }
  }

  showToolbar() {
    const toolbar = this.toolbarTarget;
    toolbar.classList.remove("hidden");
  }

  hideToolbar() {
    const toolbar = this.toolbarTarget;
    toolbar.classList.add("hidden");
  }

  updateStudentIds(selectedCheckboxes) {
    const studentIds = Array.from(selectedCheckboxes).map(
      (checkbox) => checkbox.value
    );
    this.studentIdsTarget.value = studentIds.join(",");
  }

  updateSelectedCount(count) {
    if (this.hasSelectedCountTarget) {
      this.selectedCountTarget.textContent = count;
    }
  }

  cancelSelection() {
    // 全てのチェックボックスを未選択にする
    const allCheckboxes = this.element.querySelectorAll(
      'input[type="checkbox"]'
    );
    allCheckboxes.forEach((checkbox) => {
      checkbox.checked = false;
      checkbox.indeterminate = false;
    });

    this.hideToolbar();
  }
}
