noosfero.webPush = {

  requestPersmission: function(callback) {
    // Using the callback signature to support older browsers
    Notification.requestPermission(function(permission) {
      if (permission == 'granted') {
        callback()
      } else {
        console.log('[WebPush Error] Notifications are disabled.')
      }
    })
  },

  subscribe: function() {
    return navigator.serviceWorker.ready.then(function(registration) {
      return registration.pushManager.subscribe({
        userVisibleOnly: true,
        applicationServerKey: noosfero.vapid.publicKey
      })
    })
  },

  saveSubscription: function(subscription) {
    var subscriptions = JSON.parse(localStorage.getItem('subscriptions')) || {}
    var user = noosfero.user_data.login
    var endpoint = subscription.endpoint

    if ((subscriptions[endpoint] == undefined) ||
        (subscriptions[endpoint].indexOf(user) < 0)) {
      noosfero.webPush.sendSubscription(subscription).done(function() {
        subscriptions[endpoint] = subscriptions[endpoint] || []
        subscriptions[endpoint].push(user)
        localStorage.setItem('subscriptions', JSON.stringify(subscriptions))
      })
    }
  },

  sendSubscription: function(subscription) {
    var subscriptionObj = subscription.toJSON()
    return $.ajax({
      type: 'POST',
      url: '/push_subscriptions/create',
      dataType: 'json',
      data: {
        subscription: subscriptionObj
      }
    })
  },

  setup: function() {
    if (window.Notification.requestPermission && navigator.serviceWorker) {
      noosfero.webPush.requestPersmission(function() {
        noosfero.webPush.subscribe()
        .then(noosfero.webPush.saveSubscription)
        .catch(function(err) {
          console.log('[WebPush Error]', err.message)
        })
      })
    } else {
      console.log('[WebPush Error] This browser is not supported.')
    }
  }
}
