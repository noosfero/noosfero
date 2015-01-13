README - Oauth Client Plugin
================================

OauthClient is a plugin which allow users to login/signup to noosfero with some oauth providers (for now, google, facebook and noosfero itself).

Install
=======

Enable Plugin
-------------

cd <your_noosfero_dir>
./script/noosfero-plugins enable oauth_client

Active Plugin
-------------

As a Noosfero administrator user, go to administrator panel:

- Click on "Enable/disable plugins" option
- Click on "Oauth Client Plugin" check-box

Provider Settings
=================

Goggle
------

[Create Google+ application](https://developers.google.com/+/web/signin/javascript-flow)

Facebook
--------

[Create Facebook application](https://developers.facebook.com/docs/facebook-login/v2.1)

Varnish Settings
================
If varnish has been used in your stack, you've to bypass the cache for signup page and prevent cookies to be removed when calling the oauth_client plugin callback. E.g.:

```
if (req.url !~ "^/account/*" && req.url !~ "^/plugin/oauth_provider/*" && req.url !~ "^/plugin/oauth_client/*" && req.http.cookie !~ "_noosfero_.*") {
  unset req.http.cookie;
  return(lookup);
}
```

Using Oauth Provider Plugin
===========================
The oauth_provider plugin may be used as a provider in the same noosfero installation that hosts your oauth_client plugin (this is usefull in a multi environment setup).

However, you've to use a distinct set of thin processes to handle the authorization requests (to avoid deadlock).

Apache settings example:
```
RewriteRule ^/oauth_provider/oauth/(authorize|token).*$ balancer://noosfero-oauth-provider%{REQUEST_URI} [P,QSA,L]
```


Development
===========

Running OauthClient tests
--------------------

$ rake test:noosfero_plugins:oauth_client

License
=======

Copyright (c) The Author developers.

See Noosfero license.
