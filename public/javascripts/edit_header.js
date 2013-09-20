jQuery('#document').ready(function() {
  jQuery('#header').editable({
    type: 'textarea',
    pk: 1,
    url: '/post',
    title: 'Edit header'
  });
});
