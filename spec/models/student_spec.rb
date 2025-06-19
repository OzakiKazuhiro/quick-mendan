require 'rails_helper'

RSpec.describe Student, type: :model do
  describe 'ファクトリのテスト' do
    it 'valid factoryが有効であること' do
      student = build(:student)
      expect(student).to be_valid
    end

    it 'with_campus traitが有効であること' do
      student = create(:student, :with_campus)
      expect(student).to be_valid
      expect(student.campuses).to be_present
      expect(student.campuses.count).to eq(1)
    end
    
    it 'with_multiple_campuses traitが有効であること' do
      student = create(:student, :with_multiple_campuses)
      expect(student).to be_valid
      expect(student.campuses.count).to eq(2)
    end
  end

  describe '関連付けのテスト（多対多リレーション）' do
    describe 'campuses' do
      let(:student) { create(:student) }
      
      it '複数の校舎に所属できること' do
        campus1 = create(:campus, name: "校舎1")
        campus2 = create(:campus, name: "校舎2")
        
        student.campuses << campus1
        student.campuses << campus2
        
        expect(student.campuses).to include(campus1, campus2)
        expect(student.campuses.count).to eq(2)
      end

      it '校舎との関連がない場合でも有効であること' do
        expect(student).to be_valid
        expect(student.campuses).to be_empty
      end
      
      it '中間テーブル経由で関連付けられること' do
        campus = create(:campus)
        student.campuses << campus
        
        expect(student.student_campus_affiliations.count).to eq(1)
        expect(student.student_campus_affiliations.first.campus).to eq(campus)
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
    end
  end
  
  # ===================================================================
  # 多対多リレーション用の新しいメソッドのテスト
  # ===================================================================
  
  describe '多対多リレーション用メソッドのテスト' do
    let(:student) { create(:student, name: "テスト生徒") }
    let(:campus1) { create(:campus, name: "校舎A") }
    let(:campus2) { create(:campus, name: "校舎B") }
    let(:campus3) { create(:campus, name: "校舎C") }

    describe 'campus_names' do
      it '所属校舎がない場合は空文字を返すこと' do
        expect(student.campus_names).to eq("")
      end

      it '単一校舎の場合は校舎名を返すこと' do
        student.campuses << campus1
        expect(student.campus_names).to eq("校舎A")
      end

      it '複数校舎の場合はカンマ区切りで返すこと' do
        student.campuses << [campus1, campus2, campus3]
        expect(student.campus_names).to eq("校舎A, 校舎B, 校舎C")
      end
    end

    describe 'primary_campus_name' do
      it '所属校舎がない場合は"未設定"を返すこと' do
        expect(student.primary_campus_name).to eq("未設定")
      end

      it '校舎がある場合は最初の校舎名を返すこと' do
        student.campuses << [campus2, campus1]
        expect(student.primary_campus_name).to eq("校舎B")
      end
    end

    describe 'belongs_to_campus?' do
      before do
        student.campuses << campus1
      end

      it '所属している校舎に対してtrueを返すこと' do
        expect(student.belongs_to_campus?(campus1)).to be true
      end

      it '所属していない校舎に対してfalseを返すこと' do
        expect(student.belongs_to_campus?(campus2)).to be false
      end
    end

    describe 'add_campus' do
      it '新しい校舎を追加できること' do
        student.add_campus(campus1)
        expect(student.campuses).to include(campus1)
        expect(student.campuses.count).to eq(1)
      end

      it '既に所属している校舎は重複追加されないこと' do
        student.campuses << campus1
        student.add_campus(campus1)
        expect(student.campuses.count).to eq(1)
      end
    end

    describe 'remove_campus' do
      before do
        student.campuses << [campus1, campus2]
      end

      it '指定した校舎を削除できること' do
        student.remove_campus(campus1)
        expect(student.campuses).not_to include(campus1)
        expect(student.campuses).to include(campus2)
      end

      it '所属していない校舎を削除してもエラーにならないこと' do
        expect { student.remove_campus(campus3) }.not_to raise_error
      end
    end

    describe 'campus_name (後方互換性)' do
      it 'primary_campus_nameと同じ値を返すこと' do
        student.campuses << campus1
        expect(student.campus_name).to eq(student.primary_campus_name)
        expect(student.campus_name).to eq("校舎A")
      end
    end
  end
end
