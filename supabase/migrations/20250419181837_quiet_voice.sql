/*
  # Disable security and simplify profile creation

  1. Changes
    - Disable RLS on all tables
    - Drop existing triggers and policies
    - Simplify profile validation
*/

-- Disable RLS on all tables
ALTER TABLE profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE worker_details DISABLE ROW LEVEL SECURITY;

-- Drop existing triggers and policies
DROP TRIGGER IF EXISTS ensure_worker_requirements ON profiles;
DROP FUNCTION IF EXISTS validate_worker_profile();

-- Drop all existing policies
DO $$ 
BEGIN
  DROP POLICY IF EXISTS "Profiles are viewable by everyone" ON profiles;
  DROP POLICY IF EXISTS "Users can manage their own profile" ON profiles;
  DROP POLICY IF EXISTS "Worker details are viewable by everyone" ON worker_details;
  DROP POLICY IF EXISTS "Workers can manage their own details" ON worker_details;
END $$;