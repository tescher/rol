module WaiversHelper
  def link_to_add_waiver_fields(volunteer_id, is_guardian)
    association = :waivers
    "add_fields_and_close(this, \'#{association}\', \'#{escape_javascript(add_waiver_fields(volunteer_id, is_guardian))}\', \'#{".add_waiver_fields"}\')"
  end

  def add_waiver_fields(volunteer_id, is_guardian)
    new_object = Waiver.new
    if is_guardian
      volunteer = Volunteer.find(session[:volunteer_id])
      guardian = Volunteer.find(volunteer_id)
    else
      volunteer = Volunteer.find(volunteer_id)
      guardian = nil
    end
    output = ""
    association = :waivers
    form_builder = form_for(volunteer) do |builder|
      output = builder.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
        render("waivers/waiver_fields", :f => builder, :parent => volunteer, :guardian => guardian, :association => association)
      end
    end
    output
  end

end
