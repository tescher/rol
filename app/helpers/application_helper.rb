module ApplicationHelper


  # Returns the full title on a per-page basis.
  def full_title(page_title = '')
    base_title = SITE_TITLE
    if page_title.empty?
      base_title
    else
      "#{page_title} | #{base_title}"
    end
  end

  # Dynamic form helpers
  def link_to_remove_fields(name, f)
    f.hidden_field(:_destroy) + link_to("remove", "#", class: "remove_fields")
  end

  def link_to_add_fields(name, f, association, cssClass, parent_selector, title)
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render(association.to_s.singularize + "_fields", :f => builder)
    end
    link_to name, "#", :onclick => h("add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\", \"#{parent_selector}\")"), class: cssClass, title: title, remote: true
  end

  def link_to_select(object, alias_name)
    "set_selection_field(\"#{object.id}\", \"#{object.name}\", \"#{alias_name}\", $(this))"
  end

  def multi_email_valid(emails)
    all_ok = true
    emails.split(/\s*;\s*/).each do |host|
      all_ok = false unless(host =~ VALID_EMAIL_REGEX)
    end
    all_ok
  end

  # Quotes a string, escaping any ' (single quote) and \ (backslash) characters.
  def quote_string(s)
    s.gsub(/\\/, '\&\&').gsub(/'/, "''") # ' (for ruby-mode)
  end

  # turn a currency to a number
  def currency_to_number(currency)
    currency.to_s.gsub(/[$,]/,'').to_f
  end

  ### Controller Helpers

  #standard index action
  def standard_index(myclass, page = 1, always_paginate = false, index_view = "", order = nil)
    @objects = myclass.all
    if order
      @objects = @objects.order(order)
    end
    if always_paginate || (!defined? NO_PAGINATION) || !NO_PAGINATION
      @paginate = true
      @objects = @objects.paginate(page: page)
    else
      @paginate = false
    end
    render index_view.blank? ? 'shared/simple_index' : index_view
  end

  #standard delete action for simple controllers, catches errors and returns to edit
  def standard_destroy(myclass, id, edit_view = "")
    @object = myclass.find(id)
    begin
      @object.destroy
      flash[:success] = "#{myclass.name.underscore.tr("_"," ")} deleted"
      redirect_to url_for controller: myclass.name.underscore.pluralize, action: :index
    rescue => ex
      flash[:danger] = ex.message
      #redirect_to url_for controller: myclass.name.underscore.pluralize, id: id, action: :edit
      render edit_view.blank? ? 'shared/simple_edit' : edit_view
    end
  end

  #standard create action
  def standard_create(myclass, object_params)
    @object = myclass.new(object_params)
    if @object.save
      flash[:success] = "#{myclass.name.titleize} successfully created"
      redirect_to url_for(controller: myclass.name.underscore.pluralize, action: :index)
    else
      render 'shared/simple_new'
    end
  end

  #standard update action
  def standard_update(myclass, id, object_params)
    @object = myclass.find(id)
    if @object.update_attributes(object_params)
      flash[:success] = "#{myclass.name.titleize} updated"
      redirect_to url_for(controller: myclass.name.underscore.pluralize, action: :index)
    else
      render 'shared/simple_edit'
    end

  end

  # Confirms an admin user.
  def logged_in_admin_user
    if logged_in?
      redirect_to(root_url) unless current_user.admin?
    else
      store_location
      flash[:danger] = "Please log in."
      redirect_to login_url
    end
  end

  # Set class variables for all controller actions
  def set_controller_vars(controller_name)
    @class_name = controller_name.classify
  end

end
