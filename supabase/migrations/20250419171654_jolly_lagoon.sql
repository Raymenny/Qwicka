/*
  # Implement Worker Workflow

  1. New Tables
    - `work_requests` table to track incoming job requests
      - id (uuid, primary key)
      - worker_id (uuid, references profiles)
      - employer_id (uuid, references profiles)
      - skill_id (uuid, references skills)
      - status (text: pending, accepted, rejected)
      - created_at (timestamp)
      - description (text)
      - rate_offered (numeric)

  2. Changes
    - Add constraints to ensure workers can only have one active request
    - Add policies for request visibility and management

  3. Security
    - Enable RLS
    - Add policies for workers and employers
*/

-- Create work requests table
CREATE TABLE IF NOT EXISTS work_requests (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  worker_id uuid REFERENCES profiles(id) NOT NULL,
  employer_id uuid REFERENCES profiles(id) NOT NULL,
  skill_id uuid REFERENCES skills(id) NOT NULL,
  status text NOT NULL DEFAULT 'pending',
  created_at timestamptz DEFAULT now() NOT NULL,
  description text,
  rate_offered numeric NOT NULL,
  CONSTRAINT work_requests_status_check CHECK (status = ANY (ARRAY['pending'::text, 'accepted'::text, 'rejected'::text]))
);

-- Enable RLS
ALTER TABLE work_requests ENABLE ROW LEVEL SECURITY;

-- Add policies for work requests
CREATE POLICY "Workers can view their requests"
  ON work_requests FOR SELECT
  TO public
  USING (
    auth.uid() = worker_id AND 
    status = 'pending' AND
    NOT EXISTS (
      SELECT 1 FROM work_requests wr
      WHERE wr.worker_id = auth.uid()
      AND wr.status = 'accepted'
    )
  );

CREATE POLICY "Employers can create requests"
  ON work_requests FOR INSERT
  TO public
  WITH CHECK (
    auth.uid() = employer_id AND
    NOT EXISTS (
      SELECT 1 FROM work_requests wr
      WHERE wr.worker_id = work_requests.worker_id
      AND wr.status = 'accepted'
    )
  );

CREATE POLICY "Workers can update their requests"
  ON work_requests FOR UPDATE
  TO public
  USING (auth.uid() = worker_id)
  WITH CHECK (
    auth.uid() = worker_id AND
    status IN ('accepted', 'rejected')
  );

-- Add function to check if worker is available
CREATE OR REPLACE FUNCTION check_worker_availability(worker_id uuid)
RETURNS boolean AS $$
BEGIN
  RETURN NOT EXISTS (
    SELECT 1 FROM work_requests
    WHERE work_requests.worker_id = $1
    AND status = 'accepted'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;