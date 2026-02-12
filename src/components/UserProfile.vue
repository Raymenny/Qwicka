<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import WorkRequests from './WorkRequests.vue'
import { v4 as uuidv4 } from 'uuid'

interface Skill {
  id: string;
  name: string;
  description: string;
  experience_level: string;
  rate_type: 'fixed' | 'varying' | 'negotiable';
  rate_amount?: number;
  rate_max_amount?: number;
}

interface Review {
  id: string;
  rating: number;
  comment: string;
  reviewer_name: string;
  created_at: string;
}

interface UserProfile {
  id: string;
  full_name: string;
  phone: string;
  area_code: string;
  role: 'worker' | 'employer';
  avatar_url?: string;
  worker_details?: {
    worker_id: string;
    online: boolean;
    max_distance_km: number;
    currently_working: boolean;
  };
  skills?: Skill[];
  reviews?: Review[];
  rating?: number;
}

const props = defineProps<{
  initialProfile?: UserProfile | null;
  currentUser?: UserProfile | null;
}>()

const profile = ref<UserProfile>({
  id: '',
  full_name: '',
  phone: '',
  area_code: '',
  role: 'worker',
  avatar_url: '',
  worker_details: {
    worker_id: '',
    online: false,
    max_distance_km: 20,
    currently_working: false
  },
  skills: [],
  reviews: []
})

const isOwnProfile = computed(() => {
  return props.currentUser?.id === profile.value.id
})

const averageRating = computed(() => {
  if (!profile.value.reviews || profile.value.reviews.length === 0) {
    return profile.value.rating || 0
  }
  const sum = profile.value.reviews.reduce((acc, review) => acc + review.rating, 0)
  return (sum / profile.value.reviews.length).toFixed(1)
})

const isNewWorker = computed(() => {
  return profile.value.role === 'worker' && 
         (!profile.value.reviews || profile.value.reviews.length === 0) &&
         !profile.value.rating
})

const hasGeneratedRequests = ref(false)

const generateTestRequests = () => {
  if (!profile.value.skills || profile.value.skills.length === 0) return

  const distances = [2.3, 4.7, 3.1]
  const testRequests = [
    {
      id: uuidv4(),
      employer: {
        full_name: 'Sarah Johnson',
        phone: '(555) 234-5678'
      },
      skill: {
        name: profile.value.skills[0].name
      },
      rate_offered: profile.value.skills[0].rate_amount || 50,
      description: `Need help with ${profile.value.skills[0].name.toLowerCase()}. Available for immediate start.`,
      created_at: new Date().toISOString(),
      distance: distances[0]
    },
    {
      id: uuidv4(),
      employer: {
        full_name: 'Michael Brown',
        phone: '(555) 345-6789'
      },
      skill: {
        name: profile.value.skills[0].name
      },
      rate_offered: profile.value.skills[0].rate_amount || 50,
      description: `Looking for experienced ${profile.value.skills[0].name.toLowerCase()} professional.`,
      created_at: new Date().toISOString(),
      distance: distances[1]
    },
    {
      id: uuidv4(),
      employer: {
        full_name: 'Emily Wilson',
        phone: '(555) 456-7890'
      },
      skill: {
        name: profile.value.skills[0].name
      },
      rate_offered: profile.value.skills[0].rate_amount || 50,
      description: `Urgent need for ${profile.value.skills[0].name.toLowerCase()} services.`,
      created_at: new Date().toISOString(),
      distance: distances[2]
    }
  ]

  localStorage.setItem(`workRequests_${profile.value.id}`, JSON.stringify(testRequests))
  hasGeneratedRequests.value = true
}

onMounted(() => {
  if (props.initialProfile) {
    profile.value = { ...props.initialProfile }
  }
})

const editMode = ref(false)
const showSkillForm = ref(false)
const newPicture = ref('')
const picturePreview = ref('')

const currentSkill = ref<Skill>({
  id: '',
  name: '',
  description: '',
  experience_level: 'no experience',
  rate_type: 'fixed',
  rate_amount: 0
})

const handlePictureChange = (event: Event) => {
  const input = event.target as HTMLInputElement
  if (input.files && input.files[0]) {
    const file = input.files[0]
    const reader = new FileReader()
    reader.onload = (e) => {
      picturePreview.value = e.target?.result as string
      newPicture.value = picturePreview.value
    }
    reader.readAsDataURL(file)
  }
}

const savePicture = () => {
  if (newPicture.value) {
    profile.value.avatar_url = newPicture.value
    newPicture.value = ''
    picturePreview.value = ''
  }
}

const addSkill = () => {
  if (!profile.value.skills) {
    profile.value.skills = []
  }
  profile.value.skills.push({ ...currentSkill.value })
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

const removeSkill = (index: number) => {
  profile.value.skills?.splice(index, 1)
}

const toggleAvailability = () => {
  if (profile.value.worker_details) {
    // Only allow toggling if not currently working
    if (!profile.value.worker_details.currently_working) {
      profile.value.worker_details.online = !profile.value.worker_details.online
      if (profile.value.worker_details.online && !hasGeneratedRequests.value) {
        generateTestRequests()
      }
    }
  }
}

const handleContact = () => {
  window.location.href = `tel:${profile.value.phone}`
}

const formatDate = (dateString: string) => {
  return new Date(dateString).toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
}

const getStarRating = (rating: number) => {
  return '★'.repeat(rating) + '☆'.repeat(5 - rating)
}
</script>

<template>
  <div class="profile-container">
    <div class="profile-header">
      <div class="profile-picture-section">
        <img 
          :src="profile.avatar_url" 
          alt="Profile picture"
          class="profile-picture"
        >
        <div v-if="editMode && isOwnProfile" class="picture-edit">
          <input 
            type="file" 
            @change="handlePictureChange"
            accept="image/*"
            class="file-input"
          >
          <img 
            v-if="picturePreview" 
            :src="picturePreview" 
            class="picture-preview" 
            alt="New profile picture"
          >
          <button 
            v-if="picturePreview"
            @click="savePicture"
            class="save-picture-button"
          >
            Save Picture
          </button>
        </div>
      </div>
      
      <div class="profile-info">
        <h1>{{ profile.full_name }}</h1>
        <p class="user-type">{{ profile.role === 'worker' ? 'Service Provider' : 'Employer' }}</p>
        <p class="area-code">Area: {{ profile.area_code }}</p>
        <div v-if="profile.role === 'worker'" class="rating-summary">
          <template v-if="isNewWorker">
            <span class="new-badge">New to Qwicka!</span>
          </template>
          <template v-else>
            <span class="stars">{{ getStarRating(Number(averageRating)) }}</span>
            <span class="rating-text">{{ averageRating }} ({{ profile.reviews?.length || 0 }} reviews)</span>
          </template>
        </div>
        <div class="contact-info">
          <p>{{ profile.phone }}</p>
        </div>
        <button 
          v-if="profile.role === 'worker' && profile.worker_details"
          @click="toggleAvailability"
          :class="['availability-toggle', { 
            'online': profile.worker_details.online,
            'working': profile.worker_details.currently_working
          }]"
          :disabled="!isOwnProfile || profile.worker_details.currently_working"
        >
          <span v-if="profile.worker_details.currently_working">Currently Working</span>
          <span v-else>{{ profile.worker_details.online ? 'Online' : 'Offline' }}</span>
        </button>
      </div>

      <div class="action-buttons">
        <button 
          v-if="isOwnProfile"
          @click="editMode = !editMode" 
          class="edit-button"
        >
          {{ editMode ? 'Done' : 'Edit Profile' }}
        </button>
        <button 
          v-if="profile.role === 'worker' && !isOwnProfile" 
          @click="handleContact" 
          class="contact-button"
        >
          Contact
        </button>
      </div>
    </div>

    <!-- Work Requests Section -->
    <WorkRequests 
      v-if="profile.role === 'worker' && isOwnProfile && profile.worker_details?.online"
      :worker-id="profile.id"
    />

    <!-- Reviews Section -->
    <div v-if="profile.role === 'worker' && !isNewWorker" class="reviews-section">
      <h2>Customer Reviews</h2>
      <div v-if="profile.reviews && profile.reviews.length > 0" class="reviews-grid">
        <div v-for="review in profile.reviews" :key="review.id" class="review-card">
          <div class="review-header">
            <span class="stars">{{ getStarRating(review.rating) }}</span>
            <span class="review-date">{{ formatDate(review.created_at) }}</span>
          </div>
          <p class="review-comment">{{ review.comment }}</p>
          <p class="reviewer-name">- {{ review.reviewer_name }}</p>
        </div>
      </div>
    </div>

    <div v-if="profile.role === 'worker' && profile.skills" class="skills-section">
      <div class="skills-header">
        <h2>Skills</h2>
        <button 
          v-if="editMode && isOwnProfile"
          @click="showSkillForm = true"
          class="add-skill-button"
        >
          Add Skill
        </button>
      </div>

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
          <button @click="addSkill" class="save-button">Add</button>
          <button @click="showSkillForm = false" class="cancel-button">Cancel</button>
        </div>
      </div>

      <div class="skills-grid">
        <div v-for="(skill, index) in profile.skills" :key="skill.id" class="skill-card">
          <div class="skill-header">
            <h3>{{ skill.name }}</h3>
            <button 
              v-if="editMode && isOwnProfile"
              @click="removeSkill(index)"
              class="remove-skill-button"
            >
              ×
            </button>
          </div>
          <p class="skill-description">{{ skill.description }}</p>
          <div class="skill-details">
            <p class="skill-level">Level: {{ skill.experience_level }}</p>
            <p class="skill-rate">
              Rate: {{ skill.rate_type === 'negotiable' ? 'Negotiable' : 
                skill.rate_type === 'varying' ? `$${skill.rate_amount}-${skill.rate_max_amount}/hr` :
                `$${skill.rate_amount}/hr` }}
            </p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.profile-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}

.profile-header {
  display: grid;
  grid-template-columns: auto 1fr auto;
  gap: 2rem;
  align-items: start;
  background: white;
  padding: 2rem;
  border-radius: 12px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

.profile-picture-section {
  text-align: center;
}

.profile-picture {
  width: 150px;
  height: 150px;
  border-radius: 50%;
  object-fit: cover;
  margin-bottom: 1rem;
}

.picture-preview {
  width: 100px;
  height: 100px;
  border-radius: 50%;
  object-fit: cover;
  margin: 1rem 0;
}

.file-input {
  margin-top: 1rem;
}

.save-picture-button {
  background-color: #4a5568;
  color: white;
  border: none;
  padding: 0.5rem 1rem;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.9rem;
}

.profile-info h1 {
  margin: 0;
  color: #2d3748;
  font-size: 2rem;
}

.user-type {
  color: #718096;
  font-size: 1.1rem;
  margin: 0.5rem 0;
}

.area-code {
  color: #4a5568;
  font-weight: 500;
  margin: 0.5rem 0;
}

.rating-summary {
  margin: 0.5rem 0;
}

.rating-summary .stars {
  color: #f6ad55;
  font-size: 1.2rem;
  margin-right: 0.5rem;
}

.rating-summary .rating-text {
  color: #4a5568;
  font-weight: 500;
}

.new-badge {
  background-color: #9ae6b4;
  color: #276749;
  padding: 0.25rem 0.75rem;
  border-radius: 20px;
  font-weight: 600;
  font-size: 0.9rem;
}

.contact-info {
  color: #718096;
  margin: 1rem 0;
}

.contact-info p {
  margin: 0.25rem 0;
}

.availability-toggle {
  padding: 0.5rem 1rem;
  border-radius: 20px;
  border: none;
  background-color: #cbd5e0;
  color: #4a5568;
  cursor: pointer;
  font-weight: 500;
  transition: all 0.2s;
}

.availability-toggle.online {
  background-color: #68d391;
  color: #276749;
}

.availability-toggle.working {
  background-color: #718096;
  color: white;
  cursor: not-allowed;
}

.availability-toggle:disabled {
  opacity: 0.7;
  cursor: not-allowed;
}

.action-buttons {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.edit-button, .contact-button {
  padding: 0.75rem 1.5rem;
  border: none;
  border-radius: 6px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s;
}

.edit-button {
  background-color: #4a5568;
  color: white;
}

.contact-button {
  background-color: #fbd38d;
  color: #4a5568;
}

.edit-button:hover, .contact-button:hover {
  transform: translateY(-2px);
}

.reviews-section {
  margin-top: 2rem;
  background: white;
  padding: 2rem;
  border-radius: 12px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

.reviews-section h2 {
  color: #2d3748;
  margin-bottom: 1.5rem;
}

.reviews-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 1.5rem;
}

.review-card {
  background-color: #f7fafc;
  padding: 1.5rem;
  border-radius: 8px;
}

.review-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
}

.review-header .stars {
  color: #f6ad55;
  font-size: 1.2rem;
}

.review-date {
  color: #718096;
  font-size: 0.9rem;
}

.review-comment {
  color: #4a5568;
  margin-bottom: 1rem;
  line-height: 1.5;
}

.reviewer-name {
  color: #2d3748;
  font-weight: 500;
  font-style: italic;
  margin: 0;
}

.skills-section {
  margin-top: 2rem;
  background: white;
  padding: 2rem;
  border-radius: 12px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

.skills-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 2rem;
}

.skills-header h2 {
  margin: 0;
  color: #2d3748;
}

.add-skill-button {
  background-color: #4a5568;
  color: white;
  border: none;
  padding: 0.75rem 1.5rem;
  border-radius: 6px;
  cursor: pointer;
  font-weight: 500;
  transition: all 0.2s;
}

.add-skill-button:hover {
  background-color: #2d3748;
}

.skill-form {
  background-color: #f7fafc;
  padding: 1.5rem;
  border-radius: 8px;
  margin-bottom: 2rem;
}

.form-group {
  margin-bottom: 1rem;
}

.form-group label {
  display: block;
  margin-bottom: 0.5rem;
  color: #4a5568;
  font-weight: 500;
}

.form-group input,
.form-group select,
.form-group textarea {
  width: 100%;
  padding: 0.75rem;
  border: 1px solid #e2e8f0;
  border-radius: 6px;
  font-size: 1rem;
}

.form-group textarea {
  min-height: 100px;
  resize: vertical;
}

.rate-inputs {
  display: flex;
  gap: 1rem;
}

.form-buttons {
  display: flex;
  gap: 1rem;
  margin-top: 1.5rem;
}

.save-button,
.cancel-button {
  flex: 1;
  padding: 0.75rem;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-weight: 500;
  transition: all 0.2s;
}

.save-button {
  background-color: #4a5568;
  color: white;
}

.cancel-button {
  background-color: #e2e8f0;
  color: #4a5568;
}

.skills-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 1.5rem;
}

.skill-card {
  background-color: #f7fafc;
  padding: 1.5rem;
  border-radius: 8px;
  position: relative;
}

.skill-header {
  display: flex;
  justify-content: space-between;
  align-items: start;
  margin-bottom: 1rem;
}

.skill-header h3 {
  margin: 0;
  color: #2d3748;
  font-size: 1.2rem;
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

.skill-description {
  color: #718096;
  margin-bottom: 1rem;
}

.skill-details {
  color: #4a5568;
  font-size: 0.9rem;
}

.skill-details p {
  margin: 0.25rem 0;
}

.skill-level {
  font-weight: 500;
}

.skill-rate {
  color: #2d3748;
  font-weight: 600;
}

@media (max-width: 768px) {
  .profile-header {
    grid-template-columns: 1fr;
    text-align: center;
  }

  .profile-picture-section {
    margin: 0 auto;
  }

  .action-buttons {
    flex-direction: row;
    justify-content: center;
  }

  .reviews-grid,
  .skills-grid {
    grid-template-columns: 1fr;
  }
}
</style>