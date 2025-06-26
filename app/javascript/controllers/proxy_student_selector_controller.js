import { Controller } from "@hotwired/stimulus";

// 代理予約用の生徒単一選択コントローラー
export default class extends Controller {
  static targets = [
    "checkbox",
    "selectedInfo",
    "continueButton",
    "studentInitial",
    "studentName",
    "studentNumber",
    "studentCampuses",
  ];
  static values = { selectedStudentId: Number };

  connect() {
    this.updateUI();
  }

  // チェックボックスの選択変更
  selectStudent(event) {
    const checkbox = event.target;
    const studentId = parseInt(checkbox.value);

    if (checkbox.checked) {
      // 他のチェックボックスを全て解除
      this.checkboxTargets.forEach((cb) => {
        if (cb !== checkbox) {
          cb.checked = false;
        }
      });

      // 選択された生徒IDを更新
      this.selectedStudentIdValue = studentId;

      // 生徒情報を動的に更新
      this.updateStudentInfo(checkbox);
    } else {
      // チェックを外した場合
      this.selectedStudentIdValue = 0;
      this.clearStudentInfo();
    }

    this.updateUI();
  }

  // 生徒情報の動的更新
  updateStudentInfo(checkbox) {
    const studentName = checkbox.dataset.studentName;
    const studentNumber = checkbox.dataset.studentNumber;
    const studentCampuses = checkbox.dataset.studentCampuses;

    // 各要素を更新
    if (this.hasStudentInitialTarget) {
      this.studentInitialTarget.textContent = studentName
        ? studentName.charAt(0)
        : "?";
    }

    if (this.hasStudentNameTarget) {
      this.studentNameTarget.textContent = studentName || "";
    }

    if (this.hasStudentNumberTarget) {
      this.studentNumberTarget.textContent = studentNumber || "";
    }

    if (this.hasStudentCampusesTarget) {
      if (studentCampuses && studentCampuses.trim() !== "") {
        this.studentCampusesTarget.innerHTML = `| 所属: ${studentCampuses}`;
      } else {
        this.studentCampusesTarget.innerHTML = "";
      }
    }
  }

  // 生徒情報をクリア
  clearStudentInfo() {
    if (this.hasStudentInitialTarget) {
      this.studentInitialTarget.textContent = "?";
    }

    if (this.hasStudentNameTarget) {
      this.studentNameTarget.textContent = "";
    }

    if (this.hasStudentNumberTarget) {
      this.studentNumberTarget.textContent = "";
    }

    if (this.hasStudentCampusesTarget) {
      this.studentCampusesTarget.innerHTML = "";
    }
  }

  // UIの更新
  updateUI() {
    const hasSelection = this.selectedStudentIdValue > 0;

    // 選択情報の表示/非表示
    if (this.hasSelectedInfoTarget) {
      this.selectedInfoTarget.classList.toggle("hidden", !hasSelection);
    }

    // 続行ボタンの表示/非表示
    if (this.hasContinueButtonTarget) {
      this.continueButtonTarget.classList.toggle("hidden", !hasSelection);
    }

    // 選択された行のハイライト
    this.checkboxTargets.forEach((checkbox) => {
      const row = checkbox.closest("tr");
      const isSelected = checkbox.checked;

      if (row) {
        row.classList.toggle("bg-blue-50", isSelected);
        row.classList.toggle("border-blue-200", isSelected);
      }
    });
  }

  // 続行ボタンクリック時
  continue() {
    if (this.selectedStudentIdValue > 0) {
      // 選択された生徒IDをパラメータとして送信
      const url = new URL(window.location.href);
      url.searchParams.set("student_id", this.selectedStudentIdValue);

      // 検索条件も保持
      const form = document.querySelector("form");
      if (form) {
        const formData = new FormData(form);
        for (const [key, value] of formData.entries()) {
          if (key !== "student_id" && value) {
            if (key === "campuses[]") {
              // 複数の校舎選択の場合
              url.searchParams.append("campuses[]", value);
            } else {
              url.searchParams.set(key, value);
            }
          }
        }
      }

      window.location.href = url.toString();
    }
  }

  // 選択をクリア
  clearSelection() {
    this.checkboxTargets.forEach((checkbox) => {
      checkbox.checked = false;
    });
    this.selectedStudentIdValue = 0;
    this.clearStudentInfo();
    this.updateUI();
  }
}
