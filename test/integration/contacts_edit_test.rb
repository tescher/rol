require 'test_helper'

class ContactsEditTest < ActionDispatch::IntegrationTest

  def setup
    @admin_user = users(:michael)
    @volunteer = volunteers(:one)
    @non_admin_user1 = users(:one)
    @non_admin_user2 = users(:two)
  end

  def teardown
  end

  test "No edits by non-admin user on contacts not owned by them" do
    contact = Contact.new(volunteer_id:@volunteer.id, date_time:1.day.ago.to_s(:db), user_id: @non_admin_user1.id, last_edit_user_id: @admin_user.id, contact_method_id: 1)
    contact.save!
    log_in_as(@non_admin_user1)
    get edit_contact_path(contact)
    assert_template 'edit'
    log_in_as(@non_admin_user2)
    get edit_contact_path(contact)
    assert_redirected_to root_url
  end

  test "Edits set last_edit_user_id" do
    contact = Contact.new(volunteer_id:@volunteer.id, date_time:1.day.ago.to_s(:db), user_id: @non_admin_user1.id, contact_method_id: 1)
    contact.save!
    log_in_as(@non_admin_user1)
    patch contact_path(contact), contact: { notes:  "Blah" }
    contact.reload
    assert_equal contact.last_edit_user_id,  @non_admin_user1.id
  end

  test "Edits allowed by admins on contacts not owned by them" do
    contact = Contact.new(volunteer_id:@volunteer.id, date_time:1.day.ago.to_s(:db), user_id: @non_admin_user1.id, last_edit_user_id: @non_admin_user1.id, contact_method_id: 1)
    contact.save!
    log_in_as(@admin_user)
    get edit_contact_path(contact)
    assert_template 'edit'
    patch contact_path(contact), contact: { notes:  "Blah" }
    contact.reload
    assert_equal contact.last_edit_user_id,  @admin_user.id
  end

  test "Admins and non-admins with security flag set can edit un-owned contacts" do
    # Old contact without owner
    contact = Contact.new(volunteer_id:@volunteer.id, date_time:1.day.ago.to_s(:db), user_id: @non_admin_user1.id, last_edit_user_id: @non_admin_user1.id, contact_method_id: 1)
    contact.save!
    contact.user_id = nil
    contact.save!

    # Admin can edit
    log_in_as(@admin_user)
    get edit_contact_path(contact)
    assert_template 'edit'
    patch contact_path(contact), contact: { notes:  "Blah" }
    contact.reload
    assert_equal contact.last_edit_user_id,  @admin_user.id

    # Non-admin can't edit
    log_in_as(@non_admin_user1)
    get edit_contact_path(contact)
    assert_redirected_to root_url

    # Non-admin with flag set can edit
    @non_admin_user1.can_edit_unowned_contacts = true
    @non_admin_user1.save!
    get edit_contact_path(contact)
    assert_template 'edit'
    patch contact_path(contact), contact: { notes:  "Blah" }
    contact.reload
    assert_equal contact.last_edit_user_id,  @non_admin_user1.id
  end

  test "Admin can change contact owner only if owner is empty" do

  end

  test "Only admin can delete" do

  end

  test "Admins can see all contacts in listing" do

  end

  test "Non-admins without security flag set can only see their contacts" do

  end

  test "Non-admins with security flag set can see theirs and un-owned contacts" do

  end


end