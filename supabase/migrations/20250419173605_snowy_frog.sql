/*
  # Update profiles table RLS policies

  1. Changes
    - Drop existing RLS policies on profiles table that are too restrictive
    - Add new RLS policies that allow:
      - New users to create their own profile during signup
      - Users to read any profile
      - Users to update their own profile
      - Users to delete their own profile

  2. Security
    - Maintains row-level security while allowing necessary operations
    - Ensures users can only modify their own data
    - Allows public read access to profiles
*/

-- Drop existing policies
DROP POLICY IF EXISTS "Allow profile creation during signup" ON profiles;
DROP POLICY IF EXISTS "Profiles are viewable by everyone" ON profiles;
DROP POLICY IF EXISTS "Users can create their own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update their own profile" ON profiles;

-- Create new policies
CREATE POLICY "Profiles are viewable by everyone"
ON profiles FOR SELECT
TO public
USING (true);

CREATE POLICY "Users can insert their own profile"
ON profiles FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update own profile"
ON profiles FOR UPDATE
TO authenticated
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can delete own profile"
ON profiles FOR DELETE
TO authenticated
USING (auth.uid() = id);