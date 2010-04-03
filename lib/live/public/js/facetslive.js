// Send an ajax request to rate script.
function star(script_id){
  $.get('/star/' + script_id);
};

function flag(script_id){
  $.get('/flag/' + script_id);
};

