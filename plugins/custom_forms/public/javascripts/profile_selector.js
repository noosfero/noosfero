function ProfileSelector(wrapperClass) {
  this.selector = $(wrapperClass)
  this.profiles = this.selector.find('.profile-selector-entry')

  this.filterProfiles = function(query) {
    var regex = new RegExp(query, 'i')
    this.profiles.each(function(index) {
      var profileName = $(this).find('.profile-name').text()
      if (profileName.match(regex)) {
        $(this).show()
      } else {
        $(this).hide()
      }
    })
  }

  var self = this;

  this.selector.on('keyup', '#profile-selector-search', function() {
    self.filterProfiles($(this).val())
  })

  this.selector.on('click', '.profile-selector-actions .select-all', function() {
    self.profiles.find('input[type=checkbox]').prop('checked', true)
  }).on('click', '.profile-selector-actions .deselect-all', function() {
    self.profiles.find('input[type=checkbox]').prop('checked', false)
  })
}

$(document).ready(function() {
  new ProfileSelector('form.profile-selector')
})
