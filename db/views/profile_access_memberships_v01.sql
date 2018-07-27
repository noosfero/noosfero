SELECT profiles.id, profiles.access,
role_assignments.accessor_id AS member_id, roles.permissions, roles.key
FROM profiles LEFT JOIN role_assignments
ON profiles.id = role_assignments.resource_id
LEFT JOIN roles ON role_assignments.role_id = roles.id
WHERE profiles.access > 5;
