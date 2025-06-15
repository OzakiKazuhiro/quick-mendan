require 'rails_helper'

RSpec.describe Admin, type: :model do
  describe 'ファクトリのテスト' do
    it 'valid factoryが有効であること' do
      admin = build(:admin)
      expect(admin).to be_valid
    end
  end

  describe 'バリデーションのテスト' do
    let(:admin) { build(:admin) }

    describe 'user_login_name' do
      it '存在する場合は有効であること' do
        admin.user_login_name = 'valid_admin'
        expect(admin).to be_valid
      end

      it '存在しない場合は無効であること' do
        admin.user_login_name = nil
        expect(admin).not_to be_valid
        expect(admin.errors[:user_login_name]).to include("can't be blank")
      end

      it '重複する場合は無効であること' do
        create(:admin, user_login_name: 'duplicate_admin')
        admin.user_login_name = 'duplicate_admin'
        expect(admin).not_to be_valid
        expect(admin.errors[:user_login_name]).to include("has already been taken")
      end

      it '英数字とアンダースコアのみ許可されること' do
        admin.user_login_name = 'valid_admin_123'
        expect(admin).to be_valid
      end

      it 'ハイフンが含まれる場合は無効であること' do
        admin.user_login_name = 'invalid-admin'
        expect(admin).not_to be_valid
        expect(admin.errors[:user_login_name]).to include("英数字とアンダースコアのみ使用可能です")
      end

      it '特殊文字が含まれる場合は無効であること' do
        admin.user_login_name = 'invalid@admin'
        expect(admin).not_to be_valid
        expect(admin.errors[:user_login_name]).to include("英数字とアンダースコアのみ使用可能です")
      end
    end

    describe 'name' do
      it '存在する場合は有効であること' do
        admin.name = '管理者太郎'
        expect(admin).to be_valid
      end

      it '存在しない場合は無効であること' do
        admin.name = nil
        expect(admin).not_to be_valid
        expect(admin.errors[:name]).to include("can't be blank")
      end

      it '空文字の場合は無効であること' do
        admin.name = ''
        expect(admin).not_to be_valid
        expect(admin.errors[:name]).to include("can't be blank")
      end
    end

    describe 'email' do
      it 'nilの場合でも有効であること' do
        admin.email = nil
        expect(admin).to be_valid
      end

      it '空文字の場合でも有効であること' do
        admin.email = ''
        expect(admin).to be_valid
      end

      it '重複する場合は無効であること' do
        create(:admin, email: 'duplicate@example.com')
        admin.email = 'duplicate@example.com'
        expect(admin).not_to be_valid
        expect(admin.errors[:email]).to include("has already been taken")
      end

      it '有効なメールアドレスの場合は有効であること' do
        admin.email = 'valid@example.com'
        expect(admin).to be_valid
      end
    end

    describe 'password' do
      it '存在する場合は有効であること' do
        admin.password = 'password123'
        admin.password_confirmation = 'password123'
        expect(admin).to be_valid
      end

      it '存在しない場合は無効であること' do
        admin.password = nil
        admin.password_confirmation = nil
        expect(admin).not_to be_valid
        expect(admin.errors[:password]).to include("can't be blank")
      end
    end
  end

  describe 'Deviseカスタマイズのテスト' do
    let(:admin) { build(:admin) }

    describe 'email_required?' do
      it 'falseを返すこと' do
        expect(admin.email_required?).to be false
      end
    end

    describe 'email_changed?' do
      it 'falseを返すこと' do
        expect(admin.email_changed?).to be false
      end
    end

    describe 'will_save_change_to_email?' do
      it 'falseを返すこと' do
        expect(admin.will_save_change_to_email?).to be false
      end
    end
  end

  describe '認証のテスト' do
    describe 'find_for_database_authentication' do
      let!(:admin) { create(:admin, user_login_name: 'test_admin') }

      context 'emailキーでuser_login_nameが渡された場合' do
        it '正しいadminを返すこと' do
          result = Admin.find_for_database_authentication(email: 'test_admin')
          expect(result).to eq(admin)
        end

        it '存在しないuser_login_nameの場合はnilを返すこと' do
          result = Admin.find_for_database_authentication(email: 'nonexistent')
          expect(result).to be_nil
        end
      end

      context 'user_login_nameキーが直接渡された場合' do
        it '正しいadminを返すこと' do
          result = Admin.find_for_database_authentication(user_login_name: 'test_admin')
          expect(result).to eq(admin)
        end

        it '存在しないuser_login_nameの場合はnilを返すこと' do
          result = Admin.find_for_database_authentication(user_login_name: 'nonexistent')
          expect(result).to be_nil
        end
      end

      context 'どちらのキーも存在しない場合' do
        it 'nilを返すこと' do
          result = Admin.find_for_database_authentication(other_key: 'value')
          expect(result).to be_nil
        end
      end
    end
  end

  describe 'データベース保存のテスト' do
    it 'パスワードが暗号化されて保存されること' do
      admin = create(:admin, password: 'password123')
      expect(admin.encrypted_password).not_to eq('password123')
      expect(admin.encrypted_password).to be_present
    end

    it '全ての必須フィールドが保存されること' do
      admin = create(:admin, 
                     user_login_name: 'save_test',
                     name: '保存テスト管理者',
                     email: 'save_test@example.com')
      
      saved_admin = Admin.find(admin.id)
      expect(saved_admin.user_login_name).to eq('save_test')
      expect(saved_admin.name).to eq('保存テスト管理者')
      expect(saved_admin.email).to eq('save_test@example.com')
    end
  end
end
