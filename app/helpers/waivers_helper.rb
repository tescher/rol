module WaiversHelper
  def link_to_add_waiver_fields(volunteer_id, is_guardian)
    association = :waivers
    puts "Is Guardian: #{is_guardian}"
    "add_fields_and_close(this, \'#{association}\', \'#{escape_javascript(add_waiver_fields(volunteer_id, is_guardian))}\', \'#{".add_waiver_fields"}\')"
  end

  def add_waiver_fields(volunteer_id, is_guardian)
    puts "Is Guardian: #{is_guardian} #{is_guardian.to_yaml}"
    if is_guardian == true
      volunteer = Volunteer.find(session[:volunteer_id])
      guardian = Volunteer.find(volunteer_id)
    else
      volunteer = Volunteer.find(volunteer_id)
      guardian = nil
    end
    new_object = Waiver.new(birthdate: volunteer.birthdate, adult: volunteer.adult)
    if !is_guardian
      new_object.adult = true
    end
    puts "Is Guardian: #{is_guardian} Volunteer: #{volunteer.id}  Guardian: #{guardian ? guardian.id : "nil"}"
    output = ""
    association = :waivers
    form_builder = form_for(volunteer) do |builder|
      output = builder.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
        render("waivers/waiver_fields", :f => builder, :parent => volunteer, :guardian => guardian, :association => association )
      end
    end
    output
  end

  def last_waiver(volunteer_id)
    Waiver.where(volunteer_id: volunteer_id).order(date_signed: :desc).first
  end


end
