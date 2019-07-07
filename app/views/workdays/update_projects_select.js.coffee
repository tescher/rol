$("#project_ids").html("<%= escape_javascript(render(partial: "projects_select", collection: @projects, as: :project)) %>");
$("#project_ids").multiselect("rebuild");
