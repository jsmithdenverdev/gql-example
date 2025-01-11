-- Revert gql-example:appschema from pg

BEGIN;

-- First drop the trigger
DROP TRIGGER IF EXISTS todos_updated_at ON todos;

-- Then drop the trigger function
DROP FUNCTION IF EXISTS update_updated_at();

-- Drop the index
DROP INDEX IF EXISTS idx_todos_completion_due_date;

-- Finally drop the table
DROP TABLE IF EXISTS todos;

COMMIT;
