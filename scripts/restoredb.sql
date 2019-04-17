--- This script copies `interim` DB to `postgres` DB and saves a backup of the latter 
--- 
\connect template1
-- kill all connections to `postgres` DB
SELECT pg_terminate_backend(pg_stat_activity.pid)
FROM pg_stat_activity
WHERE pg_stat_activity.datname = 'postgres' 
  AND pid <> pg_backend_pid();

DROP DATABASE IF EXISTS postgres_orig;
ALTER DATABASE postgres RENAME TO postgres_orig; 
ALTER DATABASE interim RENAME TO postgres;
