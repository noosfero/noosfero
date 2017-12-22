if (navigator.serviceWorker) {
  navigator.serviceWorker.register('/serviceworker.js', { scope: '/' })
    .then(function(reg) {
      console.log('Service worker was successfully registered.');
    });
} else {
	console.log('Service workers are not supported in this browser.')
}
