class WaiverTextsController < ApplicationController
  before_action :set_waiver_text, only: [:show, :edit]
  before_action :logged_in_admin_user, only: [:index, :create, :new, :edit]


  # GET /waiver_texts
  # GET /waiver_texts.json
  def index
    @waiver_texts = WaiverText.all.order(created_at: :desc)
  end

  # GET /waiver_texts/1
  # GET /waiver_texts/1.json
  def show
    send_data(@waiver_text.data,
              type: 'application/pdf',
              filename: @waiver_text.filename)
  end

  # GET /waiver_texts/new
  def new
    @waiver_text = WaiverText.new
  end

  # GET /waiver_texts/1/edit
  def edit
  end

  # POST /waiver_texts
  # POST /waiver_texts.json
  def create
    @waiver_text = WaiverText.new(waiver_text_params)

    respond_to do |format|
      if @waiver_text.save
        format.html { redirect_to waiver_texts_path, notice: 'Waiver text was successfully created.' }
        format.json { render :show, status: :created, location: @waiver_text }
      else
        format.html { render :new }
        format.json { render json: @waiver_text.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_waiver_text
      @waiver_text = WaiverText.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def waiver_text_params
      params.require(:waiver_text).permit(:file, :waiver_type)
    end
end
