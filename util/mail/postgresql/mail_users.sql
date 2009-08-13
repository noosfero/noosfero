CREATE OR REPLACE VIEW mail_users
AS
SELECT
  users.login || '@' || domains.name                      as username,
  case when users.password_type = 'crypt' then
    users.crypted_password
  else
    '{MD5}' || encode(decode(users.crypted_password,'hex'), 'base64')
  end
                                                          as passwd,
  ''                                                      as clearpasswd,
  5000                                                    as uid,
  5000                                                    as gid,
  '/home/vmail/' || domains.name                          as home,
  users.login                                             as maildir,
  NULL                                                    as quota,
  profiles.name                                           as fullname,
  ''                                                      as options,
  users.crypted_password                                  as pam_passwd
from users
JOIN profiles on
  (profiles.user_id = users.id and
   profiles.type = 'Person')
JOIN environments on
  (environments.id = profiles.environment_id)
JOIN domains on
  (
    (
      profiles.preferred_domain_id is null and
      domains.owner_id = environments.id and
      domains.owner_type = 'Environment'
    )
    OR
    (
      profiles.preferred_domain_id is not null and
      domains.owner_id = profiles.id and
      domains.owner_type = 'Profile'
    )
  )
WHERE
  users.enable_email;

CREATE OR REPLACE VIEW mail_aliases
AS
SELECT
  users.login || '@' || domains_from.name as source,
  users.login || '@' || domains_to.name as destination
from users
JOIN profiles on
  (profiles.user_id = users.id and
   profiles.type = 'Person')
JOIN environments on
  (environments.id = profiles.environment_id)
JOIN domains domains_from on
  (domains_from.owner_id = environments.id and
   domains_from.owner_type = 'Environment' and
   not domains_from.is_default)
JOIN domains domains_to on
  (domains_to.owner_id = environments.id and
   domains_to.owner_type = 'Environment' and
   domains_to.is_default)
WHERE
  users.enable_email;
