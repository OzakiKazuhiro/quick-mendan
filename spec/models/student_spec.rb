require 'rails_helper'

RSpec.describe Student, type: :model do
  describe 'ファクトリのテスト' do
    it 'valid factoryが有効であること' do
      student = build(:student)
      expect(student).to be_valid
    end

    it 'with_campus traitが有効であること' do
      student = build(:student, :with_campus)
      expect(student).to be_valid
      expect(student.campus).to be_present
    end
  end

  describe '関連付けのテスト' do
    describe 'campus' do
      it 'campusとの関連付けが任意であること' do
        student = build(:student, campus: nil)
        expect(student).to be_valid
      end

      it 'campusが設定されている場合は有効であること' do
        campus = create(:campus)
        student = build(:student, campus: campus)
        expect(student).to be_valid
        expect(student.campus).to eq(campus)
      end
    end
  end

  describe 'バリデーションのテスト' do
    let(:student) { build(:student) }

    describe 'student_number' do
      it '存在する場合は有効であること' do
        student.student_number = '2024001'
        expect(student).to be_valid
      end

      it '存在しない場合は無効であること' do
        student.student_number = nil
        expect(student).not_to be_valid
        expect(student.errors[:student_number]).to include("can't be blank")
      end

      it '重複する場合は無効であること' do
        create(:student, student_number: '2024999')
        student.student_number = '2024999'
        expect(student).not_to be_valid
        expect(student.errors[:student_number]).to include("has already been taken")
      end

      it '英数字のみ許可されること' do
        student.student_number = 'ABC123'
        expect(student).to be_valid
      end

      it '数字のみでも有効であること' do
        student.student_number = '123456'
        expect(student).to be_valid
      end

      it 'ハイフンが含まれる場合は無効であること' do
        student.student_number = '2024-001'
        expect(student).not_to be_valid
        expect(student.errors[:student_number]).to include("英数字のみ使用可能です")
      end

      it '特殊文字が含まれる場合は無効であること' do
        student.student_number = '2024@001'
        expect(student).not_to be_valid
        expect(student.errors[:student_number]).to include("英数字のみ使用可能です")
      end
    end

    describe 'name' do
      it '存在する場合は有効であること' do
        student.name = '生徒太郎'
        expect(student).to be_valid
      end

      it '存在しない場合は無効であること' do
        student.name = nil
        expect(student).not_to be_valid
        expect(student.errors[:name]).to include("can't be blank")
      end

      it '空文字の場合は無効であること' do
        student.name = ''
        expect(student).not_to be_valid
        expect(student.errors[:name]).to include("can't be blank")
      end
    end
  end

  describe 'Deviseカスタマイズのテスト' do
    let(:student) { build(:student) }

    describe 'email_required?' do
      it 'falseを返すこと' do
        expect(student.email_required?).to be false
      end
    end

    describe 'email_changed?' do
      it 'falseを返すこと' do
        expect(student.email_changed?).to be false
      end
    end

    describe 'will_save_change_to_email?' do
      it 'falseを返すこと' do
        expect(student.will_save_change_to_email?).to be false
      end
    end

    describe 'emailメソッドのオーバーライド' do
      it 'emailがstudent_numberを返すこと' do
        student.student_number = '2024001'
        expect(student.email).to eq('2024001')
      end
    end

    describe 'email=メソッドのオーバーライド' do
      it 'emailへの代入がstudent_numberに反映されること' do
        student.email = '2024002'
        expect(student.student_number).to eq('2024002')
      end
    end
  end

  describe '認証のテスト' do
    describe 'find_for_database_authentication' do
      let!(:student) { create(:student, student_number: '2024001') }

      context 'emailキーでstudent_numberが渡された場合' do
        it '正しいstudentを返すこと' do
          result = Student.find_for_database_authentication(email: '2024001')
          expect(result).to eq(student)
        end

        it '存在しないstudent_numberの場合はnilを返すこと' do
          result = Student.find_for_database_authentication(email: '9999999')
          expect(result).to be_nil
        end
      end

      context 'どちらのキーも存在しない場合' do
        it 'nilを返すこと' do
          result = Student.find_for_database_authentication(other_key: 'value')
          expect(result).to be_nil
        end
      end
    end
  end

  describe 'クラスメソッドのテスト' do
    describe 'create_with_default_password' do
      it 'パスワード9999でstudentが作成されること' do
        attributes = {
          student_number: '2024001',
          name: '新しい生徒'
        }
        
        student = Student.create_with_default_password(attributes)
        
        expect(student).to be_persisted
        expect(student.student_number).to eq('2024001')
        expect(student.name).to eq('新しい生徒')
        expect(student.valid_password?('9999')).to be true
      end

      it 'バリデーションエラーがある場合は保存されないこと' do
        attributes = {
          student_number: nil,  # 必須フィールドを空にする
          name: '新しい生徒'
        }
        
        student = Student.create_with_default_password(attributes)
        
        expect(student).not_to be_persisted
        expect(student.errors).to be_present
      end

      it '校舎も指定できること' do
        campus = create(:campus)
        attributes = {
          student_number: '2024002',
          name: '校舎付き生徒',
          campus: campus
        }
        
        student = Student.create_with_default_password(attributes)
        
        expect(student).to be_persisted
        expect(student.campus).to eq(campus)
      end
    end
  end

  describe 'インスタンスメソッドのテスト' do
    describe 'campus_name' do
      context '校舎が設定されている場合' do
        it '校舎名を返すこと' do
          campus = create(:campus, name: '三国ヶ丘本部校')
          student = build(:student, campus: campus)
          expect(student.campus_name).to eq('三国ヶ丘本部校')
        end
      end

      context '校舎が設定されていない場合' do
        it '"未設定"を返すこと' do
          student = build(:student, campus: nil)
          expect(student.campus_name).to eq('未設定')
        end
      end
    end
  end

  describe 'データベース保存のテスト' do
    it 'パスワードが暗号化されて保存されること' do
      student = create(:student, password: '9999')
      expect(student.encrypted_password).not_to eq('9999')
      expect(student.encrypted_password).to be_present
    end

    it '全ての必須フィールドが保存されること' do
      campus = create(:campus, name: 'テスト校舎')
      student = create(:student, 
                      student_number: '2024001',
                      name: '保存テスト生徒',
                      grade: '高校3年',
                      school_name: 'テスト高等学校',
                      campus: campus)
      
      saved_student = Student.find(student.id)
      expect(saved_student.student_number).to eq('2024001')
      expect(saved_student.name).to eq('保存テスト生徒')
      expect(saved_student.grade).to eq('高校3年')
      expect(saved_student.school_name).to eq('テスト高等学校')
      expect(saved_student.campus).to eq(campus)
    end

    it 'デフォルトパスワード9999で認証できること' do
      student = Student.create_with_default_password({
        student_number: '2024003',
        name: '認証テスト生徒'
      })
      
      expect(student.valid_password?('9999')).to be true
      expect(student.valid_password?('1234')).to be false
    end
  end
end
