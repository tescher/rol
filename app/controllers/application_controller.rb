class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include SessionsHelper

  before_action :fix_params

  private

  # to get around the httparty bug that turns [] into [""] on http calls.
  def fix_params
    params.transform_values! { |v| v.kind_of?(Array) && (v[0] == "") ? [] : v }
  end


end
