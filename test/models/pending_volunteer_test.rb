require 'test_helper'

class PendingVolunteerTest < ActiveSupport::TestCase

  def setup
    @pending_volunter = PendingVolunteer.new()
  end

  test "Detect valid XML" do
    doc = Nokogiri::XML(File.read(File.join(Rails.root, "app", "test", "fixtures", "pending_volunteers_valid.xml")))
    @pending_volunteer.xml_data = doc.to_s
    puts @pending_volunteer.xml_data
    assert @pending.volunteer.valid?
  end

  test "Detect invalid XML" do
    doc = Nokogiri::XML(File.read(File.join(Rails.root, "app", "test", "fixtures", "pending_volunteers_invalid.xml")))
    @pending_volunteer.xml_data = doc.to_s
    puts @pending_volunteer.xml_data
    assert_not @pending.volunteer.valid?
  end
end