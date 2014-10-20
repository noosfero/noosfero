  var element = jQuery("input[name='article_email_notification']");
  var initialVal="example@example.com, example2@example.com.br";
  var isEdited=false;
  element.val(initialVal);

  element.focus(function(){
    if(!isEdited){
        element.val("");
        isEdited=true;
    }

  });

  element.blur(function(){
    if(element.val()==""){
        element.val(initialVal);
        isEdited=false;
    }

  });


