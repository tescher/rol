module WorkdaysHelper

  def link_to_add_workday_volunteer_fields(volunteer, workday_id)
    association = :workday_volunteers
    "add_fields_and_close(this, \'#{association}\', \'#{escape_javascript(add_workday_volunteer_fields(volunteer, workday_id))}\', \'#{".add_volunteer_fields"}\')"
  end

  def link_to_add_workday_organization_fields(organization, workday_id)
    association = :workday_organizations
    "add_fields_and_close(this, \'#{association}\', \'#{escape_javascript(add_workday_organization_fields(organization, workday_id))}\', \'#{".add_organization_fields"}\')"
  end

  def add_workday_volunteer_fields(volunteer, workday_id)
    new_object = WorkdayVolunteer.new
    workday = Workday.find(workday_id)
    output = ""
    association = :workday_volunteers
    form_builder = form_for(workday) do |builder|
      output = builder.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
        render("workdays/workday_volunteer_fields", :f => builder, :volunteer => volunteer, :association => association)
      end
    end
    output
  end

  def add_workday_organization_fields(organization, workday_id)
    new_object = WorkdayOrganization.new
    workday = Workday.find(workday_id)
    output = ""
    association = :workday_organizations
    form_builder = form_for(workday) do |builder|
      output = builder.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
        render("workdays/workday_organization_fields", :f => builder, :organization => organization, :association => association)
      end
    end
    output
  end

end

