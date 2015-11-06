require 'digest'
include ApplicationHelper

class PendingVolunteersController < ApplicationController
  before_filter { |c| c.set_controller_vars(controller_name) }
  before_action :logged_in_user, only: [:index, :update, :match]
  before_action :send_forbidden,  except: [:create, :index, :update, :match]

  def new

  end

  def update

  end

  def index
    standard_index(PendingVolunteer.where(resolved: false), params[:page])
  end

  def match

  end

  def destroy

  end

  def create
    xml = pending_volunteer_params[:xml]
    hash = pending_volunteer_params[:hash]
    domain = request.host.split('.').last(2).join('.')
    check_hash = Digest::SHA1.hexdigest(xml + domain)
    if (hash != check_hash)
      render text: "Bad hash", status: :unprocessable_entity
    else
      @pending_volunteer = PendingVolunteer.new()
      @pending_volunteer.xml = xml
      if @pending_volunteer.save
        render text: "Saved"
      else
        render text: "Bad XML", status: :unprocessable_entity
      end
    end
  end

  def show

  end

  private

  def pending_volunteer_params
    params.require(:pending_volunteer).permit(:xml, :hash)
  end

  def send_forbidden
    head :forbidden
  end


end
