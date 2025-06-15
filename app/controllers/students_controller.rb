class StudentsController < ApplicationController
  before_action :authenticate_student!
  
  def dashboard
    @student = current_student
    @campus = @student.campus
    @teachers_count = Teacher.count
    @campuses_count = Campus.count
  end
end 