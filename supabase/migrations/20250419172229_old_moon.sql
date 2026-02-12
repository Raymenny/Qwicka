/*
  # Update Profile Requirements and Security

  1. Changes
    - Add NOT NULL constraints for required fields
    - Update profile policies to restrict editing
    - Add validation triggers for worker profiles

  2. Security
    - Only profile owners can edit their profiles
    - Enforce required fields based on role
*/

-- Add NOT NULL constraints for required fields
ALTER TABLE profiles
  ALTER COLUMN full_name SET NOT NULL,
  ALTER COLUMN phone SET NOT NULL;

-- Add trigger to validate worker profile requirements
CREATE OR REPLACE FUNCTION validate_worker_profile()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.role = 'worker' THEN
    IF NEW.avatar_url IS NULL THEN
      RAISE EXCEPTION 'Worker profiles must include a picture';
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ensure_worker_requirements
  BEFORE INSERT OR UPDATE ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION validate_worker_profile();

-- Update RLS policies
DROP POLICY IF EXISTS "Public profiles are viewable by everyone." ON profiles;
DROP POLICY IF EXISTS "Users can insert their own profile." ON profiles;
DROP POLICY IF EXISTS "Users can update own profile." ON profiles;

-- Add new policies
CREATE POLICY "Profiles are viewable by everyone"
  ON profiles FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Users can create their own profile"
  ON profiles FOR INSERT
  TO public
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
  ON profiles FOR UPDATE
  TO public
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Update worker_details policies
DROP POLICY IF EXISTS "Workers can manage their own details." ON worker_details;

CREATE POLICY "Workers can view any worker details"
  ON worker_details FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Workers can manage their own details"
  ON worker_details FOR ALL
  TO public
  USING (auth.uid() = worker_id)
  WITH CHECK (auth.uid() = worker_id);