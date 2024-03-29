require 'test_helper'

class WorkdaysEditTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:one)
    @workday = workdays(:one)
    @workday_2 = workdays(:two)
  end


  test "unsuccessful edit" do
    log_in_as(@user)
    get edit_workday_path(@workday)
    assert_template 'workdays/edit'
    patch workday_path(@workday), params: { workday: { name:  "" } }
    assert_template 'workdays/edit'
  end

  test "successful edit" do
    log_in_as(@user)
    get edit_workday_path(@workday)
    assert_template 'workdays/edit'
    name  = "Foo"
    project_id = 2
    patch workday_path(@workday), params: { workday: { name:  name,
                                                   project_id: project_id} }
    assert_redirected_to add_participants_workday_path(@workday)
    @workday.reload
    assert_equal @workday.name,  name
    assert_equal @workday.project_id,  project_id
  end

  test "successful edit with friendly forwarding. Edit of basic info redirects to Add Participants" do
    get edit_workday_path(@workday)
    log_in_as(@user)
    assert_redirected_to edit_workday_path(@workday)
    name  = "Foo"
    project_id = 2
    patch workday_path(@workday), params: { workday: { name:  name,
                                                project_id: project_id} }
    assert_redirected_to add_participants_workday_path(@workday)
    @workday.reload
    assert_equal @workday.name,  name
    assert_equal @workday.project_id,  project_id
  end

  test "successful delete as non-admin" do
    log_in_as(@user)
    get edit_workday_path(@workday)
    assert_select 'a[href=?]', workday_path(@workday), method: :delete

    assert_difference 'Workday.count', -1 do
      delete workday_path(@workday)
    end
  end


  test "no duplicate creation" do
    log_in_as(@user)
    get edit_workday_path(@workday_2)
    assert_template 'workdays/edit'
    name  = @workday.name
    project = @workday.project_id
    workdate = @workday.workdate.strftime("%m/%d/%Y")
    patch workday_path(@workday_2), params: { workday: { name:  name, project_id: project, workdate: workdate } }
    assert_select '.alert', 1
    @workday_2.reload
    assert_not_equal @workday_2.name,  name

  end



end