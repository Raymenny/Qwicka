/*
  # Disable RLS on profiles table

  1. Changes
    - Disable Row Level Security (RLS) on the profiles table
    - This is a temporary change for testing purposes
*/

-- Disable RLS on profiles table
ALTER TABLE profiles DISABLE ROW LEVEL SECURITY;