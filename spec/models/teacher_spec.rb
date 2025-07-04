require 'rails_helper'

RSpec.describe Teacher, type: :model do
  describe 'ファクトリのテスト' do
    it 'valid factoryが有効であること' do
      teacher = build(:teacher)
      expect(teacher).to be_valid
    end

    it 'with_reminder traitが有効であること' do
      teacher = build(:teacher, :with_reminder)
      expect(teacher).to be_valid
      expect(teacher.reminder_enabled?).to be true
    end
  end

  describe 'バリデーションのテスト' do
    let(:teacher) { build(:teacher) }

    describe 'user_login_name' do
      it '存在する場合は有効であること' do
        teacher.user_login_name = 'valid_teacher'
        expect(teacher).to be_valid
      end

      it '存在しない場合は無効であること' do
        teacher.user_login_name = nil
        expect(teacher).not_to be_valid
        expect(teacher.errors[:user_login_name]).to include("can't be blank")
      end

      it '重複する場合は無効であること' do
        create(:teacher, user_login_name: 'duplicate_teacher')
        teacher.user_login_name = 'duplicate_teacher'
        expect(teacher).not_to be_valid
        expect(teacher.errors[:user_login_name]).to include("has already been taken")
      end

      it '英数字とアンダースコアのみ許可されること' do
        teacher.user_login_name = 'valid_teacher_123'
        expect(teacher).to be_valid
      end

      it 'ハイフンが含まれる場合は無効であること' do
        teacher.user_login_name = 'invalid-teacher'
        expect(teacher).not_to be_valid
        expect(teacher.errors[:user_login_name]).to include("英数字とアンダースコアのみ使用可能です")
      end

      it '特殊文字が含まれる場合は無効であること' do
        teacher.user_login_name = 'invalid@teacher'
        expect(teacher).not_to be_valid
        expect(teacher.errors[:user_login_name]).to include("英数字とアンダースコアのみ使用可能です")
      end
    end

    describe 'name' do
      it '存在する場合は有効であること' do
        teacher.name = '講師太郎'
        expect(teacher).to be_valid
      end

      it '存在しない場合は無効であること' do
        teacher.name = nil
        expect(teacher).not_to be_valid
        expect(teacher.errors[:name]).to include("can't be blank")
      end

      it '空文字の場合は無効であること' do
        teacher.name = ''
        expect(teacher).not_to be_valid
        expect(teacher.errors[:name]).to include("can't be blank")
      end
    end

    describe 'email' do
      it 'nilの場合でも有効であること' do
        teacher.email = nil
        expect(teacher).to be_valid
      end

      it '空文字の場合でも有効であること' do
        teacher.email = ''
        expect(teacher).to be_valid
      end

      it '重複する場合は無効であること' do
        create(:teacher, email: 'duplicate@example.com')
        teacher.email = 'duplicate@example.com'
        expect(teacher).not_to be_valid
        expect(teacher.errors[:email]).to include("has already been taken")
      end

      it '有効なメールアドレスの場合は有効であること' do
        teacher.email = 'valid@example.com'
        expect(teacher).to be_valid
      end
    end


    describe 'password' do
      it '存在する場合は有効であること' do
        teacher.password = 'password123'
        teacher.password_confirmation = 'password123'
        expect(teacher).to be_valid
      end

      it '存在しない場合は無効であること' do
        teacher.password = nil
        teacher.password_confirmation = nil
        expect(teacher).not_to be_valid
        expect(teacher.errors[:password]).to include("can't be blank")
      end

      it 'パスワード確認が一致しない場合は無効であること' do
        teacher.password = 'password123'
        teacher.password_confirmation = 'different'
        expect(teacher).not_to be_valid
        expect(teacher.errors[:password_confirmation]).to include("doesn't match Password")
      end
    end
  end

  describe 'Deviseカスタマイズのテスト' do
    let(:teacher) { build(:teacher) }

    describe 'email_required?' do
      it 'falseを返すこと' do
        expect(teacher.email_required?).to be false
      end
    end

    describe 'email_changed?' do
      it 'falseを返すこと' do
        expect(teacher.email_changed?).to be false
      end
    end

    describe 'will_save_change_to_email?' do
      it 'falseを返すこと' do
        expect(teacher.will_save_change_to_email?).to be false
      end
    end
  end

  describe '認証のテスト' do
    describe 'find_for_database_authentication' do
      let!(:teacher) { create(:teacher, user_login_name: 'test_teacher') }

      context 'emailキーでuser_login_nameが渡された場合' do
        it '正しいteacherを返すこと' do
          result = Teacher.find_for_database_authentication(email: 'test_teacher')
          expect(result).to eq(teacher)
        end

        it '存在しないuser_login_nameの場合はnilを返すこと' do
          result = Teacher.find_for_database_authentication(email: 'nonexistent')
          expect(result).to be_nil
        end
      end

      context 'どちらのキーも存在しない場合' do
        it 'nilを返すこと' do
          result = Teacher.find_for_database_authentication(other_key: 'value')
          expect(result).to be_nil
        end
      end
    end
  end

  describe 'リマインダー機能のテスト' do
    describe 'reminder_enabled?' do
      context 'emailとnotification_timeが両方設定されている場合' do
        it 'trueを返すこと' do
          teacher = build(:teacher, 
                         email: 'reminder@example.com',
                         notification_time: '09:00')
          expect(teacher.reminder_enabled?).to be true
        end
      end

      context 'emailのみ設定されている場合' do
        it 'falseを返すこと' do
          teacher = build(:teacher, 
                         email: 'reminder@example.com',
                         notification_time: nil)
          expect(teacher.reminder_enabled?).to be false
        end
      end

      context 'notification_timeのみ設定されている場合' do
        it 'falseを返すこと' do
          teacher = build(:teacher, 
                         email: nil,
                         notification_time: '09:00')
          expect(teacher.reminder_enabled?).to be false
        end
      end

      context 'どちらも設定されていない場合' do
        it 'falseを返すこと' do
          teacher = build(:teacher, 
                         email: nil,
                         notification_time: nil)
          expect(teacher.reminder_enabled?).to be false
        end
      end

      context 'emailが空文字の場合' do
        it 'falseを返すこと' do
          teacher = build(:teacher, 
                         email: '',
                         notification_time: '09:00')
          expect(teacher.reminder_enabled?).to be false
        end
      end
    end
  end

  describe 'データベース保存のテスト' do
    it 'パスワードが暗号化されて保存されること' do
      teacher = create(:teacher, password: 'password123')
      expect(teacher.encrypted_password).not_to eq('password123')
      expect(teacher.encrypted_password).to be_present
    end

    it '全ての必須フィールドが保存されること' do
      teacher = create(:teacher, 
                      user_login_name: 'save_test',
                      name: '保存テスト講師',
                      email: 'save_test@example.com',
                      notification_time: '09:00')
      
      saved_teacher = Teacher.find(teacher.id)
      expect(saved_teacher.user_login_name).to eq('save_test')
      expect(saved_teacher.name).to eq('保存テスト講師')
      expect(saved_teacher.email).to eq('save_test@example.com')
      expect(saved_teacher.notification_time.strftime('%H:%M')).to eq('09:00')
    end
  end

  describe '担当生徒機能のテスト' do
    describe 'assigned_students' do
      let(:teacher) { create(:teacher) }

      it '担当生徒を複数持てること' do
        student1 = create(:student, assigned_teacher: teacher)
        student2 = create(:student, assigned_teacher: teacher)
        
        expect(teacher.assigned_students).to include(student1, student2)
        expect(teacher.assigned_students.count).to eq(2)
      end

      it '担当生徒がいない場合は空配列を返すこと' do
        expect(teacher.assigned_students).to be_empty
      end

      it 'with_assigned_students traitが正しく動作すること' do
        teacher_with_students = create(:teacher, :with_assigned_students)
        expect(teacher_with_students.assigned_students.count).to eq(3)
        expect(teacher_with_students.assigned_students.first).to be_a(Student)
      end

      it 'with_students traitが指定された数の生徒を作成すること' do
        teacher_with_five = create(:teacher, :with_students, students_count: 5)
        expect(teacher_with_five.assigned_students.count).to eq(5)
      end

      it '講師削除時に担当生徒のassigned_teacher_idがnilになること' do
        student1 = create(:student, assigned_teacher: teacher)
        student2 = create(:student, assigned_teacher: teacher)
        
        teacher.destroy
        
        student1.reload
        student2.reload
        
        expect(student1.assigned_teacher_id).to be_nil
        expect(student2.assigned_teacher_id).to be_nil
      end
    end

    describe '担当生徒数カウント' do
      let(:teacher) { create(:teacher) }

      it '担当生徒数を正しくカウントできること' do
        create_list(:student, 3, assigned_teacher: teacher)
        create(:student) # 他の講師の生徒（担当なし）
        
        expect(teacher.assigned_students.count).to eq(3)
      end
    end
  end
end
