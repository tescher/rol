class WorkdaysController < ApplicationController
  before_action :set_workday, only: [:show, :edit, :update, :destroy]

  # GET /workdays
  # GET /workdays.json
  def index
    @workdays = Workday.all
  end

  # GET /workdays/1
  # GET /workdays/1.json
  def show
  end

  # GET /workdays/new
  def new
    @workday = Workday.new
  end

  # GET /workdays/1/edit
  def edit
  end

  # POST /workdays
  # POST /workdays.json
  def create
    @workday = Workday.new(workday_params)

    respond_to do |format|
      if @workday.save
        format.html { redirect_to @workday, notice: 'Workday was successfully created.' }
        format.json { render :show, status: :created, location: @workday }
      else
        format.html { render :new }
        format.json { render json: @workday.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /workdays/1
  # PATCH/PUT /workdays/1.json
  def update
    respond_to do |format|
      if @workday.update(workday_params)
        format.html { redirect_to @workday, notice: 'Workday was successfully updated.' }
        format.json { render :show, status: :ok, location: @workday }
      else
        format.html { render :edit }
        format.json { render json: @workday.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /workdays/1
  # DELETE /workdays/1.json
  def destroy
    @workday.destroy
    respond_to do |format|
      format.html { redirect_to workdays_url, notice: 'Workday was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_workday
      @workday = Workday.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def workday_params
      params.require(:workday).permit(:description, :project_id)
    end
end
