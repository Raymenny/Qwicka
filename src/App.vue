<script setup lang="ts">
import ServiceSection from './components/ServiceSection.vue'
import HeroSection from './components/HeroSection.vue'
import SignIn from './components/SignIn.vue'
import SignInPage from './components/SignInPage.vue'
import LocalServices from './components/LocalServices.vue'
import UserProfile from './components/UserProfile.vue'
import AboutSection from './components/AboutSection.vue'
import { ref, provide, onMounted } from 'vue'
import { v4 as uuidv4 } from 'uuid'

// Clear any saved user data on app start
onMounted(() => {
  localStorage.removeItem('users')
})

const showSignIn = ref(false)
const showSignInPage = ref(false)
const showLocalServices = ref(false)
const showUserProfile = ref(false)
const showAbout = ref(false)
const selectedZipCode = ref('')
const selectedService = ref('')
const showSearch = ref(false)
const userProfileData = ref<any>(null)
const currentProfile = ref<any>(null)
const workerProfiles = ref<any[]>([])

// Provide worker profiles to child components
provide('workerProfiles', workerProfiles)

const goToHome = () => {
  showSignIn.value = false
  showSignInPage.value = false
  showLocalServices.value = false
  showSearch.value = false
  showUserProfile.value = false
  showAbout.value = false
}

const handleSearch = (zipCode: string) => {
  selectedZipCode.value = zipCode
  showLocalServices.value = true
  showSearch.value = false
}

const handleServiceSelect = (service: string) => {
  selectedService.value = service
  showSearch.value = true
}

const handleLogout = () => {
  // Remove the worker from available services when they log out
  if (userProfileData.value?.role === 'worker') {
    workerProfiles.value = workerProfiles.value.filter(w => w.id !== userProfileData.value.id)
  }
  userProfileData.value = null
  currentProfile.value = null
  goToHome()
}

const generateReviews = (rating: number, numReviews: number) => {
  const reviewers = [
    { name: 'Patricia Adams', comment: "Outstanding service! They were punctual, professional, and did an amazing job." },
    { name: 'Thomas Moore', comment: "Exceeded my expectations in every way. Very skilled and thorough with great attention to detail." },
    { name: 'Richard Lee', comment: "Fantastic experience from start to finish. Very reliable and reasonably priced." },
    { name: 'Susan Clark', comment: "Professional, courteous, and efficient. The quality of work was excellent." },
    { name: 'Kevin Wright', comment: "Great communication throughout the project. Would definitely hire again." },
    { name: 'Mary Turner', comment: "Top-notch service and results. Very pleased with their work." }
  ]

  const shuffled = [...reviewers].sort(() => Math.random() - 0.5)
  const selected = shuffled.slice(0, 3)

  return selected.map((reviewer, i) => ({
    id: uuidv4(),
    rating: Math.max(3, Math.min(5, rating + (Math.random() * 0.4 - 0.2))),
    comment: reviewer.comment,
    reviewer_name: reviewer.name,
    created_at: new Date(Date.now() - (i * 30 * 24 * 60 * 60 * 1000)).toISOString()
  }))
}

const handleAccountCreated = (profileData: any) => {
  userProfileData.value = profileData
  currentProfile.value = profileData
  showSignIn.value = false
  showSignInPage.value = false
  showUserProfile.value = true

  if (profileData.role === 'worker') {
    currentProfile.value.reviews = []
    // Remove any existing listings for this worker
    workerProfiles.value = workerProfiles.value.filter(w => w.id !== profileData.id)
    // Add new service listing
    const serviceListing = {
      id: profileData.id,
      name: profileData.full_name,
      rating: 0,
      reviews: 0,
      distance: Math.round(Math.random() * 10 * 10) / 10,
      baseRate: profileData.skills[0]?.rate_amount || 0,
      location: { lat: 33.8293 + (Math.random() * 0.02), lng: -118.1005 + (Math.random() * 0.02) },
      areaCode: profileData.area_code,
      services: profileData.skills.map((s: any) => s.name),
      tags: profileData.skills.map((s: any) => s.name),
      description: profileData.skills[0]?.description || '',
      image: profileData.avatar_url,
      badges: ['New Provider'],
      profile: profileData
    }
    workerProfiles.value.push(serviceListing)
  }
}

const handleShowProfile = (profile: any) => {
  if (profile.rating) {
    profile.reviews = generateReviews(profile.rating, 3)
  }
  currentProfile.value = profile
  showLocalServices.value = false
  showUserProfile.value = true
}

const showUserProfilePage = () => {
  currentProfile.value = userProfileData.value
  showSignIn.value = false
  showSignInPage.value = false
  showLocalServices.value = false
  showSearch.value = false
  showUserProfile.value = true
  showAbout.value = false
}

const showAboutPage = () => {
  showSignIn.value = false
  showSignInPage.value = false
  showLocalServices.value = false
  showSearch.value = false
  showUserProfile.value = false
  showAbout.value = true
}
</script>

<template>
  <div class="app-container">
    <header>
      <nav>
        <h1 @click="goToHome" class="logo">Qwicka</h1>
        <div class="nav-links">
          <a href="#services">Services</a>
          <a href="#" @click.prevent="showAboutPage">About</a>
          <a href="#contact">Contact</a>
          <template v-if="userProfileData">
            <button class="profile-button" @click="showUserProfilePage">
              {{ userProfileData.full_name }}
            </button>
            <button 
              v-if="!userProfileData.worker_details?.currently_working"
              class="logout-button" 
              @click="handleLogout"
            >
              Logout
            </button>
          </template>
          <template v-else>
            <button v-if="!showSignInPage" class="sign-in-button" @click="showSignInPage = true">Sign In</button>
            <button v-else class="sign-in-button" @click="showSignIn = true; showSignInPage = false">Create Account</button>
          </template>
        </div>
      </nav>
    </header>

    <SignIn 
      v-if="showSignIn" 
      @account-created="handleAccountCreated"
    />
    <SignInPage
      v-else-if="showSignInPage"
      @account-created="handleAccountCreated"
    />
    <UserProfile 
      v-else-if="showUserProfile" 
      :initial-profile="currentProfile"
      :current-user="userProfileData"
    />
    <AboutSection
      v-else-if="showAbout"
    />
    <LocalServices 
      v-else-if="showLocalServices" 
      :zipCode="selectedZipCode" 
      :serviceType="selectedService"
      @showProfile="handleShowProfile"
    />
    <template v-else>
      <div v-if="showSearch">
        <HeroSection @search="handleSearch" :selectedService="selectedService" />
      </div>
      <template v-else>
        <HeroSection @search="handleSearch" />
        <ServiceSection @selectService="handleServiceSelect" />
      </template>
    </template>

    <footer>
      <p>&copy; 2025 Qwicka. All rights reserved.</p>
    </footer>
  </div>
</template>

<style>
.app-container {
  max-width: 100%;
  margin: 0;
  padding: 0;
  text-align: left;
}

header {
  background-color: #4a5568;
  padding: 1rem 2rem;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

nav {
  display: flex;
  justify-content: space-between;
  align-items: center;
  max-width: 1200px;
  margin: 0 auto;
}

.logo {
  font-size: 2rem;
  margin: 0;
  color: white;
  font-weight: bold;
  letter-spacing: -0.5px;
  cursor: pointer;
  transition: opacity 0.2s;
}

.logo:hover {
  opacity: 0.8;
}

.nav-links {
  display: flex;
  gap: 2rem;
  align-items: center;
}

.nav-links a {
  color: white;
  text-decoration: none;
  font-weight: 500;
  transition: opacity 0.2s;
}

.nav-links a:hover {
  opacity: 0.8;
}

.sign-in-button, .profile-button, .logout-button {
  padding: 0.5rem 1.5rem;
  border: none;
  border-radius: 6px;
  font-weight: 600;
  cursor: pointer;
  transition: background-color 0.2s, transform 0.2s;
}

.sign-in-button, .profile-button {
  background-color: #fbd38d;
  color: #4a5568;
}

.logout-button {
  background-color: #fc8181;
  color: white;
}

.sign-in-button:hover, .profile-button:hover {
  background-color: #f6ad55;
  transform: translateY(-2px);
}

.logout-button:hover {
  background-color: #e53e3e;
  transform: translateY(-2px);
}

footer {
  background-color: #4a5568;
  padding: 2rem;
  text-align: center;
  margin-top: 4rem;
  color: white;
}

footer p {
  color: rgba(255, 255, 255, 0.9);
  margin: 0;
}
</style>