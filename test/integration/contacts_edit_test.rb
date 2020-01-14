require 'test_helper'

class ContactsEditTest < ActionDispatch::IntegrationTest

  def setup
    @admin_user = users(:michael)
    @volunteer = volunteers(:one)
    @volunteer2 = volunteers(:duplicate)
    @non_admin_user1 = users(:one)
    @non_admin_user2 = users(:two)
    @contact_owned_by_user1 = contacts(:one)
    @contact_owned_by_user1.user_id = @non_admin_user1.id
    @contact_owned_by_user1.last_edit_user_id = @non_admin_user1.id
    @contact_owned_by_user1.save!
    @contact_un_owned = contacts(:two)
    @contact_un_owned.user_id = nil
    @contact_un_owned.last_edit_user_id = @non_admin_user2.id
    @contact_un_owned.save!
    @contact_volunteer2 = contacts(:other_volunteer)
    @contact_method1 = contact_methods(:one)
  end

  def teardown
  end

  test "No edits by non-admin user on contacts not owned by them" do
    log_in_as(@non_admin_user1)
    get edit_contact_path(@contact_owned_by_user1)
    # puts "Flash here #{flash[:error]}"
    assert_template 'edit'
    log_in_as(@non_admin_user2)
    get edit_contact_path(@contact_owned_by_user1)
    assert_redirected_to root_url
  end

  test "Cannot create a contact owned by another user if not admin" do
    log_in_as(@non_admin_user1)
    post contacts_path, params: { contact: { volunteer_id: @volunteer.id, contact_method_id: @contact_method1.id, user_id: @non_admin_user2.id, notes: "Blah" } }
    assert_redirected_to root_url
    log_in_as(@admin_user)
    post contacts_path, params: { contact: { volunteer_id: @volunteer.id, contact_method_id: @contact_method1.id, user_id: @non_admin_user2.id, notes: "Blah" } }
    assert_response :success
  end


  test "Edits set last_edit_user_id" do
    @contact_owned_by_user1.last_edit_user_id = @admin_user.id
    @contact_owned_by_user1.save!
    log_in_as(@non_admin_user1)
    patch contact_path( @contact_owned_by_user1), params: { contact: { notes:  "Blah" } }
    @contact_owned_by_user1.reload
    assert_equal  @contact_owned_by_user1.last_edit_user_id,  @non_admin_user1.id
  end

  test "Edits allowed by admins on contacts not owned by them" do
    log_in_as(@admin_user)
    get edit_contact_path( @contact_owned_by_user1)
    assert_template 'edit'
    patch contact_path( @contact_owned_by_user1), params: { contact: { notes:  "Blah" } }
    @contact_owned_by_user1.reload
    assert_equal  @contact_owned_by_user1.last_edit_user_id,  @admin_user.id
  end

  test "Admins and non-admins with security flag set can edit un-owned contacts" do

    # Admin can edit
    log_in_as(@admin_user)
    get edit_contact_path( @contact_un_owned)
    assert_template 'edit'
    patch contact_path( @contact_un_owned), params: { contact: { notes:  "Blah" } }
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
    patch contact_path(@contact_un_owned), params: { contact: { notes:  "Blah" } }
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
    assert_select "select[id='user_id']", false

    # Nobody can edit
    log_in_as(@admin_user)
    get edit_contact_path(@contact_owned_by_user1)
    assert_select "select[id='user_id']", false

    log_in_as(@non_admin_user1)
    get edit_contact_path(@contact_owned_by_user1)
    assert_select "select[id='user_id']", false

  end

  test "Only admin can delete" do
    log_in_as(@non_admin_user1)
    get edit_contact_path(@contact_owned_by_user1)
    assert_select 'a[href=?]', contact_path(@contact_owned_by_user1), { method: :delete, count: 0 }

    get contacts_volunteer_path(@contact_owned_by_user1.volunteer)
    assert_select 'a[href=?]', "#", { text: "delete", count: 0 }

    assert_difference 'Contact.count', 0 do
      delete contact_path(@contact_owned_by_user1)
    end

    log_in_as(@admin_user)
    get edit_contact_path(@contact_owned_by_user1)
    assert_select 'a[href=?]', contact_path(@contact_owned_by_user1), method: :delete

    get contacts_volunteer_path(@contact_owned_by_user1.volunteer)
    assert_select 'a[href=?]', "#", { text: "delete" }

    assert_difference 'Contact.count', -1 do
      delete contact_path(@contact_owned_by_user1)
    end

  end

  test "Admins can see all contacts in listing" do
    log_in_as(@admin_user)
    get contacts_volunteer_path(@volunteer)
    # Should not see volunteer 2 contact
    assert_select '[href=?]', edit_contact_path(@contact_volunteer2), {count: 0}
    assert_select '[href=?]', edit_contact_path(@contact_owned_by_user1), {count: 1}
    assert_select 'label[for="contact_user"]', {text: "by #{@contact_owned_by_user1.user.name}", count: 1}
    assert_select '[href=?]', edit_contact_path(@contact_un_owned), {count: 1}
    assert_select 'label[for="contact_user"]', {text: "by Unknown", count: 1}

  end

  test "Non-admins without security flag set can only see their contacts" do
    log_in_as(@non_admin_user1)
    puts "Non-admins without security flag set can only see their contacts"
    get contacts_volunteer_path(@volunteer)
    puts response.body
    assert_select '[href=?]', edit_contact_path(@contact_volunteer2), {count: 0}
    assert_select '[href=?]', edit_contact_path(@contact_owned_by_user1), {count: 1}
    assert_select 'label[for="contact_user"]', {text: "by #{@contact_owned_by_user1.user.name}", count: 0}
    assert_select '[href=?]', edit_contact_path(@contact_un_owned), {count: 0}

  end

  test "Non-admins with security flag set can see theirs and un-owned contacts" do
    @non_admin_user1.can_edit_unowned_contacts = true
    @non_admin_user1.save!
    log_in_as(@non_admin_user1)
    get contacts_volunteer_path(@volunteer)
    assert_select '[href=?]', edit_contact_path(@contact_volunteer2), {count: 0}
    assert_select '[href=?]', edit_contact_path(@contact_owned_by_user1), {count: 1}
    assert_select 'label[for="contact_user"]', {text: "by #{@contact_owned_by_user1.user.name}", count: 1}
    assert_select '[href=?]', edit_contact_path(@contact_un_owned), {count: 1}
    assert_select 'label[for="contact_user"]', {text: "by Unknown", count: 1}

  end


end