class WaiversController < ApplicationController
  before_action :set_waiver, only: [:show, :edit, :update, :destroy]
  before_action :logged_in_user, only: [:index, :show, :create, :new, :edit, :update, :destroy, :signed_by]


  # GET /waivers
  # GET /waivers.json
  def index
    if !params[:volunteer_id].empty?
      @waivers = Waiver.where(volunteer_id: params[:volunteer_id])
     else
      @waivers = Waiver.all
    end
  end

  # GET /waivers/1
  # GET /waivers/1.json
  def show
    send_data(@waiver.data,
              type: 'application/pdf',
              filename: @waiver.filename)
  end

  # GET /waivers/new
  def new
    @waiver = Waiver.new()
  end

  # GET /waivers/1/edit
  def edit
  end

  # POST /waivers
  # POST /waivers.json
  def create
    @waiver = Waiver.new(waiver_params)

    respond_to do |format|
      if @waiver.save
        format.html { redirect_to @waiver, notice: 'Waiver was successfully created.' }
        format.json { render :show, status: :created, location: @waiver }
      else
        format.html { render :new }
        format.json { render json: @waiver.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /waivers/1
  # PATCH/PUT /waivers/1.json
  def update
    respond_to do |format|
      if @waiver.update(waiver_params)
        format.html { redirect_to @waiver, notice: 'Waiver was successfully updated.' }
        format.json { render :show, status: :ok, location: @waiver }
      else
        format.html { render :edit }
        format.json { render json: @waiver.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /waivers/1
  # DELETE /waivers/1.json
  def destroy
    @waiver.destroy
    respond_to do |format|
      format.html { redirect_to waivers_url, notice: 'Waiver was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def signed_by
    if params[:dialog] == "true"
      @volunteer = Volunteer.including_pending.find(session[:volunteer_id])
      render partial: "dialog_signed_by"
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_waiver
    @waiver = Waiver.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def waiver_params
    params.require(:waiver).permit(:volunteer_id, :guardian_id, :adult, :date_signed, :waiver_text, :e_sign, :file)
  end
end
