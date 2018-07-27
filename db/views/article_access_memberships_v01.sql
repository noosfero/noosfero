SELECT articles.id, articles.profile_id, articles.access,
role_assignments.accessor_id AS member_id, roles.permissions, roles.key
FROM articles LEFT JOIN role_assignments
ON articles.profile_id = role_assignments.resource_id
LEFT JOIN roles ON role_assignments.role_id = roles.id
WHERE articles.access > 5;
