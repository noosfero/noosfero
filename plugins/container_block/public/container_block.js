function enableMoveContainerChildren(container, box) {
  var div = jQuery('#box-'+box+' > .block-outer > .block');
  if(!div.is('.ui-resizable')) {
    div.removeClass('ui-draggable');
    div.resizable({
      handles: 'e, w',
      containment: '#block-'+container+' .block-inner-2',
      resize: function( event, ui ) {
        ui.element.height('auto');
      }
    });
  }
}

function disableMoveContainerChildren(container, box) {
  var div = jQuery('#box-'+box+' > .block-outer > .block');
  if(div.is('.ui-resizable')) {
    div.addClass('ui-draggable');
    div.resizable('destroy');
  }
}

function containerChildrenWidth(container, box) {
  widths = "";
  jQuery('#box-'+box+' > .block-outer > .block').each(function(i) {
    childId = jQuery(this).attr('id').match(/block-(\d+)/)[1];
    widths+=childId+","+jQuery(this).width()+"|";
  });
  return "widths="+widths;
}
