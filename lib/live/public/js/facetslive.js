// Send an ajax request to rate script.
function star(script_id){
  $.get('/star/' + script_id);
};

function flag(script_id){
  $.get('/flag/' + script_id);
};

function submit_enter(myfield,e)
{
  var keycode;
  if (window.event) keycode = window.event.keyCode;
  else if (e) keycode = e.which;
  else return true;

  if (keycode == 13) {
   myfield.form.submit();
   return false;
  } else {
    return true;
  }
};

function name_copy(id, old_name) {
  var n = prompt("Name of copy?", old_name);
  if(n != null) {
    location.href="/copy/" + id + "/" + n;
  };
};

