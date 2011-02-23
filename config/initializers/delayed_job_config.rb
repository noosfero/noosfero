Delayed::Worker.backend = :active_record
Delayed::Worker.max_attempts = 2
Delayed::Worker.max_run_time = 10.minutes
