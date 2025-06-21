require 'rails_helper'

RSpec.describe InterviewRecord, type: :model do
  let(:campus) { create(:campus) }
  let(:teacher) { create(:teacher) }
  let(:student) { create(:student) }
  let(:time_slot) { create(:time_slot, teacher: teacher, date: Date.current, start_time: '14:00') }
  let(:appointment) { create(:appointment, student: student, time_slot: time_slot) }

  describe 'associations' do
    it { should belong_to(:appointment) }
    it { should have_one(:student).through(:appointment) }
    # has_one :teacher, through: :appointmentは直接的な関連ではないため、インスタンスメソッドでテスト
  end

  describe 'validations' do
    subject { build(:interview_record, appointment: appointment) }

    # belongs_toの関連は自動的にpresence validationが設定されるため、belong_toマッチャーを使用
    it { should belong_to(:appointment) }
    it { should validate_presence_of(:content) }
    it { should validate_length_of(:content).is_at_least(10).is_at_most(2000) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      interview_record = build(:interview_record, appointment: appointment)
      expect(interview_record).to be_valid
    end
  end

  describe 'instance methods' do
    let(:interview_record) { create(:interview_record, appointment: appointment, content: "面談内容のテストです。十分な長さのコンテンツ。") }

    describe '#student' do
      it '関連する生徒を返すこと' do
        expect(interview_record.student).to eq(student)
      end
    end

    describe '#teacher' do
      it '関連する講師を返すこと' do
        expect(interview_record.teacher).to eq(teacher)
      end
    end

    describe '#interview_date' do
      it '面談日を返すこと' do
        expect(interview_record.interview_date).to eq(time_slot.date)
      end
    end

    describe '#interview_time' do
      it '面談時間を返すこと' do
        expect(interview_record.interview_time).to eq(time_slot.start_time)
      end
    end
  end

  describe 'scopes' do
    let(:past_time_slot) { create(:time_slot, teacher: teacher, date: 1.week.ago, status: :available) }
    let!(:today_record) { create(:interview_record, appointment: appointment, content: "今日の面談記録です。十分な長さ。") }
    let!(:old_appointment) { create(:appointment, student: student, time_slot: past_time_slot) }
    let!(:old_record) { create(:interview_record, appointment: old_appointment, content: "過去の面談記録です。十分な長さ。") }

    describe '.recent' do
      it '最近の面談記録を返すこと' do
        expect(InterviewRecord.recent).to include(today_record)
      end
    end

    describe '.by_teacher' do
      it '指定した講師の面談記録を返すこと' do
        expect(InterviewRecord.by_teacher(teacher)).to include(today_record, old_record)
      end
    end

    describe '.by_student' do
      it '指定した生徒の面談記録を返すこと' do
        expect(InterviewRecord.by_student(student)).to include(today_record, old_record)
      end
    end
  end

  describe 'callbacks' do
    let(:interview_record) { build(:interview_record, appointment: appointment) }

    it '作成時にタイムスタンプが設定されること' do
      expect { interview_record.save }.to change { interview_record.created_at }
    end

    it '更新時にタイムスタンプが更新されること' do
      interview_record.save
      expect { interview_record.update(content: "更新されたコンテンツ") }.to change { interview_record.updated_at }
    end
  end

  describe 'edge cases' do
    it 'appointmentが削除されたら面談記録も削除されること（dependent: :destroy）' do
      interview_record = create(:interview_record, appointment: appointment)
      expect { appointment.destroy }.to change { InterviewRecord.count }.by(-1)
    end

    it '空のコンテンツでは無効であること' do
      interview_record = build(:interview_record, appointment: appointment, content: '')
      expect(interview_record).not_to be_valid
      expect(interview_record.errors[:content]).to include("can't be blank")
    end

    it '10文字未満のコンテンツでは無効であること' do
      short_content = 'a' * 9
      interview_record = build(:interview_record, appointment: appointment, content: short_content)
      expect(interview_record).not_to be_valid
      expect(interview_record.errors[:content]).to include("is too short (minimum is 10 characters)")
    end

    it '2000文字を超えるコンテンツでは無効であること' do
      long_content = 'a' * 2001
      interview_record = build(:interview_record, appointment: appointment, content: long_content)
      expect(interview_record).not_to be_valid
      expect(interview_record.errors[:content]).to include("is too long (maximum is 2000 characters)")
    end
  end
end
