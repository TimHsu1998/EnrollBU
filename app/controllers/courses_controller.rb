class CoursesController < ApplicationController
  before_action :authenticate_user!
  def index
    @courses = current_user.courses.order("id DESC")
  end

  def new
    @course = Course.new
  end

  def create
    @course = Course.new(course_params)
    @course.user = current_user

    if @course.save
      redirect_to courses_path
    else
      render :new
    end
  end

  def edit
    @course = Course.find(params[:id])
  end

  def update
    @course = Course.find(params[:id])
    if @course.update(course_params)
      redirect_to courses_path
    else
      render :edit
    end
  end

  def destroy
    @course = Course.find(params[:id])

    @course.destroy

    redirect_to courses_path
  end

  private

  def course_params
    params.require(:course).permit(:name,:college,:department,:number,:section,
                                  :lab1, :lab2, :lab3, :lab4, :add_or_swap,
                                  :swapped_name,:swapped_college,:swapped_department,
                                  :swapped_number,:swapped_section, :swapped_lab,
                                  :loginemail, :loginpassword)
  end
end
