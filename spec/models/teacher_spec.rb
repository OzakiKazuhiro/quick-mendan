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

    describe 'notification_email' do
      it 'nilの場合は有効であること' do
        teacher.notification_email = nil
        expect(teacher).to be_valid
      end

      it '空文字の場合は有効であること' do
        teacher.notification_email = ''
        expect(teacher).to be_valid
      end

      it '有効なメールアドレスの場合は有効であること' do
        teacher.notification_email = 'notification@example.com'
        expect(teacher).to be_valid
      end

      it '無効なメールアドレスの場合は無効であること' do
        teacher.notification_email = 'invalid-email'
        expect(teacher).not_to be_valid
        expect(teacher.errors[:notification_email]).to be_present
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

      context 'user_login_nameキーが直接渡された場合' do
        it '正しいteacherを返すこと' do
          result = Teacher.find_for_database_authentication(user_login_name: 'test_teacher')
          expect(result).to eq(teacher)
        end

        it '存在しないuser_login_nameの場合はnilを返すこと' do
          result = Teacher.find_for_database_authentication(user_login_name: 'nonexistent')
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
      context 'notification_emailとnotification_timeが両方設定されている場合' do
        it 'trueを返すこと' do
          teacher = build(:teacher, 
                         notification_email: 'reminder@example.com',
                         notification_time: '09:00')
          expect(teacher.reminder_enabled?).to be true
        end
      end

      context 'notification_emailのみ設定されている場合' do
        it 'falseを返すこと' do
          teacher = build(:teacher, 
                         notification_email: 'reminder@example.com',
                         notification_time: nil)
          expect(teacher.reminder_enabled?).to be false
        end
      end

      context 'notification_timeのみ設定されている場合' do
        it 'falseを返すこと' do
          teacher = build(:teacher, 
                         notification_email: nil,
                         notification_time: '09:00')
          expect(teacher.reminder_enabled?).to be false
        end
      end

      context 'どちらも設定されていない場合' do
        it 'falseを返すこと' do
          teacher = build(:teacher, 
                         notification_email: nil,
                         notification_time: nil)
          expect(teacher.reminder_enabled?).to be false
        end
      end

      context 'notification_emailが空文字の場合' do
        it 'falseを返すこと' do
          teacher = build(:teacher, 
                         notification_email: '',
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
                      notification_email: 'reminder@example.com',
                      notification_time: '09:00')
      
      saved_teacher = Teacher.find(teacher.id)
      expect(saved_teacher.user_login_name).to eq('save_test')
      expect(saved_teacher.name).to eq('保存テスト講師')
      expect(saved_teacher.email).to eq('save_test@example.com')
      expect(saved_teacher.notification_email).to eq('reminder@example.com')
      expect(saved_teacher.notification_time.strftime('%H:%M')).to eq('09:00')
    end
  end
end
