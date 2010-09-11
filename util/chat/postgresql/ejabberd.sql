--
-- noosfero, Copyright (C) 2010        Colivre
-- ejabberd, Copyright (C) 2002-2008   Process-one
--
-- This program is free software; you can redistribute it and/or
-- modify it under the terms of the GNU General Public License as
-- published by the Free Software Foundation; either version 2 of the
-- License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
-- General Public License for more details.
--                         
-- You should have received a copy of the GNU General Public License
-- along with this program; if not, write to the Free Software
-- Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
-- 02111-1307 USA
--

-- This is a modified version of ejabberd's PostgreSQL schema for Noosfero. It
-- is like the original, except that the users and rosterusers tables are
-- actually views that access data from the Noosfero database.

DROP SCHEMA ejabberd CASCADE;
CREATE SCHEMA ejabberd;
SET SEARCH_PATH TO ejabberd;

CREATE VIEW users AS
  SELECT
    u.login AS username,
    u.crypted_password AS password
  FROM
    public.users u
    JOIN public.environments e on (e.id = u.environment_id)
  WHERE
    e.is_default;

CREATE TABLE last (
    username text PRIMARY KEY,
    seconds text NOT NULL,
    state text NOT NULL
);

CREATE VIEW rosterusers AS
  select
    p1.identifier AS username,               -- text NOT NULL,         
    p2.identifier || '@' || d.name AS jid,   -- text NOT NULL,         
    coalesce(p2.nickname, p2.name) AS nick,  -- text NOT NULL,         
    'B' AS subscription,                     -- character(1) NOT NULL, 
    'N' AS ask,                              -- character(1) NOT NULL, 
    '' AS askmessage,                        -- text NOT NULL,         
    'N' AS server,                           -- character(1) NOT NULL, 
    '' AS subscribe,                         -- text,                  
    'item' AS type                           -- text                   
  FROM
    public.profiles p1
    JOIN public.friendships f ON (f.person_id = p1.id)
    JOIN public.profiles p2 ON (f.friend_id = p2.id) 
    JOIN public.environments source_env ON (source_env.id = p1.environment_id)
    JOIN public.environments env ON (env.id = p2.environment_id)
    JOIN public.domains d ON (d.owner_id = env.id AND d.owner_type = 'Environment' and d.is_default)
  WHERE
    p1.type = 'Person'
    AND source_env.is_default;

CREATE TABLE rostergroups (
    username text NOT NULL,
    jid text NOT NULL,
    grp text NOT NULL
);

CREATE INDEX pk_rosterg_user_jid ON rostergroups USING btree (username, jid);


CREATE TABLE spool (
    username text NOT NULL,
    xml text NOT NULL,
    seq SERIAL
);

CREATE INDEX i_despool ON spool USING btree (username);


CREATE TABLE vcard (
    username text PRIMARY KEY,
    vcard text NOT NULL
);

CREATE TABLE vcard_search (
    username text NOT NULL,
    lusername text PRIMARY KEY,
    fn text NOT NULL,
    lfn text NOT NULL,
    family text NOT NULL,
    lfamily text NOT NULL,
    given text NOT NULL,
    lgiven text NOT NULL,
    middle text NOT NULL,
    lmiddle text NOT NULL,
    nickname text NOT NULL,
    lnickname text NOT NULL,
    bday text NOT NULL,
    lbday text NOT NULL,
    ctry text NOT NULL,
    lctry text NOT NULL,
    locality text NOT NULL,
    llocality text NOT NULL,
    email text NOT NULL,
    lemail text NOT NULL,
    orgname text NOT NULL,
    lorgname text NOT NULL,
    orgunit text NOT NULL,
    lorgunit text NOT NULL
);

CREATE INDEX i_vcard_search_lfn       ON vcard_search(lfn);
CREATE INDEX i_vcard_search_lfamily   ON vcard_search(lfamily);
CREATE INDEX i_vcard_search_lgiven    ON vcard_search(lgiven);
CREATE INDEX i_vcard_search_lmiddle   ON vcard_search(lmiddle);
CREATE INDEX i_vcard_search_lnickname ON vcard_search(lnickname);
CREATE INDEX i_vcard_search_lbday     ON vcard_search(lbday);
CREATE INDEX i_vcard_search_lctry     ON vcard_search(lctry);
CREATE INDEX i_vcard_search_llocality ON vcard_search(llocality);
CREATE INDEX i_vcard_search_lemail    ON vcard_search(lemail);
CREATE INDEX i_vcard_search_lorgname  ON vcard_search(lorgname);
CREATE INDEX i_vcard_search_lorgunit  ON vcard_search(lorgunit);

CREATE TABLE privacy_default_list (
    username text PRIMARY KEY,
    name text NOT NULL
);

CREATE TABLE privacy_list (
    username text NOT NULL,
    name text NOT NULL,
    id SERIAL UNIQUE
);

CREATE INDEX i_privacy_list_username ON privacy_list USING btree (username);
CREATE UNIQUE INDEX i_privacy_list_username_name ON privacy_list USING btree (username, name);

CREATE TABLE privacy_list_data (
    id bigint REFERENCES privacy_list(id) ON DELETE CASCADE,
    t character(1) NOT NULL,
    value text NOT NULL,
    action character(1) NOT NULL,
    ord NUMERIC NOT NULL,
    match_all boolean NOT NULL,
    match_iq boolean NOT NULL,
    match_message boolean NOT NULL,
    match_presence_in boolean NOT NULL,
    match_presence_out boolean NOT NULL
);

CREATE TABLE private_storage (
    username text NOT NULL,
    namespace text NOT NULL,
    data text NOT NULL
);

CREATE INDEX i_private_storage_username ON private_storage USING btree (username);
CREATE UNIQUE INDEX i_private_storage_username_namespace ON private_storage USING btree (username, namespace);


--- To update from 0.9.8:
-- CREATE SEQUENCE spool_seq_seq;
-- ALTER TABLE spool ADD COLUMN seq integer;
-- ALTER TABLE spool ALTER COLUMN seq SET DEFAULT nextval('spool_seq_seq');
-- UPDATE spool SET seq = DEFAULT;
-- ALTER TABLE spool ALTER COLUMN seq SET NOT NULL;

--- To update from 1.x:
-- ALTER TABLE rosterusers ADD COLUMN askmessage text;
-- UPDATE rosterusers SET askmessage = '';
-- ALTER TABLE rosterusers ALTER COLUMN askmessage SET NOT NULL;

