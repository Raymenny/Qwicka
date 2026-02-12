/*
  # Create profiles and worker details tables

  1. New Tables
    - `profiles`
      - `id` (uuid, primary key)
      - `full_name` (text, required)
      - `avatar_url` (text, required for workers)
      - `phone` (text, required)
      - `role` (text, either 'worker' or 'employer')
      - `created_at` (timestamp)
      - `updated_at` (timestamp)
    
    - `worker_details`
      - `worker_id` (uuid, references profiles)
      - `online` (boolean)
      - `max_distance_km` (integer)
      - `currently_working` (boolean)
      - `current_contract_id` (uuid, nullable)

  2. Security
    - Enable RLS on both tables
    - Add policies for profile and worker details access
*/

-- Create profiles table
CREATE TABLE IF NOT EXISTS profiles (
  id uuid PRIMARY KEY,
  full_name text NOT NULL,
  avatar_url text,
  phone text NOT NULL,
  role text NOT NULL,
  created_at timestamptz DEFAULT now() NOT NULL,
  updated_at timestamptz DEFAULT now() NOT NULL,
  CONSTRAINT profiles_role_check CHECK (role = ANY (ARRAY['worker'::text, 'employer'::text]))
);

-- Create worker_details table
CREATE TABLE IF NOT EXISTS worker_details (
  worker_id uuid PRIMARY KEY REFERENCES profiles(id),
  online boolean DEFAULT false,
  max_distance_km integer DEFAULT 20,
  currently_working boolean DEFAULT false,
  current_contract_id uuid
);

-- Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE worker_details ENABLE ROW LEVEL SECURITY;

-- Drop existing trigger and function if they exist
DROP TRIGGER IF EXISTS ensure_worker_requirements ON profiles;
DROP FUNCTION IF EXISTS validate_worker_profile();

-- Add trigger for worker profile validation
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

-- Add RLS policies
DO $$ 
BEGIN
  DROP POLICY IF EXISTS "Profiles are viewable by everyone" ON profiles;
  DROP POLICY IF EXISTS "Users can manage their own profile" ON profiles;
  DROP POLICY IF EXISTS "Worker details are viewable by everyone" ON worker_details;
  DROP POLICY IF EXISTS "Workers can manage their own details" ON worker_details;
END $$;

CREATE POLICY "Profiles are viewable by everyone"
  ON profiles FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Users can manage their own profile"
  ON profiles FOR ALL
  TO public
  USING (id = auth.uid())
  WITH CHECK (id = auth.uid());

CREATE POLICY "Worker details are viewable by everyone"
  ON worker_details FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Workers can manage their own details"
  ON worker_details FOR ALL
  TO public
  USING (worker_id = auth.uid())
  WITH CHECK (worker_id = auth.uid());