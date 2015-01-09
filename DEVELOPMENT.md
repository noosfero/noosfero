# Noosfero Development Policy

## Developer Roles

* *Developers* are everyone that is contributing code to Noosfero.
* *Committers* are the people with direct commit access to the Noosfero source
  code. They are responsible for reviewing contributions from other developers
  and integrating them in the Noosfero code base. They are the members of the
  [Noosfero group on Gitlab](https://gitlab.com/groups/noosfero/members).
* *Release managers* are the people that are managing the release of a new
  Noosfero version and/or the maintainance work of an existing Noosfero stable
  branch. See MAINTAINANCE.md for details on the maintaince policy.

## Development process

* Every new feature or non-trivial bugfix should be reviewed by at least one
  committer. This must be the case even if the original author is a committer.

  * In the case the original author is a committer, he/she should feel free to
    commit directly if after 1 week nobody has provided any kind of feedback.

  * Developers who are not committers should feel free to ping committers if
    they do not get feedback on their contributions after 1 week.

    * On GitLab, one can just add a comment to the merge request; one can also
      @-mention specific committers or other developers who have expertise on
      the area of the contribution.

  * Committers should follow the activity of the project, and try to help
    reviewing contributions from others as much as possible.

    * On GitLab one can get emails for all activity on a project by setting the
      [notification settings](https://gitlab.com/profile/notifications) to
      "watch".

  * Anyone can help by reviewing contributions. Committers are the only ones
    who can give the final approval to a contribution, but everyone is welcome
    to help with code review, testing, etc.

    * See note above about setting up notification on GitLab.

* Committers should feel free to push trivial (or urgent) changes directly.
  There are no strict rule on what makes a change trivial or urgent; committers
  are expected to exercise good judgement on a case by case basis.

  * Usually changes to the database are not trivial.

* In the case of unsolvable conflict between commiters regarding any change to
  the code, the current release manager(s) will have the final say in the
  matter.

* Release managers are responsible for stablishing a release schedule, and
  about deciding when and what to release.

  * Release managers should announce release schedules to the project mailing
    lists in advance.

  * The release schedule may include a period of feature freeze, during which
    no new features or any other changes that are not pre-approved by the
    release manager must be committed to the repository.

  * Committers must respect the release schedule and feature freezes.

## Maintainance process

### Not all feature releases will be maintained as a stable release

We will be choosing specific release series to be maintained as stable
releases.

This means that a given release is not guaranteed to be maintained as a stable
release, but does *not* mean it won't be. Any committer (or anyone, really) can
decide to maintain a given release as stable and seek help from others to do
so.

### No merges from stable branches to master

*All* changes must be submitted against the master branch first, and when
applicable, backported to the desired stable releases. Exceptions to this rules
are bug fixes that only apply to a given stable branch and not to master.

In the past we had non-trivial changes accepted into stable releases while
master was way ahead (e.g. during the rails3 migration period), that made the
merge back into master very painful.  By eliminating the need to do these
merges, we save time for the people responsible for the release, and eliminate
the possibility of human errors or oversights causing changes to be accepted
into stable that will be a problem to merge back into master.

By getting all fixes in master first, we improve the chances that  a future
release will not present regressions against bugs that should already be fixed,
but the fixes got lost in a big, complicated merge (and those won't exist
anymore, at least not from stable branches to master).

After a fix gets into master, backporting changes into a stable release branch
is the responsibility of whoever is maintaing that branch, and those interested
in it. The stable branch release manager(s) are entitled the final say on any
matters related to that branch.

## Apendix A: how to become a committer

Every developer that wants to be a committer should create [an issue on
Gitlab](https://gitlab.com/noosfero/noosfero/issues) requesting to be added as
a committer. This request must include information about the requestor's
previous contributions to the project.

If 2 or more commiters consider second the request, the requestor is accepted
as new commiter and added to the Noosfero group.

The existing committers are free to choose whatever criteria they want to
second the request, but they must be sure that the new committer is a
responsible developer and knows what she/he is doing. They must be aware that
seconding these requests means seconding the actions of the new committer: if
the new committer screw up, her/his seconds screwed up.

## Apendix B: how to become a release manager

A new release manager for the development version of Noosfero (i.e. the one
that includes new features, a.k.a. the master branch) is apointed by the
current release manager, and must be a committer first.

Release managers for stable branches are self-appointed, i.e. whoever takes the
work takes the role. In case of a conflict (e.g. 2+ different people want to do
the work but can't agree on working together), the development release manager
decides.
