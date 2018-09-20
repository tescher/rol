module WaiversHelper
  def link_to_add_waiver_fields(volunteer_id, is_guardian)
    association = :waivers
    "add_fields_and_close(this, \'#{association}\', \'#{escape_javascript(add_waiver_fields(volunteer_id, is_guardian))}\', \'#{".add_waiver_fields"}\')"
  end

  def add_waiver_fields(volunteer_id, is_guardian)
    if is_guardian == true
      volunteer = Volunteer.including_pending.find(session[:volunteer_id])
      guardian = Volunteer.including_pending.find(volunteer_id)
    else
      volunteer = Volunteer.including_pending.find(volunteer_id)
      guardian = nil
    end
    new_object = Waiver.new(adult: need_waiver_type(volunteer, false) == WaiverText.waiver_types[:adult])
    if !is_guardian
      new_object.adult = true
    end
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

  def last_waiver_date(volunteer_id)
    waiver = last_waiver(volunteer_id)
    if waiver
      puts "Found waiver"
      waiver.date_signed ? waiver.date_signed : waiver.created_at.to_date
    else
      Volunteer.including_pending.find(volunteer_id).waiver_date
    end
  end

  # If a waiver is needed, it will return the type needed (adult or minor). If "check_last_waiver" is false, it will return type for any new waiver
  def need_waiver_type(volunteer, check_last_waiver = true)
    if check_last_waiver
      waiver = last_waiver(volunteer.id)
    end
    if !waiver || ((DateTime.now.to_date - waiver.effective_date_signed) > Utilities::Utilities.system_setting(:waiver_valid_days))
      birthdate = volunteer.birthdate
      if volunteer.adult || (birthdate && age(birthdate) >= Utilities::Utilities.system_setting(:adult_age))
        return WaiverText.waiver_types[:adult]
      else
        return WaiverText.waiver_types[:minor]
      end
    end
    return nil
  end

  def effective_waiver_text(waiver = nil, waiver_type = nil)
    if !waiver
      WaiverText.where("created_at <= ?", Time.zone.now).where(waiver_type: waiver_type).order(created_at: :desc).first
    else
      if waiver.e_sign == true
        if waiver.adult == true
          waiver_type = WaiverText.waiver_types[:adult]
        else
          waiver_type = WaiverText.waiver_types[:minor]
        end
        WaiverText.where("created_at <= ?", waiver.created_at).where(waiver_type: waiver_type).order(created_at: :desc).first
      else
        waiver.data ? waiver : nil
      end
    end
  end


end
