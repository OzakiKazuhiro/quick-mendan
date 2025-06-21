require 'rails_helper'

RSpec.describe Appointment, type: :model do
  let(:campus) { create(:campus) }
  let(:teacher) { create(:teacher) }
  let(:student) { create(:student) }
  let(:time_slot) { create(:time_slot, teacher: teacher, date: Date.current + 1.day, start_time: '14:00') }

  describe 'associations' do
    it { should belong_to(:student) }
    it { should belong_to(:time_slot) }
    it { should have_one(:interview_record).dependent(:destroy) }
  end

  describe 'validations' do
    subject { build(:appointment, student: student, time_slot: time_slot) }

    it { should belong_to(:student) }
    it { should belong_to(:time_slot) }
    it { should validate_uniqueness_of(:time_slot_id) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      appointment = build(:appointment, student: student, time_slot: time_slot)
      expect(appointment).to be_valid
    end
  end

  describe 'scopes' do
    let!(:today_appointment) { create(:appointment, student: student, time_slot: create(:time_slot, teacher: teacher, date: Date.current, start_time: '14:00')) }
    let!(:future_appointment) { create(:appointment, student: student, time_slot: create(:time_slot, teacher: teacher, date: Date.current + 1.week, start_time: '14:00')) }
    let!(:past_appointment) { create(:appointment, student: student, time_slot: create(:time_slot, teacher: teacher, date: Date.current - 1.week, start_time: '14:00')) }

    describe '.upcoming' do
      it '今日以降の予約を返すこと' do
        expect(Appointment.upcoming).to include(today_appointment, future_appointment)
        expect(Appointment.upcoming).not_to include(past_appointment)
      end
    end

    describe '.past' do
      it '過去の予約を返すこと' do
        expect(Appointment.past).to include(past_appointment)
        expect(Appointment.past).not_to include(today_appointment, future_appointment)
      end
    end

    describe '.today' do
      it '今日の予約を返すこと' do
        expect(Appointment.today).to include(today_appointment)
        expect(Appointment.today).not_to include(future_appointment, past_appointment)
      end
    end

    describe '.by_teacher' do
      let(:another_teacher) { create(:teacher) }
      let!(:another_appointment) { create(:appointment, student: student, time_slot: create(:time_slot, teacher: another_teacher, date: Date.current, start_time: '14:00')) }

      it '指定した講師の予約を返すこと' do
        expect(Appointment.by_teacher(teacher)).to include(today_appointment, future_appointment, past_appointment)
        expect(Appointment.by_teacher(teacher)).not_to include(another_appointment)
      end
    end

    describe '.by_student' do
      let(:another_student) { create(:student) }
      let(:another_time_slot) { create(:time_slot, teacher: teacher, date: Date.current + 1.day, start_time: '15:00') }
      let!(:another_appointment) { create(:appointment, student: another_student, time_slot: another_time_slot) }

      it '指定した生徒の予約を返すこと' do
        expect(Appointment.by_student(student)).to include(today_appointment, future_appointment, past_appointment)
        expect(Appointment.by_student(student)).not_to include(another_appointment)
      end
    end
  end

  describe 'instance methods' do
    let(:appointment) { create(:appointment, student: student, time_slot: time_slot) }

    describe '#teacher' do
      it '関連する講師を返すこと' do
        expect(appointment.teacher).to eq(teacher)
      end
    end

    describe '#date' do
      it '予約日を返すこと' do
        expect(appointment.date).to eq(time_slot.date)
      end
    end

    describe '#start_time' do
      it '開始時間を返すこと' do
        expect(appointment.start_time).to eq(time_slot.start_time)
      end
    end

    describe '#end_time' do
      it '終了時間を返すこと' do
        expect(appointment.end_time).to eq(time_slot.end_time)
      end
    end

    describe '#can_be_cancelled?' do
      context '前日22:15より前の場合' do
        it 'trueを返すこと' do
          time_slot.update(date: Date.current + 2.days)
          expect(appointment.can_be_cancelled?).to be true
        end
      end

      context '前日22:15を過ぎている場合' do
        it 'falseを返すこと' do
          time_slot.update(date: Date.current)
          travel_to(Date.current.beginning_of_day + 22.hours + 16.minutes) do
            expect(appointment.can_be_cancelled?).to be false
          end
        end
      end
    end

    describe '#has_interview_record?' do
      context '面談記録がある場合' do
        before { create(:interview_record, appointment: appointment) }

        it 'trueを返すこと' do
          expect(appointment.has_interview_record?).to be true
        end
      end

      context '面談記録がない場合' do
        it 'falseを返すこと' do
          expect(appointment.has_interview_record?).to be false
        end
      end
    end
  end

  describe 'callbacks' do
    let(:appointment) { build(:appointment, student: student, time_slot: time_slot) }

    describe 'after_create' do
      it 'time_slotのstatusがbookedに変更されること' do
        expect { appointment.save }.to change { time_slot.reload.status }.from('available').to('booked')
      end
    end

    describe 'after_destroy' do
      it 'time_slotのstatusがavailableに戻ること' do
        appointment.save
        expect { appointment.destroy }.to change { time_slot.reload.status }.from('booked').to('available')
      end
    end
  end

  describe 'validations' do
    context '同じtime_slotに複数の予約がある場合' do
      before { create(:appointment, student: student, time_slot: time_slot) }

      it '無効であること' do
        duplicate_appointment = build(:appointment, student: create(:student), time_slot: time_slot)
        expect(duplicate_appointment).not_to be_valid
        expect(duplicate_appointment.errors[:time_slot_id]).to include('has already been taken')
      end
    end
  end

  describe 'edge cases' do
    it 'studentが削除されたら予約も削除されること（dependent: :destroy）' do
      appointment = create(:appointment, student: student, time_slot: time_slot)
      expect { student.destroy }.to change { Appointment.count }.by(-1)
    end

    it 'time_slotが削除されたら予約も削除されること' do
      appointment = create(:appointment, student: student, time_slot: time_slot)
      expect { time_slot.destroy }.to change { Appointment.count }.by(-1)
    end
  end
end
