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
end
