<script setup lang="ts">
import { ref, onMounted } from 'vue'

const emit = defineEmits(['account-created'])

const phone = ref('')
const isValidUser = ref(false)
const userData = ref<any>(null)

const handlePhoneChange = () => {
  const existingUsers = JSON.parse(localStorage.getItem('users') || '{}')
  if (existingUsers[phone.value]) {
    userData.value = existingUsers[phone.value]
    isValidUser.value = true
  } else {
    userData.value = null
    isValidUser.value = false
  }
}

const handleSubmit = (e: Event) => {
  e.preventDefault()
  if (isValidUser.value && userData.value) {
    const profile = {
      id: crypto.randomUUID(),
      full_name: userData.value.name,
      phone: phone.value,
      area_code: userData.value.areaCode,
      role: userData.value.role,
      avatar_url: userData.value.picture,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    }

    if (userData.value.role === 'worker') {
      profile.worker_details = {
        worker_id: profile.id,
        online: true,
        max_distance_km: 20,
        currently_working: false
      }
      profile.skills = userData.value.skills
    }

    emit('account-created', profile)
  }
}
</script>

<template>
  <div class="signin-container">
    <div class="signin-card">
      <h2>Welcome Back!</h2>
      
      <form @submit.prevent="handleSubmit">
        <div class="form-group">
          <label for="phone">Phone Number *</label>
          <input 
            type="tel" 
            id="phone" 
            v-model="phone" 
            @input="handlePhoneChange"
            required
            placeholder="Enter your phone number"
          >
        </div>

        <div v-if="isValidUser" class="user-info">
          <p class="welcome-message">Welcome back, {{ userData?.name }}!</p>
          <p class="user-type">{{ userData?.role === 'worker' ? 'Service Provider' : 'Employer' }}</p>
        </div>

        <div v-else class="error-message">
          <p v-if="phone">No account found with this phone number</p>
        </div>

        <button 
          type="submit" 
          class="submit-button"
          :disabled="!isValidUser"
        >
          Sign In
        </button>
      </form>
    </div>
  </div>
</template>

<style scoped>
.signin-container {
  min-height: calc(100vh - 200px);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 2rem;
  background-color: #f7fafc;
}

.signin-card {
  background: white;
  padding: 2rem;
  border-radius: 12px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  width: 100%;
  max-width: 500px;
}

h2 {
  color: #2d3748;
  margin-bottom: 2rem;
  text-align: center;
  font-size: 1.8rem;
}

.form-group {
  margin-bottom: 1.5rem;
}

label {
  display: block;
  margin-bottom: 0.5rem;
  color: #4a5568;
  font-weight: 500;
}

input {
  width: 100%;
  padding: 0.75rem;
  border: 1px solid #e2e8f0;
  border-radius: 6px;
  font-size: 1rem;
  transition: border-color 0.2s;
}

input:focus {
  outline: none;
  border-color: #4a5568;
}

.user-info {
  text-align: center;
  margin: 1.5rem 0;
  padding: 1rem;
  background-color: #f7fafc;
  border-radius: 6px;
}

.welcome-message {
  color: #2d3748;
  font-size: 1.2rem;
  font-weight: 600;
  margin: 0;
}

.user-type {
  color: #718096;
  margin: 0.5rem 0 0;
}

.error-message {
  color: #e53e3e;
  text-align: center;
  margin: 1rem 0;
}

.submit-button {
  width: 100%;
  padding: 0.75rem;
  background-color: #4a5568;
  color: white;
  border: none;
  border-radius: 6px;
  font-size: 1rem;
  font-weight: 500;
  cursor: pointer;
  transition: background-color 0.2s;
}

.submit-button:hover:not(:disabled) {
  background-color: #2d3748;
}

.submit-button:disabled {
  opacity: 0.7;
  cursor: not-allowed;
}
</style>