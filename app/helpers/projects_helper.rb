module ProjectsHelper
  def link_to_add_homeowner_fields(volunteer, project_id)
    association = :homeowner_projects
    "add_fields_and_close(this, \'#{association}\', \'#{escape_javascript(add_homeowner_fields(volunteer, project_id))}\', \'#{".add_homeowner_fields"}\')"
  end

  def add_homeowner_fields(volunteer, project_id)
    new_object = HomeownerProject.new(volunteer_id: volunteer.id)
    if (project_id)
      project = Project.find(project_id)
    else
      project = Project.new
    end
    # project = Project.find(project_id)
    output = ""
    association = :homeowner_projects
    form_builder = form_for(project)  do |builder|
      output = builder.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
        render("projects/homeowner_project_fields", :f => builder, :homeowner => volunteer, :association => association )
      end
    end
    output
  end
end
