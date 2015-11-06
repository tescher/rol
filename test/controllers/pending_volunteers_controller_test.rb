require 'test_helper'
require 'digest'

class PendingVolunteersControllerTest < ActionController::TestCase

  def setup
    @pending_volunteer = PendingVolunteer.new();
    doc = Nokogiri::XML(File.read(File.join(Rails.root, "test", "fixtures", "pending_volunteers_valid.xml")))
    @pending_volunteer.xml = doc.to_s
    @pending_volunteer.save!
  end

  test "should error all but post" do
    get :new
    assert_response :forbidden, "Should not respond to New"
    get :show, id: @pending_volunteer
    assert_response :forbidden, "Should not respond to Show"
    patch :update, id: @pending_volunteer, pending_volunteer: { xml: "" }
    assert_response :forbidden, "Should not respond to Update"
    delete :destroy, id: @pending_volunteer
    assert_response :forbidden, "Should not respond to Delete"
    get :index
    assert_response :forbidden, "Should not respond to Index"
  end

  test "respond if hash correct" do
    doc = Nokogiri::XML(File.read(File.join(Rails.root, "test", "fixtures", "pending_volunteers_valid.xml")))
    @request.host = "www.tim.testing.com"
    hash = Digest::SHA1.hexdigest(doc.to_s + "testing.com")
    post :create, pending_volunteer: { xml: doc.to_s, hash: hash }
    assert_difference "PendingVolunteer.count", 1 do
      post :create, pending_volunteer: { xml: doc.to_s, hash: hash }
      assert_response :success
    end
  end

  test "respond if hash incorrect" do
    doc = Nokogiri::XML(File.read(File.join(Rails.root, "test", "fixtures", "pending_volunteers_valid.xml")))
    @request.host = "www.tim.testing.com"
    hash = Digest::SHA1.hexdigest(doc.to_s + "invalid")
    assert_difference "PendingVolunteer.count", 0 do
      post :create, pending_volunteer: { xml: doc.to_s, hash: hash }
      assert_response :unprocessable_entity
    end
  end


end
