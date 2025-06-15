require 'rails_helper'

RSpec.describe 'Students', type: :request do
  let(:campus) { create(:campus) }
  let(:student) { create(:student, campus: campus) }
  let!(:teachers) { create_list(:teacher, 3) }
  let!(:campuses) { create_list(:campus, 2) }

  describe 'GET /student/dashboard' do
    context 'ログインしていない場合' do
      it 'ログインページにリダイレクトされること' do
        get student_dashboard_path
        expect(response).to redirect_to(new_student_session_path)
      end
    end

    context 'ログインしている場合' do
      before do
        sign_in student
      end

      it 'ステータス200が返されること' do
        get student_dashboard_path
        expect(response).to have_http_status(:ok)
      end

      it 'ダッシュボードページが表示されること' do
        get student_dashboard_path
        expect(response.body).to include('生徒ダッシュボード')
        expect(response.body).to include(student.name)
        expect(response.body).to include(student.student_number)
      end

      it '統計情報が表示されること' do
        get student_dashboard_path
        expect(response.body).to include('利用可能講師数')
        expect(response.body).to include("#{Teacher.count}名")
        expect(response.body).to include('校舎数')
        expect(response.body).to include("#{Campus.count}校舎")
      end

      it 'メニューカードが表示されること' do
        get student_dashboard_path
        expect(response.body).to include('面談予約')
        expect(response.body).to include('予約確認')
        expect(response.body).to include('予約変更')
        expect(response.body).to include('講師一覧')
      end

      it '校舎情報が表示されること' do
        get student_dashboard_path
        expect(response.body).to include("所属校舎:")
        expect(response.body).to include(campus.name)
      end

      it 'キャッシュ制御ヘッダーが正しく設定されること' do
        get student_dashboard_path
        # Railsは複数のCache-Controlディレクティブを正規化するため、含まれることを確認
        expect(response.headers['Cache-Control']).to include('no-store')
        expect(response.headers['Cache-Control']).to include('private')
        expect(response.headers['Pragma']).to eq('no-cache')
        expect(response.headers['Expires']).to eq('0')
      end
    end

    context '校舎が設定されていない生徒の場合' do
      let(:student_without_campus) { create(:student, campus: nil) }

      before do
        sign_in student_without_campus
      end

      it '正常に動作し、校舎情報が表示されないこと' do
        get student_dashboard_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to include(student_without_campus.name)
        expect(response.body).not_to include('所属校舎:')
      end

      it 'キャッシュ制御ヘッダーが正しく設定されること' do
        get student_dashboard_path
        # Railsは複数のCache-Controlディレクティブを正規化するため、含まれることを確認
        expect(response.headers['Cache-Control']).to include('no-store')
        expect(response.headers['Cache-Control']).to include('private')
        expect(response.headers['Pragma']).to eq('no-cache')
        expect(response.headers['Expires']).to eq('0')
      end
    end
  end

  describe 'ルーティング' do
    it 'student_dashboard_path が正しいパスを返すこと' do
      expect(student_dashboard_path).to eq('/student/dashboard')
    end
  end

  describe 'ログアウト機能' do
    before do
      sign_in student
    end

    it 'ログアウトが成功すること' do
      delete destroy_student_session_path
      expect(response).to redirect_to(root_path)
    end
  end
end 