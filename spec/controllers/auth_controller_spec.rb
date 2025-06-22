require 'rails_helper'

RSpec.describe AuthController, type: :controller do
  let(:teacher) { create(:teacher) }
  let(:admin_teacher) { create(:teacher, role: :admin) }

  before do
    # 講師としてログイン
    session[:teacher_id] = teacher.id
  end

  describe 'POST #bulk_assign_teacher' do
    let!(:student1) { create(:student) }
    let!(:student2) { create(:student) }
    let!(:student3) { create(:student) }
    let!(:target_teacher) { create(:teacher, name: "対象講師") }

    context '正常なパラメータでの一括担当講師設定' do
      it '複数の生徒に担当講師を設定できること' do
        student_ids = "#{student1.id},#{student2.id}"
        
        post :bulk_assign_teacher, params: {
          student_ids: student_ids,
          teacher_id: target_teacher.id
        }
        
        student1.reload
        student2.reload
        student3.reload
        
        expect(student1.assigned_teacher).to eq(target_teacher)
        expect(student2.assigned_teacher).to eq(target_teacher)
        expect(student3.assigned_teacher).to be_nil # 選択されていない
        
        expect(response).to redirect_to(staff_students_path)
        expect(flash[:success]).to include("2名の生徒を対象講師先生の担当に設定しました")
      end
    end

    context '担当講師を外す場合' do
      before do
        student1.update!(assigned_teacher: target_teacher)
        student2.update!(assigned_teacher: target_teacher)
      end

      it '複数の生徒の担当講師を外せること' do
        student_ids = "#{student1.id},#{student2.id}"
        
        post :bulk_assign_teacher, params: {
          student_ids: student_ids,
          teacher_id: '' # 空文字で担当を外す
        }
        
        student1.reload
        student2.reload
        
        expect(student1.assigned_teacher).to be_nil
        expect(student2.assigned_teacher).to be_nil
        
        expect(response).to redirect_to(staff_students_path)
        expect(flash[:success]).to include("2名の生徒の担当を外しました")
      end
    end

    context 'エラーケース' do
      it '生徒が選択されていない場合はエラーになること' do
        post :bulk_assign_teacher, params: {
          student_ids: '',
          teacher_id: target_teacher.id
        }
        
        expect(response).to redirect_to(staff_students_path)
        expect(flash[:error]).to eq("生徒を選択してください")
      end

      it '存在しない講師IDの場合はエラーになること' do
        student_ids = "#{student1.id}"
        
        expect {
          post :bulk_assign_teacher, params: {
            student_ids: student_ids,
            teacher_id: 99999
          }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it '不正な生徒IDが含まれている場合でも動作すること' do
        student_ids = "#{student1.id},99999"
        
        post :bulk_assign_teacher, params: {
          student_ids: student_ids,
          teacher_id: target_teacher.id
        }
        
        student1.reload
        expect(student1.assigned_teacher).to eq(target_teacher)
        
        expect(response).to redirect_to(staff_students_path)
        expect(flash[:success]).to include("2名の生徒を対象講師先生の担当に設定しました")
      end
    end

    context 'ログインしていない場合' do
      before do
        session[:teacher_id] = nil
      end

      it 'ログインページにリダイレクトされること' do
        post :bulk_assign_teacher, params: {
          student_ids: "#{student1.id}",
          teacher_id: target_teacher.id
        }
        
        expect(response).to redirect_to(staff_login_path)
        expect(flash[:alert]).to eq('ログインが必要です')
      end
    end
  end

  describe 'GET #students_index' do
    let!(:teacher1) { create(:teacher, name: "講師1") }
    let!(:teacher2) { create(:teacher, name: "講師2") }
    let!(:student_with_teacher1) { create(:student, assigned_teacher: teacher1) }
    let!(:student_with_teacher2) { create(:student, assigned_teacher: teacher2) }
    let!(:student_without_teacher) { create(:student, assigned_teacher: nil) }

    context '担当講師フィルタのテスト' do
      it '特定の講師の担当生徒のみ表示されること' do
        get :students_index, params: { assigned_teacher_id: teacher1.id }
        
        expect(assigns(:students)).to include(student_with_teacher1)
        expect(assigns(:students)).not_to include(student_with_teacher2)
        expect(assigns(:students)).not_to include(student_without_teacher)
      end

      it '担当なしの生徒のみ表示されること' do
        get :students_index, params: { assigned_teacher_id: 'unassigned' }
        
        expect(assigns(:students)).to include(student_without_teacher)
        expect(assigns(:students)).not_to include(student_with_teacher1)
        expect(assigns(:students)).not_to include(student_with_teacher2)
      end

      it 'フィルタなしの場合は全生徒が表示されること' do
        get :students_index
        
        expect(assigns(:students)).to include(student_with_teacher1)
        expect(assigns(:students)).to include(student_with_teacher2)
        expect(assigns(:students)).to include(student_without_teacher)
      end
    end
  end
end 