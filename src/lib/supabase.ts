import { createClient } from '@supabase/supabase-js'
import { ref } from 'vue'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

export const supabase = createClient(supabaseUrl, supabaseAnonKey)

// Profile types
export interface Profile {
  id: string
  username: string
  full_name: string
  avatar_url?: string
  phone: string
  role: 'worker' | 'employer'
  created_at: string
  updated_at: string
}

export interface WorkerDetails {
  worker_id: string
  online: boolean
  max_distance_km: number
  currently_working: boolean
  current_contract_id?: string
}

// Profile functions
export async function createProfile(profile: Partial<Profile>) {
  const { data, error } = await supabase
    .from('profiles')
    .insert(profile)
    .select()
    .single()

  if (error) throw error
  return data
}

export async function getProfile(id: string) {
  try {
    const { data, error } = await supabase
      .from('profiles')
      .select('*, worker_details(*)')
      .eq('id', id)
      .maybeSingle()

    if (error) throw error
    return data
  } catch (error) {
    console.error('Error fetching profile:', error)
    throw error
  }
}

export async function updateProfile(id: string, profile: Partial<Profile>) {
  const { data, error } = await supabase
    .from('profiles')
    .update(profile)
    .eq('id', id)
    .select()
    .single()

  if (error) throw error
  return data
}

// Worker functions
export async function createWorkerDetails(details: Partial<WorkerDetails>) {
  const { data, error } = await supabase
    .from('worker_details')
    .insert(details)
    .select()
    .single()

  if (error) throw error
  return data
}

export async function updateWorkerDetails(id: string, details: Partial<WorkerDetails>) {
  const { data, error } = await supabase
    .from('worker_details')
    .update(details)
    .eq('worker_id', id)
    .select()
    .single()

  if (error) throw error
  return data
}