README - Oauth Provider Plugin
================================

OauthProvider is a plugin which allow noosfero to be used as an oauth provider 

Install
=======

Enable Plugin
-------------

cd <your_noosfero_dir>
./script/noosfero-plugins enable oauth_provider

Active Plugin
-------------

As a Noosfero administrator user, go to administrator panel:

- Click on "Enable/disable plugins" option
- Click on "Oauth Provider Plugin" check-box

Varnish Settings
================
If varnish has been used in your stack, you've to prevent cookies to be removed when calling authorization actions for  oauth_provider. E.g.:

```
if (req.url !~ "^/plugin/oauth_provider/*" && req.http.cookie !~ "_noosfero_.*") {
  unset req.http.cookie;
  return(lookup);
}
```

Development
===========

Running OauthProvider tests
--------------------

$ rake test:noosfero_plugins:oauth_provider

License
=======

Copyright (c) The Author developers.

See Noosfero license.
