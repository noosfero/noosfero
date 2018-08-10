 SELECT profiles.id, profiles.access,
 friendships.friend_id AS friend_id, friendships.person_id AS person_id
 FROM profiles LEFT JOIN friendships
 ON profiles.id = friendships.person_id OR profiles.id = friendships.friend_id
 WHERE profiles.access > 5;
