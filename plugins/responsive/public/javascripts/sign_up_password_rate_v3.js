// This jQuery plugin is written by firas kassem [2007.04.05] and was modified to fit noosfero
// Firas Kassem  phiras.wordpress.com || phiras at gmail {dot} com
// for more information : http://phiras.wordpress.com/2007/04/08/password-strength-meter-a-jquery-plugin/

var blankPass    = -1;
var shortPass   = 0;
var badPass     = 1;
var goodPass    = 2;
var strongPass  = 3;


function passwordStrength(password,username)
{
  score = 0;

  if(password.length == 0) { return blankPass }

  //password < 4
  if (password.length < 4 ) { return shortPass }

  //password == username
  if (password.toLowerCase()==username.toLowerCase()) { return badPass }

  //password length
  score += password.length * 4;
  score += ( checkRepetition(1,password).length - password.length ) * 1;
  score += ( checkRepetition(2,password).length - password.length ) * 1;
  score += ( checkRepetition(3,password).length - password.length ) * 1;
  score += ( checkRepetition(4,password).length - password.length ) * 1;

  //password has 3 numbers
  if (password.match(/(.*[0-9].*[0-9].*[0-9])/))  score += 5;

  //password has 2 sybols
  if (password.match(/(.*[!,@,#,$,%,^,&,*,?,_,~].*[!,@,#,$,%,^,&,*,?,_,~])/)) score += 5;

  //password has Upper and Lower chars
  if (password.match(/([a-z].*[A-Z])|([A-Z].*[a-z])/))  score += 10;

  //password has number and chars
  if (password.match(/([a-zA-Z])/) && password.match(/([0-9])/))  score += 15;
  //
  //password has number and symbol
  if (password.match(/([!,@,#,$,%,^,&,*,?,_,~])/) && password.match(/([0-9])/))  score += 15;

  //password has char and symbol
  if (password.match(/([!,@,#,$,%,^,&,*,?,_,~])/) && password.match(/([a-zA-Z])/))  score += 15;

  //password is just a nubers or chars
  if (password.match(/^\w+$/) || password.match(/^\d+$/) )  score -= 10;

  //verifing 0 < score < 100
  if ( score < 0 )  score = 0;
  if ( score > 100 )  score = 100;

  if (score < 34 )  return badPass;
  if (score < 68 )  return goodPass;
  return strongPass
}

function checkRepetition(pLen,str)
{
  res = "";
  for ( i=0; i<str.length ; i++ )
  {
      repeated=true
      for (j=0;j < pLen && (j+i+pLen) < str.length;j++)
          repeated=repeated && (str.charAt(j+i)==str.charAt(j+i+pLen))
      if (j<pLen) repeated=false;
      if (repeated)
      {
          i+=pLen-1;
          repeated=false
      }
      else
      {
          res+=str.charAt(i)
      }
  }
  return res
}

function setupPasswordField() {
    jQuery('#user_pw_v3').keyup(function()
    {
        var result = passwordStrength(jQuery('#user_pw_v3').val(),jQuery('#user_login_v3').val());

        var help_message = jQuery('#user_pw_help_message');
        var pw_alert = jQuery('#user_pw_alert');
        var pw_group = jQuery('#user_pw_group');

        if(result == blankPass)
        {
            pw_alert.removeClass('fa fa-warning').removeClass('fa fa-check').removeClass('fa fa-thumbs-down');
            help_message.html('');
            pw_group.removeClass('has-warning').removeClass('has-error').removeClass('has-success').addClass('has-error');


        } else
        if(result == shortPass)
        {
            pw_alert.removeClass('fa fa-warning').removeClass('fa fa-check').removeClass('fa fa-thumbs-down').addClass('fa fa-warning');
            help_message.html(window.password_states.short);
            pw_group.removeClass('has-warning').removeClass('has-error').removeClass('has-success').addClass('has-error');

        } else
        if( result == badPass )
        {
            pw_alert.removeClass('fa fa-warning').removeClass('fa fa-check').removeClass('fa fa-thumbs-down').addClass('fa fa-thumbs-down');
            help_message.html(window.password_states.bad);
            pw_group.removeClass('has-warning').removeClass('has-error').removeClass('has-success').addClass('has-warning');

        } else
        if( result == goodPass )
        {
            pw_alert.removeClass('fa fa-warning').removeClass('fa fa-check').removeClass('fa fa-thumbs-down').addClass('fa fa-check');
            help_message.html(window.password_states.good);
            pw_group.removeClass('has-warning').removeClass('has-error').removeClass('has-success').addClass('has-success');

        } else
        if( result == strongPass )
        {
            pw_alert.removeClass('fa fa-warning').removeClass('fa fa-check').removeClass('fa fa-thumbs-down').addClass('fa fa-check');
            help_message.html(window.password_states.strong);
            pw_group.removeClass('has-warning').removeClass('has-error').removeClass('has-success').addClass('has-success');

        }

    });
}

function setupPasswordConfirmation() {
    jQuery('#user_pw_confirm').blur(function(evt) {
        var password = jQuery('#user_pw_v3').val();
        var confirmed_password = jQuery('#user_pw_confirm').val();

        var help_message = jQuery('#user_pw_confirm_help_message');
        var pw_alert = jQuery('#user_pw_confirm_alert');
        var pw_group = jQuery('#user_pw_confirm_group');

        if (password != confirmed_password) {
            pw_alert.removeClass('fa fa-warning').removeClass('fa fa-check').addClass('fa fa-warning');
            pw_group.removeClass('has-error').removeClass('has-success').addClass('has-error');
            help_message.html(window.password_confirm_msg.error)
        } else {
            pw_alert.removeClass('fa fa-warning').removeClass('fa fa-check').addClass('fa fa-check');
            pw_group.removeClass('has-error').removeClass('has-success').addClass('has-success');
            help_message.html('');
        }
    });

}

jQuery(document).ready(function() {
    setupPasswordField();
    setupPasswordConfirmation();

});