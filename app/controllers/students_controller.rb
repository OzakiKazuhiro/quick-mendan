class StudentsController < ApplicationController
  before_action :authenticate_student!
  # ダッシュボードページのキャッシュを無効化（セキュリティ対策）
  before_action :prevent_caching, only: [:dashboard]
  
  def dashboard
    @student = current_student
    @campus = @student.campus
    @teachers_count = Teacher.count
    @campuses_count = Campus.count
  end
end 