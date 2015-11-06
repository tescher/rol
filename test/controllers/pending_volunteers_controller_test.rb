require 'test_helper'
require 'digest'

class PendingVolunteersControllerTest < ActionController::TestCase

  def setup
    @pending_volunteer = PendingVolunteer.new();
    doc = Nokogiri::XML(File.read(File.join(Rails.root, "test", "fixtures", "pending_volunteers_valid.xml")))
    @pending_volunteer.xml = doc.to_s
    @pending_volunteer.save!
    @user = users(:one)
  end

  test "should error or redirect all but post if not logged in " do
    get :new
    assert_response :forbidden, "Should not respond to New"
    get :show, id: @pending_volunteer
    assert_response :forbidden, "Should not respond to Show"
    patch :update, id: @pending_volunteer, pending_volunteer: { xml: "" }
    assert_not flash.empty?
    assert_redirected_to login_url
    delete :destroy, id: @pending_volunteer
    assert_response :forbidden, "Should not respond to Delete"
    get :index
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "respond post if hash correct" do
    doc = Nokogiri::XML(File.read(File.join(Rails.root, "test", "fixtures", "pending_volunteers_valid.xml")))
    @request.host = "www.tim.testing.com"
    hash = Digest::SHA1.hexdigest(doc.to_s + "testing.com")
    post :create, pending_volunteer: { xml: doc.to_s, hash: hash }
    assert_difference "PendingVolunteer.count", 1 do
      post :create, pending_volunteer: { xml: doc.to_s, hash: hash }
      assert_response :success
    end
  end

  test "respond post if hash incorrect" do
    doc = Nokogiri::XML(File.read(File.join(Rails.root, "test", "fixtures", "pending_volunteers_valid.xml")))
    @request.host = "www.tim.testing.com"
    hash = Digest::SHA1.hexdigest(doc.to_s + "invalid")
    assert_difference "PendingVolunteer.count", 0 do
      post :create, pending_volunteer: { xml: doc.to_s, hash: hash }
      assert_response :unprocessable_entity
    end
  end

  test "index display" do
    log_in_as(@user)
    get :index
    assert_template 'shared/simple_index'
    pending_volunteers = PendingVolunteer.where(resolved: false)
    pending_volunteers.each do |pending_volunteer|
      assert_select 'div[href=?]', match_pending_volunteer_path(pending_volunteer)
    end
  end

  test "match display" do
    log_in_as(@user)
    get :match, id: @pending_volunteer
    assert_template 'match'
    pending_volunteers = PendingVolunteer.where(resolved: false)
    pending_volunteers.each do |pending_volunteer|
      assert_select 'div[href=?]', edit_pending_volunteer_path(pending_volunteer)
    end
  end


end
