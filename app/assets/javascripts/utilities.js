/**
 * Created by tescher on 1/27/15.
 */

jQuery(document).ready(function($) {
    $(".row.clickable").click(function() {
        window.document.location = $(this).attr("href");
    });

});

