# Rails 5 behaviour generates a custom token for a form in order to prevent code-injection, 
# by using this in an initializer it'll generate a CSRF token to every controller, if this
# isn't needed just add: "self.per_form_csrf_tokens = true" to the desired controller.

# Rails.configuration.action_controller.per_form_csrf_tokens = true