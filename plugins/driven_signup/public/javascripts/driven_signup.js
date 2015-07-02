driven_signup = {

  admin: {
    append: function(auth) {
      return $('#auth-new').before(auth)
    },

    find: function(token) {
      return $('#driven-signup-tokens [data-token='+token+']')
    },

    update: function(token, auth){
      return this.find(token).replaceWith(auth)
    },

    remove: function(token) {
      return this.find(token).remove()
    },
  },

}

