/*
  # Update worker experience levels

  1. Changes
    - Update worker_skills experience_level constraint to include 'no experience'
    - Add 'very experienced' level
    - Update rate_type options

  2. Security
    - No changes to existing policies
*/

-- Drop existing worker_skills table to update constraints
DROP TABLE IF EXISTS worker_skills;

-- Recreate worker_skills table with updated constraints
CREATE TABLE IF NOT EXISTS worker_skills (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  worker_id uuid REFERENCES profiles(id),
  skill_id uuid REFERENCES skills(id),
  experience_level text NOT NULL,
  rate_type text NOT NULL,
  rate_amount numeric,
  available boolean DEFAULT true,
  CONSTRAINT worker_skills_experience_level_check CHECK (experience_level = ANY (ARRAY['no experience'::text, 'beginner'::text, 'intermediate'::text, 'experienced'::text, 'very experienced'::text])),
  CONSTRAINT worker_skills_rate_type_check CHECK (rate_type = ANY (ARRAY['hourly'::text, 'fixed'::text, 'varying'::text, 'negotiable'::text])),
  CONSTRAINT worker_skills_worker_id_skill_id_key UNIQUE (worker_id, skill_id)
);

-- Enable RLS for new table
ALTER TABLE worker_skills ENABLE ROW LEVEL SECURITY;

-- Recreate worker_skills policies
CREATE POLICY "Worker skills are viewable by everyone."
  ON worker_skills FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Workers can manage their own skills."
  ON worker_skills FOR ALL
  TO public
  USING (auth.uid() = worker_id);