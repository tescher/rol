// Use the Bootstrap multiselect

    $(document).ready(function() {
        $('[id*=interest_ids]').multiselect();

        $(".multiselect-container").find("label.checkbox").contents().filter(function() { return this.nodeType === 3 }).each(function() {
            var name=$(this).text();
            if (name.substring(0,2) == " *") {
                $(this).replaceWith("<b> "+name.substring(2)+"</b>")
            }
            if (name.substring(0,2) == " /") {
                $(this).replaceWith("<s> "+name.substring(2)+"</s>")
            }
        })
    });