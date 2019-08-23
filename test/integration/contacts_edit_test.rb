require 'test_helper'

class ContactsEditTest < ActionDispatch::IntegrationTest

  def setup
    @admin_user = users(:michael)
    @volunteer = volunteers(:one)
    @non_admin_user1 = users(:one)
    @non_admin_user2 = users(:two)
    @contact_owned_by_user1 = contacts(:one)
    @contact_un_owned = contacts(:two)
    @contact_un_owned.user_id = nil
    @contact_un_owned.save!
  end

  def teardown
  end

  test "No edits by non-admin user on contacts not owned by them" do
    log_in_as(@non_admin_user1)
    get edit_contact_path(@contact_owned_by_user1)
    assert_template 'edit'
    log_in_as(@non_admin_user2)
    get edit_contact_path(@contact_owned_by_user1)
    assert_redirected_to root_url
  end

  test "Edits set last_edit_user_id" do
    @contact_owned_by_user1.last_edit_user_id = @admin_user
    @contact_owned_by_user1.save!
    log_in_as(@non_admin_user1)
    patch contact_path( @contact_owned_by_user1), contact: { notes:  "Blah" }
    @contact_owned_by_user1.reload
    assert_equal  @contact_owned_by_user1.last_edit_user_id,  @non_admin_user1.id
  end

  test "Edits allowed by admins on contacts not owned by them" do
    log_in_as(@admin_user)
    get edit_contact_path( @contact_owned_by_user1)
    assert_template 'edit'
    patch contact_path( @contact_owned_by_user1), contact: { notes:  "Blah" }
    @contact_owned_by_user1.reload
    assert_equal  @contact_owned_by_user1.last_edit_user_id,  @admin_user.id
  end

  test "Admins and non-admins with security flag set can edit un-owned contacts" do

    # Admin can edit
    log_in_as(@admin_user)
    get edit_contact_path( @contact_un_owned)
    assert_template 'edit'
    patch contact_path( @contact_un_owned), contact: { notes:  "Blah" }
    @contact_un_owned.reload
    assert_equal  @contact_un_owned.last_edit_user_id,  @admin_user.id

    # Non-admin can't edit
    log_in_as(@non_admin_user1)
    get edit_contact_path( @contact_un_owned)
    assert_redirected_to root_url

    # Non-admin with flag set can edit
    @non_admin_user1.can_edit_unowned_contacts = true
    @non_admin_user1.save!
    get edit_contact_path(@contact_un_owned)
    assert_template 'edit'
    patch contact_path(@contact_un_owned), contact: { notes:  "Blah" }
    @contact_un_owned.reload
    assert_equal @contact_un_owned.last_edit_user_id,  @non_admin_user1.id
  end

  test "Admin can change contact owner only if owner is empty" do

    # Admin can edit owner
    log_in_as(@admin_user)
    get edit_contact_path(@contact_un_owned)
    assert_select "select[id='contact_user_id']"

    # Non-admin cannot
    log_in_as(@non_admin_user1)
    get edit_contact_path(@contact_un_owned)
    assert_select "select[id='contact_user_id']", false

    # Nobody can edit
    log_in_as(@admin_user)
    get edit_contact_path(@contact_owned_by_user1)
    assert_select "select[id='contact_user_id']", false

    log_in_as(@non_admin_user1)
    get edit_contact_path(@contact_owned_by_user1)
    assert_select "select[id='contact_user_id']", false

  end

  test "Only admin can delete" do
    log_in_as(@non_admin_user1)
    get edit_interest_path(@contact_owned_by_user1)
    assert_select 'a[href=?]', contact_path(@contact_owned_by_user1), { method: :delete }, false

    assert_difference 'Contact.count', 0 do
      delete contact_path(@contact_owned_by_user1)
    end

    log_in_as(@admin_user)
    get edit_interest_path(@contact_owned_by_user1)
    assert_select 'a[href=?]', contact_path(@contact_owned_by_user1), method: :delete

    assert_difference 'Contact.count', -1 do
      delete contact_path(@contact_owned_by_user1)
    end

  end

  test "Admins can see all contacts in listing" do

  end

  test "Non-admins without security flag set can only see their contacts" do

  end

  test "Non-admins with security flag set can see theirs and un-owned contacts" do

  end


end