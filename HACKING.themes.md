Noosfero Instructions for Theme Developers
==========================================

To build Noosfero themes you must to know HTML and CSS. You may also get some advantages with Ruby and Noosfero hacking knowledge because all customizable pieces of the theme's HTML structure are [erb](http://en.wikipedia.org/wiki/ERuby) files.


Organization Basics
-------------------

A theme is a directory and must inside `noosfero/public/designs/themes`, and you will find tis themes in a fresh installation:
`noosfero`, `aluminium`, `base`, `butter`, `chameleon`, `chocolate`, `orange`, `plum`, `scarletred` and `skyblue`. The `default` is only a link to `noosfero` and you can change this link to any other.

`noosfero` is the default theme with a big header. All other are colored themes with a thin header. That colored ones can be used as additional themes for any environment, as they will search for `/images/thin-logo.png` inside the current environment.theme, to use as top left logo.

Inside a theme we can found:
* `theme.yml` — Theme description with some nice configuration options.
* `preview.png` — A 100x100 screenshot of this theme to the theme selection UI.
* `style.css` — The main file. The magic happens here.
* `errors.css` — Change the error page look. (only if this theme is linked by `defaut`)
* `favicon.ico` — The identifier icon for your web site.
* `images` — Another name can be found by your CSS, but will not allow to reuse the logo.
  * `thin-logo.png` — The logo to be reused by the colored themes.
  * *many images...*
* `site_title.html.erb` — A nice place to put your logo, any code here will be placed inside `h1#site-title`.
* `header.html.erb` — That goes inside `div#theme-header`.
* `navigation.html.erb` — That goes inside `div#navigation ul`, so use `<li>`s.
* `footer.html.erb` — That goes inside `div#theme-footer`.

You can add more files like javascript and modularized CSS, but you must to refer that by the described files above.

To refer one of this files trough the web the path is `<domain>/designs/themes/<thistheme>/<somefile>`.


theme.yml
---------

A simple definition file. See this example:
```yml
name: "My Cool Theme"
layout: "application-ng"
jquery_theme: "smoothness"
icon_theme: [default, pidgin]
gravatar: "retro"
```

About non obvious:
* `layout` is about the theme structure to use. The `application-ng` is enough for 99.97358% use cases. If you want to use another structure, you must add a new `*.html.erb` file at `app/views/layouts/`.
* `icon_theme` point to something inside `public/designs/icons/`.
* `gravatar` set the default gravatar *(avatar picture)* for people without picture.


Theme Intervention from Environment Theme
-----------------------------------------

Sometimes an environment (as instace http://cirandas.net) wants to allow profiles to set its own theme, but with some environment identification or functions, like a top bar with the social network logo and a top menu (as instace http://cirandas.net/rango-vegan).
To make the magic happens you can add some files to the environment theme.
All are optional:
* `global.css` — this must be used to style all extra html added by your intervention partials. As it is a free form css file you can style anything, but this is a conflict risk.
* `global_header.html.erb` — Will add content to `#global-header`.
* `global_footer.html.erb` — Will add content to `#global-footer`.
