require "byebug"

class SelfTrackingController < ApplicationController
  before_action :has_valid_token, only: [
    :index
  ]

  def has_valid_token
    if !session[:workday_id].present?
      flash[:danger] = "No workday found, please launch this feature again from the workday screen."
      redirect_to root_path
    end
  end

  def launch
    @workday = Workday.find(params[:id])
    user_id = session[:user_id]

    # Create a token for this session
    new_token = "create_here"

    # Logout the user
    log_out

    # Save the token in the session
    # reset_session
    session[:self_tracking_token] = new_token
    session[:workday_id] = @workday.id
    session[:launching_user_id] = @workday.id

    redirect_to action: "index"
  end

  def index
    # byebug
    @workday = Workday.find(session[:workday_id])
    @project = Project.find(@workday.project_id)
  end

  def volunteer_search
    if params[:search_form].present?
      @search_form = SearchForm.new(params[:search_form])
      if @search_form.valid?
        last_name, first_name = @search_form.name.split(",")

        where_clause = []
        where_clause.push(Volunteer.get_fuzzymatch_where_clause("last_name", last_name)) if last_name.present?
        where_clause.push(Volunteer.get_fuzzymatch_where_clause("first_name", first_name)) if first_name.present?
        where_clause.push("email = #{Volunteer.sanitize(@search_form.email)}") if @search_form.email.present?
        where_clause.push("(mobile_phone LIKE %{phone} OR work_phone LIKE %{phone} OR home_phone LIKE %{phone})" % {
          :phone => "#{Volunteer.sanitize(@search_form.phone)}"}) if @search_form.phone.present?

        @results = Volunteer.where(where_clause.join(" OR ")).order(:last_name, :first_name)

        render partial: "search_results"
      else
        render partial: "volunteer_search"
      end
    else
      @search_form = SearchForm.new()
      render partial: "volunteer_search"
    end
  end
end

class SearchForm
  include ActiveModel::Model

  attr_accessor :name, :phone, :email

  validates_presence_of :name
end
