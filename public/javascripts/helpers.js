var $flash_error = $('<div class="flash error" />');
var $flash_message = $('<div class="flash success" />');

function showFlashMessage(msg) {
  $('#header').prepend($flash_message.html(msg).fadeIn().delay(4000).fadeOut('slow', function() { $(this).remove(); }));
}

function showFlashError(msg) {
  $('#header').prepend($flash_error.html(msg).fadeIn().delay(4000).fadeOut('slow', function() { $(this).remove(); }));
}

DIALOG_DEFAULTS = {
  position: ['center', 'top'],
  modal: true,
  draggable: false,
  resizable: false
}

function dialogOptions(opts) {
  return $.extend({}, DIALOG_DEFAULTS, opts);
}

function confirmDialog(message, ajax_options) {
  $('#modal-form').remove();
  opts = {
    width: 400,
    title: 'Are you sure?',
    buttons: {
      'Yes': ajax_options['yes'],
      'No' : ajax_options['no']
    },
    height: 200
  }
  $('<div id="modal-form" />')
  .html(message)
  .appendTo($('body'))
  .dialog(dialogOptions(opts));
}

function createFormDialog(url, title, context, options) {
  $('#modal-form').remove();
  var opts = {
    width: 600,
    title: title,
    dialogClass: 'modal-form',
    buttons: {
      'Save': function() {
        $.ajax({
          url: $('#modal-form form').attr('action'),
          type: 'POST',
          dataType: 'json',
          data: $('#modal-form form').serialize(),
          context: context,
          success: function(data, status) {
            var that = this;
            if(data.errors) {
              if(!$('.errors').length) {
                $('#modal-form form').prepend($('<div class="errors" />'));
              }
              $('.errors').html(data.errors);
            } else {
              showFlashMessage(data.message);
              that.fadeOut('normal', function(){
                that.replaceWith(data.list);
                that.fadeIn('normal');
              });
              $('#modal-form').dialog('close');
              $('#modal-form').dialog('destroy');
            }
          }
        });
      },
      Cancel: function() {
        $(this).dialog('close');
      }
    },
    close: function() {
      $('#modal-form').dialog('destroy');
      $('#modal-form').remove();
    }
  };
  if(typeof options != 'undefined') {
    $.extend(opts, options);
  }
  
  $('<div id="modal-form" />')
  .appendTo($('body'))
  .html('<img src="/images/spinner.gif" style="display: block; margin: 0 auto;"/>')
  .load(url, function(data) {
    var $submit = $('#modal-form input[name=commit]');
    if($submit.length) {
      opts.buttons[$submit.val()] = opts.buttons['Save'];
      delete opts.buttons['Save'];
      $submit.remove();
    }
    $(this).dialog(dialogOptions(opts));
  });
  
}