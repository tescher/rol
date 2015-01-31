// Use the Bootstrap datepicker

    $(document).ready(function() {
        $(function () {
            $("[id$='datepicker']").datetimepicker({
                format: 'M/D/YYYY'
            });
        });

    });