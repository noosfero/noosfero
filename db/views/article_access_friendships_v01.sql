SELECT articles.id, articles.profile_id, articles.access,
friendships.friend_id AS friend_id, friendships.person_id AS person_id
FROM articles JOIN profiles ON profiles.id = articles.profile_id
LEFT JOIN friendships
ON articles.profile_id = friendships.person_id OR articles.profile_id = friendships.friend_id
WHERE articles.access > 5;
