Noosfero release tasks
======================

This file documents release-related activities.

Releasing noosfero
------------------

Considering you are on a Debian GNU/Linux or Debian-based system, the following
packages are required during the release process:

```
# apt install git devscripts debhelper
```

To prepare a release of noosfero, you must follow the steps below:

* Disable the automatic pushing of translation updates in weblate.
* Make sure all tests pass
* Generate packages with `rake noosfero:release[(stable|test)]`. This task will:
  * Update the version in lib/noosfero.rb and debian/changelog.
  * Create the tarbal and the deb pkg under pkg/ directory.
  * Create a git tag and push it.
  * Upload the packages to the configured repository (if configured) on ~/.dput.cf.
* Test that the tarball and deb package are ok
* Update an eventual demonstration version that you run.
* Write an announcement e-mail to the relevant mailing lists pointing to the
  release notes, and maybe to the demonstration version.
* Re-enable the automatic pushing of trasnlatio updates in weblate.

If you had any problem during these steps, you can do `rake clobber_package` to
completely delete the generated packages and start the process again.
