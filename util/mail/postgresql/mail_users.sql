CREATE OR REPLACE VIEW mail_users
AS
SELECT
  users.login || '@' || domains.name                      as username,
  '{MD5}' || encode(decode(users.crypted_password,'hex'), 'base64')
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
  (domains.owner_id = environments.id and
   domains.owner_type = 'Environment')
WHERE
  users.password_type = 'md5'
  AND users.enable_email;

