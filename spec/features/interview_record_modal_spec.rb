require 'rails_helper'

RSpec.feature "Interview Record Modal", type: :feature do
  let(:admin_teacher) { create(:teacher, role: :admin) }
  let(:student) { create(:student, name: "テスト生徒") }
  let(:time_slot) { create(:time_slot, teacher: admin_teacher, date: Date.current - 1.day) }
  let!(:appointment) { create(:appointment, student: student, time_slot: time_slot) }

  before do
    # 管理者としてログイン
    allow_any_instance_of(ApplicationController).to receive(:current_staff_user).and_return(admin_teacher)
    allow_any_instance_of(ApplicationController).to receive(:current_user_is_admin?).and_return(true)
  end

  scenario "管理者が面談記録モーダルを表示できる", js: true do
    visit staff_student_path(student)

    click_button "面談記録の確認"

    expect(page).to have_content("面談記録詳細")
    expect(page).to have_content("#{admin_teacher.name}先生との面談")
    expect(page).to have_content("まだ面談記録はありません")
    expect(page).to have_button("記録を作成する")
  end

  scenario "管理者が新しい面談記録を作成できる", js: true do
    visit staff_student_path(student)

    click_button "面談記録の確認"
    click_button "記録を作成する"

    fill_in "面談内容", with: "テスト面談記録です。生徒の学習状況について話し合いました。"
    click_button "保存する"

    expect(page).to have_content("テスト面談記録です。生徒の学習状況について話し合いました。")
    expect(page).to have_button("編集する")
  end

  scenario "管理者が既存の面談記録を表示できる", js: true do
    interview_record = create(:interview_record, 
                             appointment: appointment, 
                             content: "既存の面談記録です。")

    visit staff_student_path(student)

    click_button "面談記録の確認"

    expect(page).to have_content("面談記録詳細")
    expect(page).to have_content("既存の面談記録です。")
    expect(page).to have_button("編集する")
  end

  scenario "管理者が面談記録を編集できる", js: true do
    interview_record = create(:interview_record, 
                             appointment: appointment, 
                             content: "編集前の記録")

    visit staff_student_path(student)

    click_button "面談記録の確認"
    click_button "編集する"

    fill_in "面談内容", with: "編集後の面談記録です。"
    click_button "保存する"

    expect(page).to have_content("編集後の面談記録です。")
    expect(page).not_to have_content("編集前の記録")
  end

  scenario "管理者が面談記録の編集をキャンセルできる", js: true do
    interview_record = create(:interview_record, 
                             appointment: appointment, 
                             content: "キャンセルテスト記録")

    visit staff_student_path(student)

    click_button "面談記録の確認"
    click_button "編集する"

    fill_in "面談内容", with: "変更されるはずのテキスト"
    click_button "キャンセル"

    expect(page).to have_content("キャンセルテスト記録")
    expect(page).not_to have_content("変更されるはずのテキスト")
  end

  scenario "管理者がモーダルを閉じることができる", js: true do
    visit staff_student_path(student)

    click_button "面談記録の確認"

    expect(page).to have_content("面談記録詳細")

    # モーダルの閉じるボタンをクリック
    find('button[data-action*="close"]').click

    expect(page).not_to have_content("面談記録詳細")
  end
end 