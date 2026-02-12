/*
  # Fix work requests RLS policy

  1. Changes
    - Remove recursive condition from work requests RLS policy
    - Simplify the policy to avoid self-referential queries
    - Keep core business logic intact (workers can only view pending requests)
  
  2. Security
    - Maintain RLS enabled on work_requests table
    - Update policies to prevent infinite recursion while maintaining security
*/

-- Drop existing policies
DROP POLICY IF EXISTS "Workers can view their requests" ON work_requests;

-- Create new simplified policy without recursive conditions
CREATE POLICY "Workers can view their requests"
ON work_requests
FOR SELECT
TO public
USING (
  (auth.uid() = worker_id) AND 
  (status = 'pending'::text)
);