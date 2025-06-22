require 'rails_helper'

RSpec.describe 'Students', type: :request do
  let(:campus) { create(:campus) }
  let(:student) do
    create(:student).tap do |s|
      s.campuses << campus
    end
  end
  let!(:teachers) { create_list(:teacher, 3) }
  let!(:campuses) { create_list(:campus, 2) }

  describe 'GET /student/dashboard' do
    context 'ログインしていない場合' do
      it 'ログインページにリダイレクトされること' do
        get student_dashboard_path
        expect(response).to redirect_to(student_login_path)
      end
    end

    context 'ログインしている場合' do
      before do
        # リクエストテストでセッションを設定
        post student_login_path, params: { 
          student_number: student.student_number, 
          password: '9999' 
        }
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
        expect(response.body).to include('面談予約')
        expect(response.body).to include('予約キャンセル')
        expect(response.body).to include('生徒ダッシュボード')
      end

      it 'メニューカードが表示されること' do
        get student_dashboard_path
        expect(response.body).to include('面談予約')
        expect(response.body).to include('予約キャンセル')
        expect(response.body).to include('講師との面談を予約する')
        expect(response.body).to include('現在の予約状況を確認・キャンセル')
      end

      it '校舎情報が表示されること' do
        get student_dashboard_path
        expect(response.body).to include("所属校舎:")
        expect(response.body).to include(campus.name)
      end

      it 'キャッシュ制御ヘッダーが正しく設定されること' do
        get student_dashboard_path
        # 実際のヘッダー値に合わせて修正
        expect(response.headers['Cache-Control']).to include('private')
        expect(response.headers['Cache-Control']).to include('no-store')
        expect(response.headers['Pragma']).to eq('no-cache')
      end
    end

    context '校舎が設定されていない生徒の場合' do
      let(:student_without_campus) { create(:student) }
      # 校舎を設定しない（多対多リレーションなので何もしない）

      before do
        # リクエストテストでセッションを設定
        post student_login_path, params: { 
          student_number: student_without_campus.student_number, 
          password: '9999' 
        }
      end

      it '正常に動作し、校舎情報が表示されないこと' do
        get student_dashboard_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to include(student_without_campus.name)
        expect(response.body).not_to include('所属校舎:')
      end

      it 'キャッシュ制御ヘッダーが正しく設定されること' do
        get student_dashboard_path
        # 実際のヘッダー値に合わせて修正
        expect(response.headers['Cache-Control']).to include('private')
        expect(response.headers['Cache-Control']).to include('no-store')
        expect(response.headers['Pragma']).to eq('no-cache')
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
      # リクエストテストでセッションを設定
      post student_login_path, params: { 
        student_number: student.student_number, 
        password: '9999' 
      }
    end

    it 'ログアウトが成功すること' do
      delete student_logout_path
      expect(response).to redirect_to(root_path)
    end
  end
end 