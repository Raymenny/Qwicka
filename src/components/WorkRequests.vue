<script setup lang="ts">
import { ref, onMounted, watch } from 'vue'

interface WorkRequest {
  id: string
  employer: {
    full_name: string
    phone: string
  }
  skill: {
    name: string
  }
  status?: 'pending' | 'accepted' | 'rejected'
  created_at: string
  description: string
  rate_offered: number
  distance: number
}

const props = defineProps<{
  workerId: string
}>()

const requests = ref<WorkRequest[]>([])
const loading = ref(false)
const error = ref<string | null>(null)
const acceptedRequest = ref<WorkRequest | null>(null)
const hasGeneratedRequests = ref(false)

const handleRequest = async (requestId: string, status: 'accepted' | 'rejected') => {
  if (status === 'accepted') {
    const request = requests.value.find(req => req.id === requestId)
    if (request) {
      acceptedRequest.value = request
      requests.value = []
      
      // Store the accepted request and worker status
      const workerStatus = {
        currently_working: true,
        online: false,
        acceptedRequest: request,
        hasGeneratedRequests: true
      }
      localStorage.setItem(`workerStatus_${props.workerId}`, JSON.stringify(workerStatus))
      
      // Clear pending requests
      localStorage.removeItem(`workRequests_${props.workerId}`)
    }
  } else {
    requests.value = requests.value.filter(req => req.id !== requestId)
    localStorage.setItem(`workRequests_${props.workerId}`, JSON.stringify(requests.value))
  }
}

// Load saved state on worker ID change
watch(() => props.workerId, () => {
  if (props.workerId) {
    loadWorkerState()
  }
})

const loadWorkerState = () => {
  // Check for existing worker status first
  const savedStatus = localStorage.getItem(`workerStatus_${props.workerId}`)
  if (savedStatus) {
    const status = JSON.parse(savedStatus)
    if (status.acceptedRequest) {
      acceptedRequest.value = status.acceptedRequest
      requests.value = []
      hasGeneratedRequests.value = true
      return
    }
    if (status.hasGeneratedRequests) {
      hasGeneratedRequests.value = true
    }
  }

  // Only load requests if there's no accepted request and requests haven't been generated
  const savedRequests = localStorage.getItem(`workRequests_${props.workerId}`)
  if (savedRequests && !acceptedRequest.value && !hasGeneratedRequests.value) {
    requests.value = JSON.parse(savedRequests)
  }
  loading.value = false
}

onMounted(() => {
  if (props.workerId) {
    loadWorkerState()
  }
})
</script>

<template>
  <div class="work-requests">
    <h2>Work Requests</h2>
    
    <div v-if="loading" class="loading">
      Loading requests...
    </div>
    
    <div v-else-if="error" class="error">
      {{ error }}
    </div>

    <div v-else-if="acceptedRequest" class="accepted-message">
      <p>You have accepted {{ acceptedRequest.employer.full_name }}'s request.</p>
      <p>They will contact you at their earliest convenience.</p>
      <p class="status-note">Your status has been set to offline while you complete this work.</p>
    </div>
    
    <div v-else-if="hasGeneratedRequests && requests.length === 0" class="no-requests">
      No more work requests available
    </div>
    
    <div v-else-if="requests.length === 0" class="no-requests">
      No pending work requests
    </div>
    
    <div v-else class="requests-list">
      <div v-for="request in requests" :key="request.id" class="request-card">
        <div class="request-header">
          <h3>{{ request.skill.name }}</h3>
          <span class="rate">${{ request.rate_offered }}/hr</span>
        </div>
        
        <div class="employer-info">
          <p class="employer-name">{{ request.employer.full_name }}</p>
          <p class="distance">{{ request.distance.toFixed(1) }} miles away</p>
          <p class="request-date">
            {{ new Date(request.created_at).toLocaleDateString() }}
          </p>
        </div>
        
        <p class="description">{{ request.description }}</p>
        
        <div class="actions">
          <button 
            class="accept-button"
            @click="handleRequest(request.id, 'accepted')"
          >
            Accept
          </button>
          <button 
            class="reject-button"
            @click="handleRequest(request.id, 'rejected')"
          >
            Reject
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.work-requests {
  margin-top: 2rem;
  padding: 1.5rem;
  background: white;
  border-radius: 12px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

h2 {
  color: #2d3748;
  margin-bottom: 1.5rem;
  font-size: 1.5rem;
}

.loading, .error, .no-requests {
  text-align: center;
  padding: 2rem;
  color: #718096;
}

.accepted-message {
  text-align: center;
  padding: 2rem;
  color: #48bb78;
  font-weight: 600;
  font-size: 1.1rem;
}

.status-note {
  color: #718096;
  font-size: 0.9rem;
  margin-top: 1rem;
}

.error {
  color: #e53e3e;
}

.requests-list {
  display: grid;
  gap: 1rem;
}

.request-card {
  padding: 1.5rem;
  background: #f7fafc;
  border-radius: 8px;
  border: 1px solid #e2e8f0;
}

.request-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
}

.request-header h3 {
  margin: 0;
  color: #2d3748;
  font-size: 1.2rem;
}

.rate {
  font-weight: 600;
  color: #48bb78;
}

.employer-info {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
}

.employer-name {
  color: #4a5568;
  font-weight: 500;
  margin: 0;
}

.distance {
  color: #4a5568;
  font-weight: 500;
  margin: 0;
}

.request-date {
  color: #718096;
  font-size: 0.9rem;
  margin: 0;
}

.description {
  color: #4a5568;
  margin-bottom: 1.5rem;
}

.actions {
  display: flex;
  gap: 1rem;
}

.accept-button, .reject-button {
  flex: 1;
  padding: 0.75rem;
  border: none;
  border-radius: 6px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s;
}

.accept-button {
  background-color: #48bb78;
  color: white;
}

.accept-button:hover {
  background-color: #38a169;
}

.reject-button {
  background-color: #fc8181;
  color: white;
}

.reject-button:hover {
  background-color: #e53e3e;
}
</style>