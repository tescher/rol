require 'test_helper'

class PendingVolunteerTest < ActiveSupport::TestCase

  def setup
    @doc = Nokogiri::XML(File.read(File.join(Rails.root, "test", "fixtures", "pending_volunteers_valid.xml")))
    @pending_volunteer = PendingVolunteer.new(xml: @doc.to_s)
  end

  test "Detect valid XML" do
    assert @pending_volunteer.valid?, @pending_volunteer.errors.full_messages
  end

  test "Detect invalid XML" do
    doc = Nokogiri::XML(File.read(File.join(Rails.root, "test", "fixtures", "pending_volunteers_invalid.xml")))
    @pending_volunteer.xml = doc.to_s
    assert_not @pending_volunteer.valid?
  end

  test "Data populated after save" do
    @pending_volunteer.save
    @pending_volunteer.reload
    assert_equal @pending_volunteer.first_name, @doc.xpath("data-set/first_name")[0].text
    assert_equal @pending_volunteer.middle_name, @doc.xpath("data-set/middle_name")[0].text
    assert_equal @pending_volunteer.last_name, @doc.xpath("data-set/last_name")[0].text

  end


end