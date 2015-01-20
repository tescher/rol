require 'test_helper'

class VolunteersSearchTest < ActionDispatch::IntegrationTest

  def setup
    @user     = users(:one)
  end

  test "Search including pagination" do
    log_in_as(@user)
    get search_volunteers_path
    assert_template 'volunteers/search'
    get volunteers_path, params: {last_name: "e"}
    assert_select 'div.pagination'
    first_page_of_volunteers = Volunteer.paginate(page: 1)
    first_page_of_volunteers.each do |volunteer|
      assert_select 'a[href=?]', edit_volunteer_path(volunteer), text: volunteer.name
    end
  end


end