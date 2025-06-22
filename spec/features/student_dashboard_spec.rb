require 'rails_helper'

RSpec.feature '生徒ダッシュボード', type: :feature do
  let(:campus) { create(:campus, name: '三国ヶ丘本部校') }
  let!(:teachers) { create_list(:teacher, 3) }
  let!(:campuses) { create_list(:campus, 2) }
  let(:student) do
    create(:student, name: '山田太郎', student_number: '2024001').tap do |s|
      s.campuses << campus
    end
  end

  scenario '生徒がログインしてダッシュボードを表示する' do
    # ログインページにアクセス
    visit student_login_path

    # ログイン情報を入力
    fill_in 'student_number', with: student.student_number
    fill_in 'password', with: '9999'
    click_button 'ログイン'

    # ダッシュボードにリダイレクトされることを確認
    expect(current_path).to eq(student_dashboard_path)

    # ページタイトルの確認
    expect(page).to have_title('生徒ダッシュボード')

    # ヘッダー情報の確認
    expect(page).to have_content('生徒ダッシュボード')
    expect(page).to have_content("こんにちは、#{student.name}さん")
    expect(page).to have_content("生徒番号: #{student.student_number}")
    expect(page).to have_content("所属校舎: #{campus.name}")

    # メニューカードの確認
    expect(page).to have_content('面談予約')
    expect(page).to have_content('講師との面談を予約する')
    expect(page).to have_content('予約キャンセル')
    expect(page).to have_content('現在の予約状況を確認・キャンセル')

    # 今日の面談予定セクションの確認
    expect(page).to have_content('面談予定日時')
    expect(page).to have_content('予約はありません')

    # ログアウトボタンの確認
    expect(page).to have_button('ログアウト')
  end

  scenario '校舎が設定されていない生徒の場合' do
    student_without_campus = create(:student, name: '佐藤花子', student_number: '2024002')
    # 校舎を設定しない（多対多リレーションなので何もしない）

    # ログイン
    visit student_login_path
    fill_in 'student_number', with: student_without_campus.student_number
    fill_in 'password', with: '9999'
    click_button 'ログイン'

    # ダッシュボードにアクセス成功
    expect(current_path).to eq(student_dashboard_path)
    expect(page).to have_content("こんにちは、#{student_without_campus.name}さん")
    
    # 校舎情報が表示されないことを確認
    expect(page).not_to have_content('所属校舎:')
  end

  scenario 'ログインしていない状態でダッシュボードにアクセス' do
    # 直接ダッシュボードにアクセス
    visit student_dashboard_path

    # ログインページにリダイレクトされることを確認
    expect(current_path).to eq(student_login_path)
  end
end 