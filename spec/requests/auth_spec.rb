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

  # 生徒管理機能のテスト
  describe 'Student Management' do
    before do
      allow_any_instance_of(ApplicationController).to receive(:current_staff_user).and_return(admin_teacher)
      allow_any_instance_of(ApplicationController).to receive(:current_user_is_admin?).and_return(true)
    end

    describe 'GET /staff/students' do
      it '生徒一覧が表示されること' do
        get staff_students_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('生徒管理')
      end
    end

    describe 'GET /staff/students/new' do
      it '生徒新規作成画面が表示されること' do
        get new_staff_student_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('新規生徒登録')
      end
    end

    describe 'POST /staff/students' do
      let(:valid_params) do
        {
          student: {
            name: '新規生徒',
            student_number: '2024999',
            grade: '高校1年',
            school_name: 'テスト高校',
            campus_ids: [campuses.first.id]
          }
        }
      end

      context '有効なパラメータの場合' do
        it '生徒が作成されること' do
          expect {
            post create_staff_student_path, params: valid_params
          }.to change(Student, :count).by(1)
        end

        it '生徒一覧にリダイレクトされること' do
          post create_staff_student_path, params: valid_params
          expect(response).to redirect_to(staff_students_path)
        end

        it '成功メッセージが表示されること' do
          post create_staff_student_path, params: valid_params
          follow_redirect!
          expect(response.body).to include('生徒「新規生徒」を登録しました')
        end
      end

      context '無効なパラメータの場合' do
        let(:invalid_params) do
          {
            student: {
              name: '',
              student_number: '',
              campus_ids: []
            }
          }
        end

        it '生徒が作成されないこと' do
          expect {
            post create_staff_student_path, params: invalid_params
          }.not_to change(Student, :count)
        end

        it '新規作成画面が再表示されること' do
          post create_staff_student_path, params: invalid_params
          expect(response).to have_http_status(:ok)
          expect(response.body).to include('新規生徒登録')
        end
      end
    end

    describe 'GET /staff/students/:id' do
      let(:student) { students.first }

      it '生徒詳細が表示されること' do
        get staff_student_path(student)
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('生徒詳細')
        expect(response.body).to include(student.name)
      end
    end

    describe 'GET /staff/students/:id/edit' do
      let(:student) { students.first }

      it '生徒編集画面が表示されること' do
        get edit_staff_student_path(student)
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('生徒情報編集')
        expect(response.body).to include(student.name)
      end
    end

    describe 'PATCH /staff/students/:id' do
      let(:student) { students.first }
      let(:update_params) do
        {
          student: {
            name: '更新された名前',
            grade: '高校3年'
          }
        }
      end

      context '有効なパラメータの場合' do
        it '生徒情報が更新されること' do
          patch update_staff_student_path(student), params: update_params
          student.reload
          expect(student.name).to eq('更新された名前')
          expect(student.grade).to eq('高校3年')
        end

        it '生徒詳細にリダイレクトされること' do
          patch update_staff_student_path(student), params: update_params
          expect(response).to redirect_to(staff_student_path(student))
        end
      end
    end

    describe 'DELETE /staff/students/:id' do
      let(:student) { students.first }

      it '生徒が削除されること' do
        expect {
          delete destroy_staff_student_path(student)
        }.to change(Student, :count).by(-1)
      end

      it '生徒一覧にリダイレクトされること' do
        delete destroy_staff_student_path(student)
        expect(response).to redirect_to(staff_students_path)
      end
    end
  end

  # 面談記録モーダル機能のテスト
  describe 'Interview Record Modal' do
    let(:time_slot) { create(:time_slot, teacher: admin_teacher, date: Date.current) }
    let(:appointment) { create(:appointment, student: students.first, time_slot: time_slot) }

    before do
      allow_any_instance_of(ApplicationController).to receive(:current_staff_user).and_return(admin_teacher)
    end

    describe 'GET /staff/appointments/:id/interview_record_modal' do
      it 'モーダルコンテンツが返されること' do
        get show_interview_record_modal_path(appointment)
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('面談記録詳細')
      end

      context '面談記録が存在する場合' do
        before { create(:interview_record, appointment: appointment, content: 'テスト記録') }

        it '既存の記録が表示されること' do
          get show_interview_record_modal_path(appointment)
          expect(response.body).to include('テスト記録')
        end
      end
    end

    describe 'PATCH /staff/appointments/:id/interview_record_modal' do
      let(:record_params) do
        {
          interview_record: {
            content: '新しい面談記録'
          }
        }
      end

      context '新規作成の場合' do
        it '面談記録が作成されること' do
          expect {
            patch save_interview_record_in_modal_path(appointment), params: record_params
          }.to change(InterviewRecord, :count).by(1)
        end
      end

      context '更新の場合' do
        before { create(:interview_record, appointment: appointment, content: '既存記録') }

        it '面談記録が更新されること' do
          patch save_interview_record_in_modal_path(appointment), params: record_params
          expect(appointment.interview_record.reload.content).to eq('新しい面談記録')
        end
      end
    end
  end
end 