$('a.form.popup').live('click', function(e) {
  e.preventDefault();
  createFormDialog($(this).attr('href'), $(this).attr('title'), $(this).closest('.table'));
});

$('a.show.popup').click(function(e) {
  e.preventDefault();
  $('#modal-form').remove();
  opts = {
    width: 600,
    title: $(this).attr('title'),
    dialogClass: 'modal-form'
  };
  
  $('<div id="modal-form" />')
  .appendTo($('body'))
  .html('<img src="/images/spinner.gif" style="display: block; margin: 0 auto;"/>')
  .load($(this).attr('href'))
  .dialog(dialogOptions(opts));
});

$('a.delete.popup').live('click', function(e) {
  e.preventDefault();
  e.stopPropagation();
  var $a = $(this);
  var msg = $a.attr('data-message');
  if (!msg) msg = "Are you sure you want to delete this?"
  confirmDialog(msg, {
    'yes': function() {
      $.ajax({
        url: $a.attr('href'),
        type: 'delete', 
        success: function(data, status) {
          var $row = $a.closest('tr');
          $row.fadeOut('normal', function() {
            $row.remove();
          });
        }
      });
      $('#modal-form').dialog('destroy');
    },
    'no': function() {
      $('#modal-form').dialog('destroy');
    }
  });
});
