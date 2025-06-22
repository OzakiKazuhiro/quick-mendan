require 'rails_helper'

RSpec.feature "Interview Record Modal", type: :feature do
  let(:admin_teacher) { create(:teacher, role: :admin) }
  let(:student) { create(:student, name: "テスト生徒") }
  let(:time_slot) { create(:time_slot, teacher: admin_teacher, date: Date.current - 1.day) }
  let!(:appointment) { create(:appointment, student: student, time_slot: time_slot) }

  before do
    # 管理者としてログイン
    visit staff_login_path
    fill_in 'username', with: admin_teacher.user_login_name
    fill_in 'password', with: 'password123'
    click_button 'ログイン'
  end

  scenario "管理者が面談記録モーダルを表示できる", js: true do
    # 面談記録が存在する場合のテスト
    create(:interview_record, appointment: appointment, content: "既存の面談記録です。")
    
    visit staff_student_path(student)

    click_button "面談記録の確認"

    expect(page).to have_content("面談記録詳細")
    expect(page).to have_content("#{admin_teacher.name}先生との面談")
    expect(page).to have_content("既存の面談記録です。")
    expect(page).to have_button("編集する")
  end

  scenario "管理者が面談記録が存在しない場合を確認できる" do
    visit staff_student_path(student)

    # 面談記録が存在しない場合は「予約済み」と表示される
    expect(page).to have_content("予約済み")
  end

  scenario "管理者がモーダルを閉じることができる", js: true do
    # 面談記録が存在する場合のテスト
    create(:interview_record, appointment: appointment, content: "これは10文字以上のテスト記録です。")
    
    visit staff_student_path(student)

    click_button "面談記録の確認"

    expect(page).to have_content("面談記録詳細")

    # モーダルの閉じるボタンをクリック
    find('button[data-action*="close"]').click

    expect(page).not_to have_content("面談記録詳細")
  end
end 