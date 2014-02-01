window.onload = function () {
 $('select').css('background-color',this.value);
 $('select').css('color',"white");
}

$(document).on('change','select',function(e){
    $(this).css('background-color',this.value);
    var id = $(this).closest('tr').attr('id');
    var val = $('option:selected', this).attr('val');
    $.ajax({
      url: 'status',
      type: 'PUT',
      data: { id: id, value: val },
    });
});

$(document).on('click','.toggle-col',function(e){
    $element = $(this);
    $content = $element.next();
    $content.slideToggle(370, function () {
    });
});

$(document).ready(function(){
  $('.add').click(function(e){
    var name = $("#addTxt").val();
    $.ajax({
    url: 'add',
    type: 'POST',
    data: { name: name },
    success: function( result ) {
            $("#tabulka").prepend(result);
            $("#notification").append(notification);
            $('select').css('background-color',this.value);
            $('select').css('color',"white");
      }
    });
    var notification = '<div class="alert alert-success alert-dismissable"> \
                      <button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button> \
                      <strong>Success!</strong> Added. \
                      </div>'
  });
});

$(function(){
  $(document).tooltip();
});

$(document).on('click','.save',function(e){
    var which = $(this).closest('tr');

    var start_time = which.find(".start-time").val();
    var end_time = which.find(".end-time").val();
    var date = which.find(".date").val();
    var to_save = which.attr('id');
    var table = which.find("#table-log");

    if((start_time == '') || (end_time == '') || (date == '')){
      var notification = '<div class="alert alert-danger alert-dismissable"> \
                        <button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button> \
                        <strong>You must fill all fields!</strong> \
                        </div>'
      $("#notification").append(notification);
    } else if ((check(start_time)) && (check(end_time))) {
      var notification = '<div class="alert alert-success alert-dismissable"> \
                          <button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button> \
                          <strong>Success!</strong> Added. \
                          </div>'

    $.ajax({
    url: 'add-log',
    type: 'POST',
    data: { start_time: start_time, end_time: end_time, date: date, id: to_save},
    success: function( result ) {
            table.prepend(result);
            $("#notification").append(notification);
            $.ajax({
                  url: 'retime',
                  type: 'POST',
                  data: { id: to_save},
                  success: function( result ) {
                        which.find('.total-time').html(result);
                  }
            });
      }
    });
    }else{
      var notification = '<div class="alert alert-danger alert-dismissable"> \
                        <button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button> \
                        <strong>Wrong Time filled in!</strong> \
                        </div>'
      $("#notification").append(notification);
    }
});

function check(time) {
  var time_array = [];
  time_array = time.split(":");
  if ((parseInt(time_array[0]) > 23) || (parseInt(time_array[1]) > 59) || (parseInt(time_array[2]) > 59)){
    return false;
  }else{
    return true;
  }
}

$(document).on('click','.rename',function(e){
    var id = $(this).closest('tr').attr('id');
    var new_name = $(this).closest('td').find('.new-name').val();
    if(new_name == ''){
      new_name = "UNNAMED";
    }
    var to_rename = $(this).closest('td').find('.name').html(new_name);
    $.ajax({
      url: 'rename',
      type: 'PUT',
      data: { id: id, name: new_name},
    });
});

$(document).on('click','.delete',function(e){
    if (confirm('Are you sure you want to delete this item?')) {
      var to_delete = $(this).closest('tr').attr('id');
      $("#"+to_delete).slideUp();
      $.ajax({
        url: 'delete',
        type: 'DELETE',
        data: { id: to_delete },
      });
    }
});

$(document).on('click','.delete-log',function(e){
    if (confirm('Are you sure you want to delete this item?')) {
      var which = $(this).closest('tr').parents('tr');
      var task_id = which.attr('id');
      var to_delete = $(this).closest('tr').attr('id');
      $("#"+to_delete).slideUp();
      $.ajax({
        url: 'delete-log',
        type: 'DELETE',
        data: { id: to_delete , task_id: task_id},
        success: function( result ) {
              which.find('.total-time').html(result);
        }
      });
    }
});

$(document).on('click','.start-time',function(e){
    if ($(this).attr('value') == null){
    var date = new Date;
    var seconds = date.getSeconds();
    var minutes = date.getMinutes();
    var hour = date.getHours();
    $(this).attr("value",hour +":"+ minutes +":"+ seconds);
    }
});

$(document).on('click','.end-time',function(e){
    if ($(this).attr('value') == null){
    var date = new Date;
    var seconds = date.getSeconds();
    var minutes = date.getMinutes();
    var hour = date.getHours();
    $(this).attr("value",hour +":"+ minutes +":"+ seconds);
    }
});


var sign = 0;
var tTime = "";
var time = 1;
var idInterval = 0;

$(document).on('click','.start',function(e){
    var which = $(this).closest('tr');
    var to_log = which.attr('id');
    var to_clock = $(this).closest('td').prev().find('.time-position');
    var table = which.find("#table-log");

    if (sign == 0) {
      $('.start').attr('disabled',true);
      $(this).closest('tr').find('.start').attr('disabled',false);
      idInterval = setInterval(function(){
        if (time < 60){
          to_clock.html(time);
        }else {
          if (time % 60 > 9){
            to_clock.html("0" + Math.floor(time/60) + ":" + time % 60);
          } else {
            to_clock.html("0" + Math.floor(time/60) + ":0" + time % 60);
          }
        }
        time = time + 1;
      }, 1000);
    }else{
      $('.start').attr('disabled',false);
      clearInterval(idInterval);
    }
    $.ajax({
        url: 'log',
        type: 'POST',
        data: { id: to_log, clocktoggle: sign, stime: tTime, clocked: time-1},
        success: function( result ) {
            if(sign == 0){
              tTime = result;
            }
            if (sign == 0){
              sign = 1;
            }else{
              time = 0;
              sign = 0;
              table.prepend(result);
              $.ajax({
                  url: 'retime',
                  type: 'POST',
                  data: { id: to_log},
                  success: function( result ) {
                        which.find('.total-time').html(result);
                  }
              });
            }
        }
    });
});
