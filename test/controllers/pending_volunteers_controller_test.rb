require 'test_helper'
require 'digest'

class PendingVolunteersControllerTest < ActionController::TestCase

  def setup
    @pending_volunteer = PendingVolunteer.new();
    doc = Nokogiri::XML(File.read(File.join(Rails.root, "test", "fixtures", "pending_volunteers_valid.xml")))
    @pending_volunteer.xml = doc.to_s
    @pending_volunteer.save!
    @pending_volunteer2 = PendingVolunteer.new();
    doc = Nokogiri::XML(File.read(File.join(Rails.root, "test", "fixtures", "pending_volunteers_valid2.xml")))
    @pending_volunteer2.xml = doc.to_s
    @pending_volunteer2.save!
    @pending_volunteer3 = PendingVolunteer.new();
    doc = Nokogiri::XML(File.read(File.join(Rails.root, "test", "fixtures", "pending_volunteers_valid3.xml")))
    @pending_volunteer3.xml = doc.to_s
    @pending_volunteer3.save!
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

  test "index display with nobody" do
    log_in_as(@user)
    @pending_volunteer.resolved = true
    @pending_volunteer.save!
    @pending_volunteer2.resolved = true
    @pending_volunteer2.save!
    @pending_volunteer3.resolved = true
    @pending_volunteer3.save!
    get :index
    assert_template 'shared/simple_index'
    assert_select 'span', /^No pending?/
  end

  test "match display" do
    log_in_as(@user)
    get :match, id: @pending_volunteer
    assert_template 'match'   # ToDo: Duplicate the matching algorithm?
  end


end
