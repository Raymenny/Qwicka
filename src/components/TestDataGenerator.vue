<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { supabase } from '../lib/supabase'
import { v4 as uuidv4 } from 'uuid'

const props = defineProps<{
  workerId: string
}>()

const skills = [
  { id: uuidv4(), name: 'House Cleaning', rate: 35 },
  { id: uuidv4(), name: 'Lawn Maintenance', rate: 45 },
  { id: uuidv4(), name: 'Plumbing', rate: 85 },
  { id: uuidv4(), name: 'Electrical Work', rate: 95 },
  { id: uuidv4(), name: 'Painting', rate: 55 }
]

const employers = [
  { id: uuidv4(), name: 'John Smith', phone: '(555) 123-4567' },
  { id: uuidv4(), name: 'Sarah Johnson', phone: '(555) 234-5678' },
  { id: uuidv4(), name: 'Mike Wilson', phone: '(555) 345-6789' },
  { id: uuidv4(), name: 'Emily Brown', phone: '(555) 456-7890' },
  { id: uuidv4(), name: 'David Miller', phone: '(555) 567-8901' }
]

const generateTestData = async () => {
  try {
    // Create skills first
    const { data: skillsData, error: skillsError } = await supabase
      .from('skills')
      .insert(skills.map(skill => ({
        id: skill.id,
        name: skill.name,
        description: `Professional ${skill.name.toLowerCase()} services`
      })))
      .select()

    if (skillsError) throw skillsError

    // Create employer profiles
    const { data: employersData, error: employersError } = await supabase
      .from('profiles')
      .insert(employers.map(employer => ({
        id: employer.id,
        full_name: employer.name,
        username: employer.name.toLowerCase().replace(' ', '_'),
        phone: employer.phone,
        role: 'employer',
        phone_verified: true
      })))
      .select()

    if (employersError) throw employersError

    // Create work requests
    const requests = skills.map((skill, index) => ({
      id: uuidv4(),
      worker_id: props.workerId,
      employer_id: employers[index].id,
      skill_id: skill.id,
      status: 'pending',
      description: `Need help with ${skill.name.toLowerCase()}. Available for immediate start.`,
      rate_offered: skill.rate,
      created_at: new Date(Date.now() - (index * 60000)).toISOString() // Stagger creation times
    }))

    const { error: requestsError } = await supabase
      .from('work_requests')
      .insert(requests)

    if (requestsError) throw requestsError

  } catch (error) {
    console.error('Error generating test data:', error)
  }
}

onMounted(() => {
  // Wait 30 seconds before generating test data
  setTimeout(generateTestData, 30000)
})
</script>

<template>
  <!-- This component doesn't render anything -->
</template>