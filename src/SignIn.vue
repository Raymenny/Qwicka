<script setup lang="ts">
import { ref } from 'vue'
import { v4 as uuidv4 } from 'uuid'

const emit = defineEmits(['account-created'])

interface Skill {
  id: string;
  name: string;
  description: string;
  experience_level: 'no experience' | 'beginner' | 'intermediate' | 'experienced' | 'very experienced';
  rate_type: 'fixed' | 'varying' | 'negotiable';
  rate_amount?: number;
  rate_max_amount?: number;
}

const userType = ref<'worker' | 'employer'>('employer')
const name = ref('')
const phone = ref('')
const areaCode = ref('')
const picture = ref('')
const picturePreview = ref('')
const skills = ref<Skill[]>([])
const showSkillForm = ref(false)
const isReturningUser = ref(false)

const currentSkill = ref<Skill>({
  id: '',
  name: '',
  description: '',
  experience_level: 'no experience',
  rate_type: 'fixed',
  rate_amount: 0
})

const handlePhoneChange = () => {
  // Check local storage for existing user data
  const existingUsers = JSON.parse(localStorage.getItem('users') || '{}')
  if (existingUsers[phone.value]) {
    const userData = existingUsers[phone.value]
    name.value = userData.name
    userType.value = userData.role
    areaCode.value = userData.areaCode
    if (userData.picture) {
      picture.value = userData.picture
      picturePreview.value = userData.picture
    }
    if (userData.skills) {
      skills.value = userData.skills
    }
    isReturningUser.value = true
  } else {
    name.value = ''
    isReturningUser.value = false
  }
}

const handlePictureChange = (event: Event) => {
  const input = event.target as HTMLInputElement
  if (input.files && input.files[0]) {
    const file = input.files[0]
    const reader = new FileReader()
    reader.onload = (e) => {
      picturePreview.value = e.target?.result as string
      picture.value = picturePreview.value
    }
    reader.readAsDataURL(file)
  }
}

const addSkill = () => {
  currentSkill.value.id = uuidv4()
  skills.value.push({ ...currentSkill.value })
  currentSkill.value = {
    id: '',
    name: '',
    description: '',
    experience_level: 'no experience',
    rate_type: 'fixed',
    rate_amount: 0
  }
  showSkillForm.value = false
}

const removeSkill = (skillId: string) => {
  skills.value = skills.value.filter(skill => skill.id !== skillId)
}

const handleSubmit = (e: Event) => {
  e.preventDefault()
  
  const userId = uuidv4()
  const profile = {
    id: userId,
    full_name: name.value,
    phone: phone.value,
    area_code: areaCode.value,
    role: userType.value,
    avatar_url: picture.value,
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString()
  }

  if (userType.value === 'worker') {
    profile.worker_details = {
      worker_id: profile.id,
      online: true,
      max_distance_km: 20,
      currently_working: false
    }
    profile.skills = skills.value
  }

  // Save user data to local storage
  const existingUsers = JSON.parse(localStorage.getItem('users') || '{}')
  existingUsers[phone.value] = {
    name: name.value,
    role: userType.value,
    areaCode: areaCode.value,
    picture: picture.value,
    skills: skills.value
  }
  localStorage.setItem('users', JSON.stringify(existingUsers))

  emit('account-created', profile)
}

const validateForm = () => {
  if (!phone.value || !areaCode.value) return false
  if (!isReturningUser.value && !name.value) return false
  if (userType.value === 'worker') {
    return Boolean(picture.value || picturePreview.value) && skills.value.length > 0
  }
  return true
}

const validateAreaCode = () => {
  const areaCodePattern = /^\d{5}$/
  return areaCodePattern.test(areaCode.value)
}
</script>

<template>
  <div class="signin-container">
    <div class="signin-card">
      <h2>{{ isReturningUser ? 'Welcome Back!' : 'Create Account' }}</h2>
      
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

        <div class="user-type-toggle" v-if="!isReturningUser">
          <button 
            type="button"
            :class="{ active: userType === 'employer' }"
            @click="userType = 'employer'"
          >
            Employer
          </button>
          <button 
            type="button"
            :class="{ active: userType === 'worker' }"
            @click="userType = 'worker'"
          >
            Worker
          </button>
        </div>

        <div class="form-group" v-if="!isReturningUser">
          <label for="name">Name/Company *</label>
          <input 
            type="text" 
            id="name" 
            v-model="name" 
            required
            placeholder="Enter your name or company name"
          >
        </div>

        <div class="form-group">
          <label for="areaCode">ZIP Code *</label>
          <input 
            type="text" 
            id="areaCode" 
            v-model="areaCode" 
            required
            maxlength="5"
            placeholder="Enter your ZIP code"
            :class="{ 'error': !validateAreaCode() && areaCode }"
          >
          <p class="error-message" v-if="!validateAreaCode() && areaCode">
            Please enter a valid 5-digit ZIP code
          </p>
        </div>

        <div class="form-group">
          <label for="picture">Profile Picture {{ userType === 'worker' ? '*' : '' }}</label>
          <input 
            type="file" 
            id="picture" 
            @change="handlePictureChange"
            accept="image/*"
            :required="userType === 'worker'"
          >
          <img 
            v-if="picturePreview" 
            :src="picturePreview" 
            class="picture-preview" 
            alt="Profile preview"
          >
        </div>

        <template v-if="userType === 'worker'">
          <div class="skills-section">
            <h3>Skills *</h3>
            <div v-if="skills.length > 0" class="skills-list">
              <div v-for="skill in skills" :key="skill.id" class="skill-item">
                <div class="skill-header">
                  <h4>{{ skill.name }}</h4>
                  <button 
                    type="button" 
                    class="remove-skill-button"
                    @click="removeSkill(skill.id)"
                  >
                    ×
                  </button>
                </div>
                <p>{{ skill.description }}</p>
                <p>Level: {{ skill.experience_level }}</p>
                <p>Rate: {{ skill.rate_type === 'negotiable' ? 'Negotiable' : 
                  skill.rate_type === 'varying' ? `$${skill.rate_amount}-${skill.rate_max_amount}/hr` :
                  `$${skill.rate_amount}/hr` }}</p>
              </div>
            </div>

            <button 
              type="button"
              class="add-skill-button"
              @click="showSkillForm = true"
            >
              Add Skill
            </button>

            <div v-if="showSkillForm" class="skill-form">
              <div class="form-group">
                <label for="skillName">Skill Name</label>
                <input 
                  type="text" 
                  id="skillName" 
                  v-model="currentSkill.name"
                  required
                >
              </div>

              <div class="form-group">
                <label for="skillDescription">Description</label>
                <textarea 
                  id="skillDescription" 
                  v-model="currentSkill.description"
                  required
                ></textarea>
              </div>

              <div class="form-group">
                <label for="skillLevel">Experience Level</label>
                <select id="skillLevel" v-model="currentSkill.experience_level">
                  <option value="no experience">No Experience</option>
                  <option value="beginner">Beginner</option>
                  <option value="intermediate">Intermediate</option>
                  <option value="experienced">Experienced</option>
                  <option value="very experienced">Very Experienced</option>
                </select>
              </div>

              <div class="form-group">
                <label for="rateType">Rate Type</label>
                <select id="rateType" v-model="currentSkill.rate_type">
                  <option value="fixed">Fixed Rate</option>
                  <option value="varying">Varying Rate</option>
                  <option value="negotiable">Negotiable</option>
                </select>
              </div>

              <template v-if="currentSkill.rate_type !== 'negotiable'">
                <div class="form-group">
                  <label>Rate ($/hr)</label>
                  <div class="rate-inputs">
                    <input 
                      type="number" 
                      v-model="currentSkill.rate_amount"
                      placeholder="Min rate"
                      min="0"
                    >
                    <input 
                      v-if="currentSkill.rate_type === 'varying'"
                      type="number" 
                      v-model="currentSkill.rate_max_amount"
                      placeholder="Max rate"
                      min="0"
                    >
                  </div>
                </div>
              </template>

              <div class="skill-form-buttons">
                <button type="button" @click="addSkill">Add</button>
                <button type="button" @click="showSkillForm = false">Cancel</button>
              </div>
            </div>
          </div>
        </template>

        <button 
          type="submit" 
          class="submit-button"
          :disabled="!validateForm()"
        >
          {{ isReturningUser ? 'Sign In' : 'Create Account' }}
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

.user-type-toggle {
  display: flex;
  gap: 1rem;
  margin-bottom: 1.5rem;
}

.user-type-toggle button {
  flex: 1;
  padding: 0.75rem;
  border: 2px solid #e2e8f0;
  background: none;
  border-radius: 6px;
  cursor: pointer;
  font-weight: 500;
  transition: all 0.2s;
}

.user-type-toggle button.active {
  background-color: #4a5568;
  color: white;
  border-color: #4a5568;
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

input, select, textarea {
  width: 100%;
  padding: 0.75rem;
  border: 1px solid #e2e8f0;
  border-radius: 6px;
  font-size: 1rem;
  transition: border-color 0.2s;
}

input.error {
  border-color: #fc8181;
}

.error-message {
  color: #fc8181;
  font-size: 0.9rem;
  margin-top: 0.5rem;
}

textarea {
  min-height: 100px;
  resize: vertical;
}

input:focus, select:focus, textarea:focus {
  outline: none;
  border-color: #4a5568;
}

.picture-preview {
  width: 100px;
  height: 100px;
  object-fit: cover;
  border-radius: 50%;
  margin-top: 1rem;
}

.skills-section {
  margin-top: 2rem;
  padding-top: 1rem;
  border-top: 1px solid #e2e8f0;
}

.skills-list {
  margin-bottom: 1rem;
}

.skill-item {
  background-color: #f7fafc;
  padding: 1rem;
  border-radius: 6px;
  margin-bottom: 1rem;
}

.skill-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.skill-header h4 {
  margin: 0;
  color: #2d3748;
}

.remove-skill-button {
  background: none;
  border: none;
  color: #e53e3e;
  font-size: 1.5rem;
  cursor: pointer;
  padding: 0;
  line-height: 1;
}

.add-skill-button {
  width: 100%;
  padding: 0.75rem;
  background-color: #e2e8f0;
  border: none;
  border-radius: 6px;
  color: #4a5568;
  font-weight: 500;
  cursor: pointer;
  transition: background-color 0.2s;
}

.add-skill-button:hover {
  background-color: #cbd5e0;
}

.skill-form {
  margin-top: 1rem;
  padding: 1rem;
  background-color: #f7fafc;
  border-radius: 6px;
}

.rate-inputs {
  display: flex;
  gap: 1rem;
}

.skill-form-buttons {
  display: flex;
  gap: 1rem;
  margin-top: 1rem;
}

.skill-form-buttons button {
  flex: 1;
  padding: 0.75rem;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-weight: 500;
  transition: all 0.2s;
}

.skill-form-buttons button:first-child {
  background-color: #4a5568;
  color: white;
}

.skill-form-buttons button:last-child {
  background-color: #e2e8f0;
  color: #4a5568;
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