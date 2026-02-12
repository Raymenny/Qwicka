<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'

const emit = defineEmits(['search'])
const props = defineProps<{
  selectedService?: string
}>()

const areaCode = ref('')
const isValidAreaCode = ref(true)
const currentImageIndex = ref(0)

const backgroundImages = [
  'https://images.unsplash.com/photo-1646324554833-f0b6a479fa5d?auto=format&fit=crop&q=80', // Home maintenance
  'https://images.unsplash.com/photo-1734079692160-fcbe4be6ab96?auto=format&fit=crop&q=80', // Landscaping
  'https://images.unsplash.com/photo-1505798577917-a65157d3320a?auto=format&fit=crop&q=80', // Home improvement
]

let intervalId: number

const startImageRotation = () => {
  intervalId = setInterval(() => {
    currentImageIndex.value = (currentImageIndex.value + 1) % backgroundImages.length
  }, 5000)
}

onMounted(() => {
  if (!props.selectedService) {
    startImageRotation()
  }
})

onUnmounted(() => {
  clearInterval(intervalId)
})

const validateAreaCode = () => {
  const areaCodePattern = /^\d{5}$/
  isValidAreaCode.value = areaCodePattern.test(areaCode.value)
}

const searchServices = () => {
  if (isValidAreaCode.value) {
    emit('search', areaCode.value)
  }
}
</script>

<template>
  <section class="hero" :class="{ 'service-specific': selectedService }">
    <template v-if="!selectedService">
      <div 
        v-for="(image, index) in backgroundImages" 
        :key="index"
        class="background-image"
        :class="{ active: index === currentImageIndex }"
        :style="{ backgroundImage: `url(${image})` }"
      ></div>
    </template>
    <div class="overlay"></div>
    <div class="hero-content">
      <template v-if="selectedService">
        <h1>Compare quotes from top-rated<br><span class="highlight">{{ selectedService }}</span> professionals</h1>
      </template>
      <template v-else>
        <div class="hero-badge">Lightning Fast Service Marketplace</div>
        <h1>Get Any Service,<br>In a <span class="highlight">Qwick</span> Click</h1>
      </template>
      <div class="search-container">
        <div class="input-group">
          <input 
            type="text" 
            v-model="areaCode"
            @input="validateAreaCode"
            placeholder="Enter your ZIP code"
            maxlength="5"
            class="zip-input"
            :class="{ 'error': !isValidAreaCode && areaCode }"
          >
          <button 
            @click="searchServices"
            class="search-button"
            :disabled="!isValidAreaCode || !areaCode"
          >
            Find Local Services
          </button>
        </div>
        <p class="error-message" v-if="!isValidAreaCode && areaCode">
          Please enter a valid 5-digit ZIP code
        </p>
      </div>
    </div>
  </section>
</template>

<style scoped>
.hero {
  position: relative;
  padding: 6rem 2rem;
  text-align: center;
  color: white;
  min-height: 600px;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
}

.service-specific {
  min-height: 400px;
  background-color: #4a5568;
}

.background-image {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-size: cover;
  background-position: center;
  opacity: 0;
  transition: opacity 1s ease-in-out;
}

.background-image.active {
  opacity: 1;
}

.overlay {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.5);
}

.hero-content {
  position: relative;
  z-index: 1;
  max-width: 900px;
  margin: 0 auto;
}

.hero-badge {
  background: rgba(255, 255, 255, 0.2);
  padding: 0.5rem 1rem;
  border-radius: 20px;
  display: inline-block;
  margin-bottom: 1.5rem;
  font-weight: 500;
  backdrop-filter: blur(4px);
}

.hero h1 {
  font-size: 3.5rem;
  font-weight: 800;
  line-height: 1.2;
  margin-bottom: 1.5rem;
  letter-spacing: -0.5px;
  text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.3);
}

.highlight {
  color: #fbd38d;
}

.search-container {
  max-width: 500px;
  margin: 2rem auto;
  background: rgba(255, 255, 255, 0.1);
  padding: 1.5rem;
  border-radius: 12px;
  backdrop-filter: blur(8px);
}

.input-group {
  display: flex;
  gap: 0.5rem;
  margin-bottom: 0.5rem;
}

.zip-input {
  flex: 1;
  padding: 1rem;
  border: 2px solid transparent;
  border-radius: 8px;
  font-size: 1.1rem;
  outline: none;
  transition: border-color 0.2s;
  background: rgba(255, 255, 255, 0.9);
}

.zip-input::placeholder {
  color: #a0aec0;
}

.zip-input.error {
  border-color: #fc8181;
}

.search-button {
  background-color: #fbd38d;
  color: #4a5568;
  border: none;
  padding: 1rem 2rem;
  font-size: 1.1rem;
  border-radius: 8px;
  cursor: pointer;
  transition: transform 0.2s, background-color 0.2s;
  font-weight: 600;
}

.search-button:hover:not(:disabled) {
  background-color: #f6ad55;
  transform: translateY(-2px);
}

.search-button:disabled {
  opacity: 0.7;
  cursor: not-allowed;
}

.error-message {
  color: #fc8181;
  font-size: 0.9rem;
  margin-top: 0.5rem;
  text-align: left;
  text-shadow: 1px 1px 2px rgba(0, 0, 0, 0.5);
}
</style>