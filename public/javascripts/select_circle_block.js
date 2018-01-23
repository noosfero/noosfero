$('#submit-button-set-circle-block').on('click', function(e){
  setTimeout(function(){
    if($('a.button.with-text.icon-ok').parents('#circles-container').css('display') == 'none'){
      // Follow post response was successful
      location.reload(); // Reloads page in order to re-run the embeded ruby on _circles.html
    }
  }, 1000);
});
