SELECT CAST(id AS char(10))
	, name
	, address
	, office_manager_id::char(10)
	, num_desks::char
	, CAST(state AS char(10))
FROM departments