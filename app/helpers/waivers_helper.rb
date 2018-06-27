module WaiversHelper
  def link_to_add_waiver_fields(volunteer_id)
    association = :waivers
    "add_fields_and_close(this, \'#{association}\', \'#{escape_javascript(add_waiver_fields(volunteer_id))}\', \'#{".add_waiver_fields"}\')"
  end

  def add_waiver_fields(volunteer_id)
    new_object = Waiver.new
    volunteer = Volunteer.find(volunteer_id)
    output = ""
    association = :waivers
    form_builder = form_for(volunteer) do |builder|
      output = builder.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
        render("waivers/waiver_fields", :f => builder, :parent => volunteer, :association => association)
      end
    end
    output
  end

end
