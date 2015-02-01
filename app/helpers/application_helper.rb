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

end
