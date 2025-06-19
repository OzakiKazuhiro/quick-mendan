class TimeSlotsController < ApplicationController
  before_action :require_staff
  before_action :set_current_week, only: [:index, :weekly]
  before_action :set_time_slot, only: [:show, :update, :destroy]

  # 面談枠設定メイン画面
  def index
    @current_teacher = current_teacher
    @campuses = Campus.ordered
    @selected_campus = params[:campus_id].present? ? Campus.find(params[:campus_id]) : @campuses.first
    
    # 週の日付範囲を設定
    @week_dates = (@start_date..(@start_date + 6.days)).to_a
    
    # 営業時間の時間枠を生成（14:00-22:00、10分刻み）
    @time_slots_grid = generate_time_slots_grid
    
    # 全校舎の既存面談枠データを取得
    @all_existing_slots = TimeSlot.for_week_all_campuses(@current_teacher, @start_date)
                                  .group_by { |slot| [slot.date, slot.start_time] }
    
    # 選択中校舎の面談枠のみを抽出（従来の動作も維持）
    @existing_slots = TimeSlot.for_week(@current_teacher, @start_date, @selected_campus)
                              .includes(:campus)
                              .group_by { |slot| [slot.date, slot.start_time] }
  end

  # 週表示（AJAX用）
  def weekly
    @current_teacher = current_teacher
    @selected_campus = params[:campus_id].present? ? Campus.find(params[:campus_id]) : Campus.first
    
    @week_dates = (@start_date..(@start_date + 6.days)).to_a
    @time_slots_grid = generate_time_slots_grid
    
    # 全校舎の既存面談枠データを取得
    @all_existing_slots = TimeSlot.for_week_all_campuses(@current_teacher, @start_date)
                                  .group_by { |slot| [slot.date, slot.start_time] }
    
    # 選択中校舎の面談枠のみを抽出（従来の動作も維持）
    @existing_slots = TimeSlot.for_week(@current_teacher, @start_date, @selected_campus)
                              .includes(:campus)
                              .group_by { |slot| [slot.date, slot.start_time] }
    
    render partial: 'time_slots_grid'
  end

  # 個別面談枠の作成
  def create
    @time_slot = current_teacher.time_slots.build(time_slot_params)
    
    if @time_slot.save
      render json: { 
        status: 'success', 
        message: '面談枠を設定しました',
        slot: {
          id: @time_slot.id,
          status: @time_slot.status,
          datetime: @time_slot.datetime_display
        }
      }
    else
      # 一意制約エラーの特別処理
      error_message = if @time_slot.errors[:teacher_id].any? && @time_slot.errors[:teacher_id].first.include?("同じ校舎・同じ日時")
                        "この校舎のこの時間には既に面談枠が設定されています"
                      else
                        @time_slot.errors.full_messages.join(', ')
                      end
      
      render json: { 
        status: 'error', 
        message: error_message
      }
    end
  end

  # 個別面談枠の更新
  def update
    if @time_slot.update(time_slot_params)
      render json: { 
        status: 'success', 
        message: '面談枠を更新しました',
        slot: {
          id: @time_slot.id,
          status: @time_slot.status,
          datetime: @time_slot.datetime_display
        }
      }
    else
      render json: { 
        status: 'error', 
        message: @time_slot.errors.full_messages.join(', ')
      }
    end
  end

  # 個別面談枠の削除
  def destroy
    if @time_slot.booked?
      render json: { 
        status: 'error', 
        message: '予約済みの面談枠は削除できません'
      }
    else
      @time_slot.destroy
      render json: { 
        status: 'success', 
        message: '面談枠を削除しました'
      }
    end
  end

  # 一括更新（将来の拡張用）
  def bulk_update
    slots_data = params[:slots] || []
    success_count = 0
    error_messages = []

    ActiveRecord::Base.transaction do
      slots_data.each do |slot_data|
        date = Date.parse(slot_data[:date])
        start_time = Time.parse(slot_data[:start_time])
        campus_id = slot_data[:campus_id]
        action = slot_data[:action] # 'create' or 'delete'

        if action == 'create'
          time_slot = current_teacher.time_slots.build(
            date: date,
            start_time: start_time,
            campus_id: campus_id,
            status: :available
          )
          
          if time_slot.save
            success_count += 1
          else
            error_messages << "#{date.strftime('%m/%d')} #{start_time.strftime('%H:%M')}: #{time_slot.errors.full_messages.join(', ')}"
          end
        elsif action == 'delete'
          time_slot = current_teacher.time_slots.find_by(
            date: date,
            start_time: start_time,
            campus_id: campus_id
          )
          
          if time_slot&.available?
            time_slot.destroy
            success_count += 1
          elsif time_slot&.booked?
            error_messages << "#{date.strftime('%m/%d')} #{start_time.strftime('%H:%M')}: 予約済みのため削除できません"
          end
        end
      end
    end

    if error_messages.empty?
      render json: { 
        status: 'success', 
        message: "#{success_count}件の面談枠を更新しました"
      }
    else
      render json: { 
        status: 'partial_success', 
        message: "#{success_count}件更新完了。エラー: #{error_messages.join(', ')}"
      }
    end
  rescue => e
    render json: { 
      status: 'error', 
      message: "更新中にエラーが発生しました: #{e.message}"
    }
  end

  private

  def set_current_week
    if params[:week_start].present?
      @start_date = Date.parse(params[:week_start])
    else
      # 今週の月曜日を取得
      @start_date = Date.current.beginning_of_week(:monday)
    end
  end

  def set_time_slot
    @time_slot = current_teacher.time_slots.find(params[:id])
  end

  def time_slot_params
    params.require(:time_slot).permit(:date, :start_time, :campus_id, :status)
  end

  # 営業時間の時間枠グリッドを生成
  def generate_time_slots_grid
    business_start = Time.parse('14:00')
    business_end = Time.parse('22:00')
    
    time_slots = []
    current_time = business_start
    
    while current_time < business_end
      time_slots << current_time
      current_time += 10.minutes
    end
    
    time_slots
  end
end
