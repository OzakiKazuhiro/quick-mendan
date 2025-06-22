require 'rails_helper'

RSpec.feature "Student Management", type: :feature do
  let(:admin_teacher) { create(:teacher, role: :admin) }
  let(:campus) { create(:campus) }
  let!(:student) { create(:student, name: "テスト生徒") }

  before do
    # 管理者としてログイン
    visit staff_login_path
    fill_in 'username', with: admin_teacher.user_login_name
    fill_in 'password', with: 'password123'
    click_button 'ログイン'
  end

  scenario "管理者が生徒一覧を表示できる" do
    visit staff_students_path

    expect(page).to have_content("生徒管理")
    expect(page).to have_content(student.name)
    expect(page).to have_link("新規生徒登録")
  end

  scenario "管理者が新しい生徒を作成できる" do
    visit new_staff_student_path

    fill_in "生徒番号", with: "2024999"
    fill_in "氏名", with: "新規生徒"
    select "高校1年", from: "学年"
    fill_in "高校名", with: "テスト高校"
    
    click_button "生徒を登録"

    expect(page).to have_content("生徒「新規生徒」を登録しました")
    expect(page).to have_current_path(staff_students_path)
  end

  scenario "管理者が生徒詳細を表示できる" do
    visit staff_student_path(student)

    expect(page).to have_content("生徒詳細")
    expect(page).to have_content(student.name)
    expect(page).to have_content(student.student_number)
    expect(page).to have_link("編集")
  end

  scenario "管理者が生徒情報を編集できる" do
    visit edit_staff_student_path(student)

    fill_in "氏名", with: "更新された名前"
    select "高校2年", from: "学年"
    
    click_button "変更を保存"

    expect(page).to have_content("生徒「更新された名前」の情報を更新しました")
    expect(page).to have_content("更新された名前")
  end

  scenario "管理者が削除確認モーダルを表示できる", js: true do
    visit staff_student_path(student)

    click_button "生徒を削除"

    expect(page).to have_content("生徒を削除しますか？")
    expect(page).to have_content("生徒「#{student.name}」を削除します")
    expect(page).to have_button("削除する")
    expect(page).to have_button("キャンセル")
  end

  scenario "管理者が削除をキャンセルできる", js: true do
    visit staff_student_path(student)

    click_button "生徒を削除"
    click_button "キャンセル"

    expect(page).not_to have_content("生徒を削除しますか？")
    expect(Student.find_by(id: student.id)).to be_present
  end

  scenario "管理者が生徒を削除できる" do
    # 削除リクエストを直接送信
    page.driver.submit :delete, destroy_staff_student_path(student), {}
    
    expect(page).to have_current_path(staff_students_path)
    expect(page).to have_content("生徒「#{student.name}」を削除しました")
    expect(Student.find_by(id: student.id)).to be_nil
  end
end 