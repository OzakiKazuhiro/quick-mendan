require 'rails_helper'

RSpec.describe 'Auth', type: :request do
  let(:admin_teacher) { create(:teacher, role: :admin) }
  let(:teacher) { create(:teacher, role: :teacher) }
  let!(:teachers) { create_list(:teacher, 3) }
  let!(:students) { create_list(:student, 5) }
  let!(:campuses) { create_list(:campus, 4) }

  describe 'GET /staff/dashboard' do
    context 'ログインしていない場合' do
      it 'ルートページにリダイレクトされること' do
        get staff_dashboard_path
        expect(response).to redirect_to(root_path)
      end
    end

    context '管理者としてログインしている場合' do
      before do
        # セッションに管理者権限を持つ講師IDを設定
        allow_any_instance_of(ApplicationController).to receive(:current_teacher).and_return(admin_teacher)
        allow_any_instance_of(ApplicationController).to receive(:current_staff_user).and_return(admin_teacher)
        allow_any_instance_of(ApplicationController).to receive(:current_user_is_admin?).and_return(true)
        allow_any_instance_of(ApplicationController).to receive(:current_user_is_staff?).and_return(true)
      end

      it 'ステータス200が返されること' do
        get staff_dashboard_path
        expect(response).to have_http_status(:ok)
      end

      it 'ダッシュボードページが表示されること' do
        get staff_dashboard_path
        expect(response.body).to include('ダッシュボード')
        expect(response.body).to include(admin_teacher.name)
        expect(response.body).to include('（管理者）')
      end

      it 'キャッシュ制御ヘッダーが正しく設定されること' do
        get staff_dashboard_path
        # Railsは複数のCache-Controlディレクティブを正規化するため、含まれることを確認
        expect(response.headers['Cache-Control']).to include('no-store')
        expect(response.headers['Cache-Control']).to include('private')
        expect(response.headers['Pragma']).to eq('no-cache')
        expect(response.headers['Expires']).to eq('0')
      end

      it '統計情報が表示されること' do
        get staff_dashboard_path
        expect(response.body).to include('生徒数')
        expect(response.body).to include("#{Student.count}名")
        expect(response.body).to include('講師数')  # 管理者の場合のみ表示
        expect(response.body).to include("#{Teacher.count}名")
        expect(response.body).to include('校舎数')
        expect(response.body).to include("#{Campus.count}校舎")
      end

      it '管理者向けメニューが表示されること' do
        get staff_dashboard_path
        expect(response.body).to include('面談枠設定')
        expect(response.body).to include('予約管理')
        expect(response.body).to include('システム管理')  # 管理者のみ
        expect(response.body).to include('面談記録')
      end
    end

    context '講師としてログインしている場合' do
      before do
        # セッションに講師IDを設定
        allow_any_instance_of(ApplicationController).to receive(:current_teacher).and_return(teacher)
        allow_any_instance_of(ApplicationController).to receive(:current_staff_user).and_return(teacher)
        allow_any_instance_of(ApplicationController).to receive(:current_user_is_admin?).and_return(false)
        allow_any_instance_of(ApplicationController).to receive(:current_user_is_staff?).and_return(true)
      end

      it 'ステータス200が返されること' do
        get staff_dashboard_path
        expect(response).to have_http_status(:ok)
      end

      it 'ダッシュボードページが表示されること' do
        get staff_dashboard_path
        expect(response.body).to include('ダッシュボード')
        expect(response.body).to include(teacher.name)
        expect(response.body).to include('（講師）')
      end

      it 'キャッシュ制御ヘッダーが正しく設定されること' do
        get staff_dashboard_path
        # Railsは複数のCache-Controlディレクティブを正規化するため、含まれることを確認
        expect(response.headers['Cache-Control']).to include('no-store')
        expect(response.headers['Cache-Control']).to include('private')
        expect(response.headers['Pragma']).to eq('no-cache')
        expect(response.headers['Expires']).to eq('0')
      end

      it '講師向けメニューが表示されること' do
        get staff_dashboard_path
        expect(response.body).to include('面談枠設定')
        expect(response.body).to include('予約管理')
        expect(response.body).to include('面談記録')
        # 講師の場合はシステム管理は表示されない
        expect(response.body).not_to include('システム管理')
      end

      it '講師向け統計情報が表示されること' do
        get staff_dashboard_path
        expect(response.body).to include('生徒数')
        expect(response.body).to include("#{Student.count}名")
        expect(response.body).to include('校舎数')
        expect(response.body).to include("#{Campus.count}校舎")
        # 講師の場合は講師数は表示されない
        expect(response.body).not_to include('講師数')
      end
    end
  end
end 