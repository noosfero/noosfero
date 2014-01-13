Noosfero release tasks
======================

This file documents release-related activities.

Working with translations
-------------------------

* Update translation files: `rake updatepo`. Then `git commit` them.
* Send the PO files to the translators.
* Get the PO files back from translators, put in `po/` under the correct language name (e.,g. `po/pt_BR/`) and `git commit`.
* test translations: `rake makemo` and browse the application on the web.

Releasing noosfero
------------------

Considering you are on a Debian GNU/Linux or Debian-based system

    # apt-get install devscripts debhelper

To prepare a release of noosfero, you must follow the steps below:

* Finish all requirements and bugs assigned to the to-be-released version
* Make sure all tests pass
* Write release notes at the version's wiki topic
* Generate packages with `rake noosfero:release[(stable|test)]`. This task will:
  * Update the version in lib/noosfero.rb and debian/changelog.
  * Create the tarbal and the deb pkg under pkg/ directory.
  * Create a git tag and push it.
  * Upload the pkg to the configured repository (if configured) on ~/.dput.cf.
* Test that the tarball and deb package are ok
* Go to the version's wiki topic and edit it to reflect the new reality
* Edit the topic WebPreferences and update DEBIAN_REPOSITORY_TOPICS setting
* Attach the generated packages to that topic. Before attaching calculate the sha1 of the package (with sha1sum and paste the SHA1 hash as comment in the attachment form)
* Download the attached and verify the MD5 hash
* Update an eventual demonstration version that you run.
* Write an announcement e-mail to the relevant mailing lists pointing to the release notes, and maybe to the demonstration version.

If you had any problem during these steps, you can do `rake clobber_package` to completely delete the generated packages and start the process again.
