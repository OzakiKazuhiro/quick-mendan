import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "modal",
    "studentName",
    "studentId",
    "deleteButton",
    "teacherName",
    "teacherId",
  ];

  connect() {
    // ESCキーでモーダルを閉じる
    this.boundHandleKeyup = this.handleKeyup.bind(this);
    document.addEventListener("keyup", this.boundHandleKeyup);
  }

  disconnect() {
    document.removeEventListener("keyup", this.boundHandleKeyup);
  }

  handleKeyup(event) {
    if (event.key === "Escape") {
      this.close();
    }
  }

  open(event) {
    event.preventDefault();

    // 生徒の場合
    if (event.target.dataset.studentName) {
      const studentName = event.target.dataset.studentName;
      const studentId = event.target.dataset.studentId;

      if (this.hasStudentNameTarget) {
        this.studentNameTarget.textContent = studentName;
      }

      if (this.hasDeleteButtonTarget) {
        this.deleteButtonTarget.onclick = () => this.deleteStudent(studentId);
      }
    }

    // 講師の場合
    if (event.target.dataset.teacherName) {
      const teacherName = event.target.dataset.teacherName;
      const teacherId = event.target.dataset.teacherId;

      if (this.hasTeacherNameTarget) {
        this.teacherNameTarget.textContent = teacherName;
      }

      if (this.hasDeleteButtonTarget) {
        this.deleteButtonTarget.onclick = () => this.deleteTeacher(teacherId);
      }
    }

    this.modalTarget.classList.remove("hidden");
    document.body.style.overflow = "hidden";
  }

  close() {
    this.modalTarget.classList.add("hidden");
    document.body.style.overflow = "auto";
  }

  confirm() {
    // deleteButtonのonclickが設定されているので、それを実行
    if (this.deleteButtonTarget.onclick) {
      this.deleteButtonTarget.onclick();
    }
  }

  deleteStudent(studentId) {
    const form = document.createElement("form");
    form.method = "POST";
    form.action = `/staff/students/${studentId}`;
    form.style.display = "none";

    const methodInput = document.createElement("input");
    methodInput.type = "hidden";
    methodInput.name = "_method";
    methodInput.value = "DELETE";

    const tokenInput = document.createElement("input");
    tokenInput.type = "hidden";
    tokenInput.name = "authenticity_token";
    tokenInput.value = document
      .querySelector('meta[name="csrf-token"]')
      .getAttribute("content");

    form.appendChild(methodInput);
    form.appendChild(tokenInput);
    document.body.appendChild(form);
    form.submit();
  }

  deleteTeacher(teacherId) {
    const form = document.createElement("form");
    form.method = "POST";
    form.action = `/staff/teachers/${teacherId}`;
    form.style.display = "none";

    const methodInput = document.createElement("input");
    methodInput.type = "hidden";
    methodInput.name = "_method";
    methodInput.value = "DELETE";

    const tokenInput = document.createElement("input");
    tokenInput.type = "hidden";
    tokenInput.name = "authenticity_token";
    tokenInput.value = document
      .querySelector('meta[name="csrf-token"]')
      .getAttribute("content");

    form.appendChild(methodInput);
    form.appendChild(tokenInput);
    document.body.appendChild(form);
    form.submit();
  }
}
