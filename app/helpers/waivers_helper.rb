module WaiversHelper
  def link_to_add_waiver_fields(volunteer_id, is_guardian)
    association = :waivers
    puts "Is Guardian: #{is_guardian}"
    "add_fields_and_close(this, \'#{association}\', \'#{escape_javascript(add_waiver_fields(volunteer_id, is_guardian))}\', \'#{".add_waiver_fields"}\')"
  end

  def add_waiver_fields(volunteer_id, is_guardian)
    if is_guardian == false
      volunteer = Volunteer.find(session[:volunteer_id])
      guardian = Volunteer.find(volunteer_id)
    else
      volunteer = Volunteer.find(volunteer_id)
      guardian = nil
    end
    new_object = Waiver.new(birthdate: volunteer.birthdate, adult: volunteer.adult)
    puts "Is Guardian: #{is_guardian} Volunteer: #{volunteer.id}  Guardian: #{guardian ? guardian.id : "nil"}"
    puts new_object.to_yaml
    output = ""
    association = :waivers
    form_builder = form_for(volunteer) do |builder|
      output = builder.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
        render("waivers/waiver_fields", :f => builder, :parent => volunteer, :guardian => guardian, :association => association )
      end
    end
    output
  end

end
