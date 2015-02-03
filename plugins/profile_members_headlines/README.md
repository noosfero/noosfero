README - Profile Members Headlines (ProfileMembersHeadlines Plugin)
===================================================================

ProfileMembersHeadlines is a plugin that allow users to add a block that
displays the most recent post from members with the defined roles.

The user also can configure the limit of headlines.

This block will be available for all layout columns of communities and enterprises.

INSTALL
=======

Enable Plugin
-------------

Also, you need to enable ProfileMembersHeadlines Plugin at you Noosfero:

cd <your_noosfero_dir>
./script/noosfero-plugins enable profile_members_headlines

Active Plugin
-------------

As a Noosfero administrator user, go to administrator panel:

- Click on "Enable/disable plugins" option
- Click on "Profile Members Headlines Plugin" checkbox

Running DisplayContent tests
--------------------

$ rake test:noosfero_plugins:profile_members_headlines_plugin

LICENSE
=======

See Noosfero license.
