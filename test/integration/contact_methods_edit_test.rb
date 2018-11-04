require 'test_helper'

class ContactMethodsEditTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
    @contact_method = contact_methods(:one)
    @contact_method_2 = contact_methods(:two)
    @contact_method_deleteable = ContactMethod.new(name: "Deleteable")
    @contact_method_deleteable.save!
    @non_admin = users(:one)
  end

  def teardown
    @contact_method_deleteable.destroy
  end

  test "No edits by non-admin" do
    log_in_as(@non_admin)
    get edit_contact_method_path(@contact_method)
    assert_redirected_to root_url
  end

  test "unsuccessful edit" do
    log_in_as(@user)
    get edit_contact_method_path(@contact_method)
    assert_template 'shared/simple_edit'
    patch contact_method_path(@contact_method), contact_method: { name:  "" }
    assert_template 'shared/simple_edit'
  end

  test "successful edit" do
    log_in_as(@user)
    get edit_contact_method_path(@contact_method)
    assert_template 'shared/simple_edit'
    name  = "Foo"
    patch contact_method_path(@contact_method), contact_method: { name:  name }
    assert_not flash.empty?
    assert_redirected_to contact_methods_url
    @contact_method.reload
    assert_equal @contact_method.name,  name
  end

  test "successful edit with friendly forwarding" do
    get edit_contact_method_path(@contact_method)
    log_in_as(@user)
    assert_redirected_to edit_contact_method_path(@contact_method)
    name  = "Foo"
    patch contact_method_path(@contact_method), contact_method: { name:  name }
    assert_not flash.empty?
    assert_redirected_to contact_methods_url
    @contact_method.reload
    assert_equal @contact_method.name,  name
  end

  test "successful delete as admin" do
    log_in_as(@user)
    get edit_contact_method_path(@contact_method_deleteable)
    assert_select 'a[href=?]', contact_method_path(@contact_method_deleteable), method: :delete

    assert_difference 'ContactMethod.count', -1 do
      delete contact_method_path(@contact_method_deleteable)
    end
  end

  test "no delete if attached to an contact" do
    log_in_as(@user)
    @contact = Contact.new(name: "Deletable")
    @contact.contact_method = @contact_method_deleteable
    @contact.save
    get edit_contact_method_path(@contact_method_deleteable)
    assert_select 'a[href=?]', contact_method_path(@contact_method_deleteable), method: :delete

    assert_no_difference 'ContactMethod.count' do
      delete contact_method_path(@contact_method_deleteable)
    end
    @contact.destroy
  end

  test "no duplicate creation" do
    log_in_as(@user)
    get edit_contact_method_path(@contact_method_2)
    assert_template 'shared/simple_edit'
    name  = @contact_method.name
    patch contact_method_path(@contact_method_2), contact_method: { name:  name }
    assert_select '.alert', 1
    @contact_method_2.reload
    assert_not_equal @contact_method_2.name,  name

  end


end