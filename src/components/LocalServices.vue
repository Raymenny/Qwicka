<script setup lang="ts">
import { ref, computed, onMounted, inject } from 'vue'
import { defineProps, defineEmits } from 'vue'
import { Loader } from '@googlemaps/js-api-loader'

const emit = defineEmits(['showProfile'])

const props = defineProps<{
  zipCode: string
  serviceType?: string
}>()

const workerProfiles = inject('workerProfiles', ref([]))

const map = ref<google.maps.Map | null>(null)
const mapContainer = ref<HTMLElement | null>(null)

// Pagination
const itemsPerPage = 5
const currentPage = ref(1)

// Filter states
const selectedDistance = ref('any')
const selectedPriceRange = ref('any')
const selectedRating = ref('any')
const searchQuery = ref('')
const selectedTags = ref<string[]>([])

const distances = [
  { value: 'any', label: 'Any Distance' },
  { value: '5', label: 'Within 5 miles' },
  { value: '10', label: 'Within 10 miles' },
  { value: '25', label: 'Within 25 miles' },
  { value: '50', label: 'Within 50 miles' }
]

const priceRanges = [
  { value: 'any', label: 'Any Price' },
  { value: '0-50', label: '$0-$50/hr' },
  { value: '51-100', label: '$51-$100/hr' },
  { value: '101-150', label: '$101-$150/hr' },
  { value: '151+', label: '$151+/hr' }
]

const ratings = [
  { value: 'any', label: 'Any Rating' },
  { value: '4.5', label: '4.5+ stars' },
  { value: '4.0', label: '4.0+ stars' },
  { value: '3.5', label: '3.5+ stars' },
  { value: '3.0', label: '3.0+ stars' }
]

const allTags = [
  'Cleaning', 'Deep Cleaning', 'Move-in/Move-out',
  'Lawn Care', 'Garden Design', 'Tree Service',
  'Plumbing', 'Electrical', 'HVAC',
  'Painting', 'Carpentry', 'Flooring',
  'Roofing', 'Siding', 'Windows',
  'Kitchen Remodel', 'Bathroom Remodel',
  'Pest Control', 'Pool Service',
  'Appliance Repair', 'Garage Door'
]

// Sample data with real addresses around 90808 (Long Beach, CA)
const localServices = [
  {
    id: 1,
    name: 'Express Home Cleaning',
    rating: 4.8,
    reviews: 156,
    distance: 3.2,
    baseRate: 45,
    location: { lat: 33.8293, lng: -118.1005 },
    areaCode: '90808',
    services: ['Regular Cleaning', 'Deep Cleaning', 'Move-in/Move-out'],
    tags: ['Cleaning', 'Deep Cleaning', 'Move-in/Move-out'],
    description: 'Professional cleaning services with 10+ years of experience. Specializing in residential and commercial cleaning.',
    image: 'https://images.unsplash.com/photo-1618038483079-bfe64dcb17f1?auto=format&fit=crop&q=80',
    badges: ['Top Rated', 'Background Check', 'Insured'],
    profile: {
      id: '1',
      full_name: 'Express Home Cleaning',
      phone: '(562) 123-4567',
      area_code: '90808',
      role: 'worker',
      rating: 4.8,
      reviews: 156,
      avatar_url: 'https://images.unsplash.com/photo-1618038483079-bfe64dcb17f1?auto=format&fit=crop&q=80',
      worker_details: {
        worker_id: '1',
        online: true,
        max_distance_km: 20,
        currently_working: false
      },
      skills: [
        {
          id: '1',
          name: 'House Cleaning',
          description: 'Professional home cleaning services for all room types',
          experience_level: 'very experienced',
          rate_type: 'varying',
          rate_amount: 30,
          rate_max_amount: 50
        },
        {
          id: '2',
          name: 'Deep Cleaning',
          description: 'Thorough deep cleaning services including hard to reach areas',
          experience_level: 'experienced',
          rate_type: 'fixed',
          rate_amount: 60
        }
      ]
    }
  },
  {
    id: 2,
    name: 'Green Thumb Landscaping',
    rating: 4.9,
    reviews: 203,
    distance: 5.7,
    baseRate: 75,
    location: { lat: 33.8315, lng: -118.1156 },
    areaCode: '90815',
    services: ['Lawn Care', 'Garden Design', 'Tree Service'],
    tags: ['Lawn Care', 'Garden Design', 'Tree Service'],
    description: 'Full-service landscaping company offering design, maintenance, and installation services.',
    image: 'https://images.unsplash.com/photo-1558904541-efa843a96f01?auto=format&fit=crop&q=80',
    badges: ['Elite Service', 'Licensed', 'Insured'],
    profile: {
      id: '2',
      full_name: 'Green Thumb Landscaping',
      phone: '(562) 234-5678',
      area_code: '90815',
      role: 'worker',
      rating: 4.9,
      reviews: 203,
      avatar_url: 'https://images.unsplash.com/photo-1558904541-efa843a96f01?auto=format&fit=crop&q=80',
      worker_details: {
        worker_id: '2',
        online: true,
        max_distance_km: 20,
        currently_working: false
      },
      skills: [
        {
          id: '3',
          name: 'Lawn Maintenance',
          description: 'Complete lawn care including mowing, edging, and fertilizing',
          experience_level: 'very experienced',
          rate_type: 'varying',
          rate_amount: 40,
          rate_max_amount: 75
        },
        {
          id: '4',
          name: 'Garden Design',
          description: 'Custom garden design and installation',
          experience_level: 'experienced',
          rate_type: 'negotiable'
        }
      ]
    }
  },
  {
    id: 3,
    name: 'Handyman Heroes',
    rating: 4.7,
    reviews: 178,
    distance: 8.3,
    baseRate: 55,
    location: { lat: 33.8198, lng: -118.0890 },
    areaCode: '90713',
    services: ['Home Repairs', 'Installations', 'Maintenance'],
    tags: ['Plumbing', 'Electrical', 'Carpentry'],
    description: 'Expert handyman services for all your home repair and maintenance needs.',
    image: 'https://images.unsplash.com/photo-1621905252507-b35492cc74b4?auto=format&fit=crop&q=80',
    badges: ['Background Check', '5+ Years', 'Insured'],
    profile: {
      id: '3',
      full_name: 'Handyman Heroes',
      phone: '(562) 345-6789',
      area_code: '90713',
      role: 'worker',
      rating: 4.7,
      reviews: 178,
      avatar_url: 'https://images.unsplash.com/photo-1621905252507-b35492cc74b4?auto=format&fit=crop&q=80',
      worker_details: {
        worker_id: '3',
        online: true,
        max_distance_km: 20,
        currently_working: false
      },
      skills: [
        {
          id: '5',
          name: 'General Repairs',
          description: 'Various home repair services including carpentry, plumbing, and electrical',
          experience_level: 'very experienced',
          rate_type: 'fixed',
          rate_amount: 55
        },
        {
          id: '6',
          name: 'Installations',
          description: 'Installation of fixtures, appliances, and home improvements',
          experience_level: 'experienced',
          rate_type: 'varying',
          rate_amount: 45,
          rate_max_amount: 80
        }
      ]
    }
  },
  {
    id: 4,
    name: 'Elite Electric Solutions',
    rating: 4.9,
    reviews: 245,
    distance: 4.1,
    baseRate: 85,
    location: { lat: 33.8254, lng: -118.1134 },
    areaCode: '90815',
    services: ['Electrical Repairs', 'Installations', 'Panel Upgrades'],
    tags: ['Electrical', 'HVAC'],
    description: 'Licensed electricians providing comprehensive electrical services for residential and commercial properties.',
    image: 'https://images.unsplash.com/photo-1657664066042-c59e5f84b7a8?auto=format&fit=crop&q=80',
    badges: ['Top Rated', 'Licensed', 'Insured'],
    profile: {
      id: '4',
      full_name: 'Elite Electric Solutions',
      phone: '(562) 456-7890',
      area_code: '90815',
      role: 'worker',
      rating: 4.9,
      reviews: 245,
      avatar_url: 'https://images.unsplash.com/photo-1657664066042-c59e5f84b7a8?auto=format&fit=crop&q=80',
      worker_details: {
        worker_id: '4',
        online: true,
        max_distance_km: 20,
        currently_working: false
      },
      skills: [
        {
          id: '7',
          name: 'Electrical Repairs',
          description: 'Comprehensive electrical repair services',
          experience_level: 'very experienced',
          rate_type: 'fixed',
          rate_amount: 85
        }
      ]
    }
  },
  {
    id: 5,
    name: 'Perfect Painters',
    rating: 4.6,
    reviews: 167,
    distance: 6.2,
    baseRate: 65,
    location: { lat: 33.8340, lng: -118.0967 },
    areaCode: '90815',
    services: ['Interior Painting', 'Exterior Painting', 'Cabinet Refinishing'],
    tags: ['Painting'],
    description: 'Professional painting services with attention to detail and quality finishes.',
    image: 'https://images.unsplash.com/photo-1589939705384-5185137a7f0f?auto=format&fit=crop&q=80',
    badges: ['Licensed', 'Insured'],
    profile: {
      id: '5',
      full_name: 'Perfect Painters',
      phone: '(562) 567-8901',
      area_code: '90815',
      role: 'worker',
      rating: 4.6,
      reviews: 167,
      avatar_url: 'https://images.unsplash.com/photo-1589939705384-5185137a7f0f?auto=format&fit=crop&q=80',
      worker_details: {
        worker_id: '5',
        online: true,
        max_distance_km: 20,
        currently_working: false
      },
      skills: [
        {
          id: '8',
          name: 'House Painting',
          description: 'Interior and exterior painting services',
          experience_level: 'very experienced',
          rate_type: 'varying',
          rate_amount: 65,
          rate_max_amount: 95
        }
      ]
    }
  },
  {
    id: 6,
    name: 'Pro Plumbing Services',
    rating: 4.8,
    reviews: 198,
    distance: 7.5,
    baseRate: 95,
    location: { lat: 33.8187, lng: -118.1167 },
    areaCode: '90808',
    services: ['Plumbing Repairs', 'Water Heaters', 'Drain Cleaning'],
    tags: ['Plumbing'],
    description: 'Expert plumbing services available 24/7 for all your plumbing needs.',
    image: 'https://images.unsplash.com/photo-1585704032915-c3400ca199e7?auto=format&fit=crop&q=80',
    badges: ['Emergency Service', 'Licensed', 'Insured'],
    profile: {
      id: '6',
      full_name: 'Pro Plumbing Services',
      phone: '(562) 678-9012',
      area_code: '90808',
      role: 'worker',
      rating: 4.8,
      reviews: 198,
      avatar_url: 'https://images.unsplash.com/photo-1585704032915-c3400ca199e7?auto=format&fit=crop&q=80',
      worker_details: {
        worker_id: '6',
        online: true,
        max_distance_km: 20,
        currently_working: false
      },
      skills: [
        {
          id: '9',
          name: 'Plumbing',
          description: '24/7 emergency plumbing services',
          experience_level: 'very experienced',
          rate_type: 'fixed',
          rate_amount: 95
        }
      ]
    }
  },
  {
    id: 7,
    name: 'Kitchen Kings Remodeling',
    rating: 4.9,
    reviews: 167,
    distance: 5.8,
    baseRate: 120,
    location: { lat: 33.8276, lng: -118.1089 },
    areaCode: '90808',
    services: ['Kitchen Remodeling', 'Cabinet Installation', 'Countertop Installation'],
    tags: ['Kitchen Remodel'],
    description: 'Specialized kitchen remodeling services with expert craftsmanship.',
    image: 'https://images.unsplash.com/photo-1556912173-3bb406ef7e77?auto=format&fit=crop&q=80',
    badges: ['Top Rated', 'Licensed', 'Insured'],
    profile: {
      id: '7',
      full_name: 'Kitchen Kings Remodeling',
      phone: '(562) 789-0123',
      area_code: '90808',
      role: 'worker',
      rating: 4.9,
      reviews: 167,
      avatar_url: 'https://images.unsplash.com/photo-1556912173-3bb406ef7e77?auto=format&fit=crop&q=80',
      worker_details: {
        worker_id: '7',
        online: true,
        max_distance_km: 20,
        currently_working: false
      },
      skills: [
        {
          id: '10',
          name: 'Kitchen Remodeling',
          description: 'Full kitchen remodeling and renovation services',
          experience_level: 'very experienced',
          rate_type: 'varying',
          rate_amount: 120,
          rate_max_amount: 200
        }
      ]
    }
  },
  {
    id: 8,
    name: 'Pest Control Pros',
    rating: 4.7,
    reviews: 143,
    distance: 3.9,
    baseRate: 85,
    location: { lat: 33.8312, lng: -118.1023 },
    areaCode: '90808',
    services: ['Pest Control', 'Termite Treatment', 'Rodent Control'],
    tags: ['Pest Control'],
    description: 'Professional pest control services using eco-friendly and pet-safe treatments.',
    image: 'https://res.cloudinary.com/liaison-inc/image/upload/c_fill,f_auto,q_auto,w_1200/services/homeguide/backgrounds/pest-control.jpg',
    badges: ['Eco-Friendly', 'Licensed', 'Pet Safe'],
    profile: {
      id: '8',
      full_name: 'Pest Control Pros',
      phone: '(562) 890-1234',
      area_code: '90808',
      role: 'worker',
      rating: 4.7,
      reviews: 143,
      avatar_url: 'https://res.cloudinary.com/liaison-inc/image/upload/c_fill,f_auto,q_auto,w_1200/services/homeguide/backgrounds/pest-control.jpg',
      worker_details: {
        worker_id: '8',
        online: true,
        max_distance_km: 20,
        currently_working: false
      },
      skills: [
        {
          id: '11',
          name: 'Pest Control',
          description: 'Comprehensive pest control and prevention services',
          experience_level: 'very experienced',
          rate_type: 'fixed',
          rate_amount: 85
        }
      ]
    }
  }
]

const allServices = computed(() => {
  console.log('Worker profiles:', workerProfiles.value)
  return [...localServices, ...workerProfiles.value]
})

const filteredServices = computed(() => {
  return allServices.value.filter(service => {
    // Service type filter
    if (props.serviceType && !service.tags.includes(props.serviceType)) {
      return false
    }

    // Distance filter
    if (selectedDistance.value !== 'any') {
      const maxDistance = parseInt(selectedDistance.value)
      if (service.distance > maxDistance) return false
    }

    // Price filter
    if (selectedPriceRange.value !== 'any') {
      const [min, max] = selectedPriceRange.value.split('-').map(n => parseInt(n) || 151)
      if (service.baseRate < min || (max && service.baseRate > max)) return false
    }

    // Rating filter - skip rating check for new providers
    if (selectedRating.value !== 'any' && service.rating > 0) {
      const minRating = parseFloat(selectedRating.value)
      if (service.rating < minRating) return false
    }

    // Tags filter
    if (selectedTags.value.length > 0) {
      if (!selectedTags.value.some(tag => service.tags.includes(tag))) return false
    }

    // Search query
    if (searchQuery.value) {
      const query = searchQuery.value.toLowerCase()
      return service.name.toLowerCase().includes(query) ||
             service.description.toLowerCase().includes(query) ||
             service.services.some(s => s.toLowerCase().includes(query)) ||
             service.tags.some(t => t.toLowerCase().includes(query))
    }

    return true
  })
})

const totalPages = computed(() => Math.ceil(filteredServices.value.length / itemsPerPage))

const paginatedServices = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage
  const end = start + itemsPerPage
  return filteredServices.value.slice(start, end)
})

const handleBookNow = (service: any) => {
  emit('showProfile', service.profile)
}

const toggleTag = (tag: string) => {
  const index = selectedTags.value.indexOf(tag)
  if (index === -1) {
    selectedTags.value.push(tag)
  } else {
    selectedTags.value.splice(index, 1)
  }
}

const changePage = (page: number) => {
  currentPage.value = page
  window.scrollTo({ top: 0, behavior: 'smooth' })
}

// Google Maps integration
const initMap = async () => {
  const loader = new Loader({
    apiKey: 'AIzaSyBgHRc8-irx37wC4DHM_V-Xo9ElqejSt20',
    version: 'weekly'
  })

  try {
    const google = await loader.load()
    const geocoder = new google.maps.Geocoder()
    
    geocoder.geocode({ address: props.zipCode }, (results, status) => {
      if (status === 'OK' && results && results[0] && mapContainer.value) {
        const location = results[0].geometry.location
        
        map.value = new google.maps.Map(mapContainer.value, {
          center: location,
          zoom: 12
        })

        // Add markers for each service
        paginatedServices.value.forEach(service => {
          new google.maps.Marker({
            position: service.location,
            map: map.value,
            title: service.name
          })
        })
      }
    })
  } catch (error) {
    console.error('Error loading Google Maps:', error)
  }
}

onMounted(() => {
  initMap()
})
</script>

<template>
  <div class="local-services">
    <div class="header">
      <h2>{{ serviceType || 'Services' }} Available in {{ zipCode }}</h2>
      <p class="subtitle">We found {{ filteredServices.length }} trusted service providers in your area</p>
    </div>

    <div class="content-wrapper">
      <!-- Filters sidebar -->
      <div class="filters">
        <div class="search-box">
          <input 
            type="text"
            v-model="searchQuery"
            placeholder="Search services..."
            class="search-input"
          >
        </div>

        <div class="filter-group">
          <h3>Distance</h3>
          <select v-model="selectedDistance">
            <option 
              v-for="option in distances" 
              :key="option.value" 
              :value="option.value"
            >
              {{ option.label }}
            </option>
          </select>
        </div>

        <div class="filter-group">
          <h3>Price Range</h3>
          <select v-model="selectedPriceRange">
            <option 
              v-for="option in priceRanges" 
              :key="option.value" 
              :value="option.value"
            >
              {{ option.label }}
            </option>
          </select>
        </div>

        <div class="filter-group">
          <h3>Rating</h3>
          <select v-model="selectedRating">
            <option 
              v-for="option in ratings" 
              :key="option.value" 
              :value="option.value"
            >
              {{ option.label }}
            </option>
          </select>
        </div>

        <div class="filter-group">
          <h3>Service Types</h3>
          <div class="tags-container">
            <button
              v-for="tag in allTags"
              :key="tag"
              @click="toggleTag(tag)"
              :class="['tag-button', { active: selectedTags.includes(tag) }]"
            >
              {{ tag }}
            </button>
          </div>
        </div>
      </div>

      <div class="main-content">
        <!-- Map view -->
        <div ref="mapContainer" class="map-container"></div>

        <!-- Services list -->
        <div class="services-list">
          <div 
            v-for="service in paginatedServices" 
            :key="service.id" 
            class="service-item"
          >
            <div class="service-image">
              <img :src="service.image" :alt="service.name">
            </div>
            
            <div class="service-details">
              <div class="service-header">
                <h3>{{ service.name }}</h3>
                <div class="badges">
                  <span 
                    v-for="badge in service.badges" 
                    :key="badge" 
                    class="badge"
                  >
                    {{ badge }}
                  </span>
                </div>
              </div>

              <div class="rating" v-if="service.rating > 0">
                <span class="stars">★★★★★</span>
                <span class="rating-text">{{ service.rating }} ({{ service.reviews }} reviews)</span>
              </div>
              <div class="rating new-provider" v-else>
                <span class="new-badge">New Provider</span>
              </div>

              <p class="distance">{{ service.distance }} miles away</p>
              <p class="description">{{ service.description }}</p>

              <div class="services-offered">
                <span 
                  v-for="tag in service.tags" 
                  :key="tag"
                  class="service-tag"
                >
                  {{ tag }}
                </span>
              </div>

              <div class="price-book">
                <div class="price">
                  Starting at <span class="amount">${{ service.baseRate }}/hr</span>
                </div>
                <button class="book-button" @click="handleBookNow(service)">
                  View Profile & Book
                </button>
              </div>
            </div>
          </div>
        </div>

        <!-- Pagination -->
        <div v-if="totalPages > 1" class="pagination">
          <button 
            v-for="page in totalPages" 
            :key="page"
            @click="changePage(page)"
            :class="['page-button', { active: currentPage === page }]"
          >
            {{ page }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.local-services {
  padding: 2rem;
  background-color: #f7fafc;
  min-height: calc(100vh - 200px);
}

.header {
  text-align: center;
  margin-bottom: 2rem;
}

.header h2 {
  font-size: 2rem;
  color: #2d3748;
  margin-bottom: 0.5rem;
}

.subtitle {
  color: #718096;
  font-size: 1.1rem;
}

.content-wrapper {
  display: grid;
  grid-template-columns: 280px 1fr;
  gap: 2rem;
  max-width: 1400px;
  margin: 0 auto;
}

/* Filters */
.filters {
  background: white;
  padding: 1.5rem;
  border-radius: 12px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  height: fit-content;
  position: sticky;
  top: 2rem;
}

.search-box {
  margin-bottom: 1.5rem;
}

.search-input {
  width: 100%;
  padding: 0.75rem;
  border: 1px solid #e2e8f0;
  border-radius: 6px;
  font-size: 1rem;
}

.filter-group {
  margin-bottom: 1.5rem;
}

.filter-group h3 {
  color: #2d3748;
  font-size: 1rem;
  margin-bottom: 0.5rem;
}

.filter-group select {
  width: 100%;
  padding: 0.75rem;
  border: 1px solid #e2e8f0;
  border-radius: 6px;
  font-size: 1rem;
  color: #4a5568;
  background-color: white;
}

.tags-container {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
}

.tag-button {
  background: none;
  border: 1px solid #e2e8f0;
  padding: 0.5rem 1rem;
  border-radius: 20px;
  font-size: 0.875rem;
  color: #4a5568;
  cursor: pointer;
  transition: all 0.2s;
}

.tag-button.active {
  background-color: #4a5568;
  color: white;
  border-color: #4a5568;
}

/* Map */
.map-container {
  height: 400px;
  width: 100%;
  border-radius: 12px;
  margin-bottom: 2rem;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

/* Services List */
.services-list {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.service-item {
  background: white;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  display: flex;
  gap: 1.5rem;
}

.service-image {
  width: 200px;
  flex-shrink: 0;
}

.service-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.service-details {
  padding: 1.5rem;
  flex-grow: 1;
}

.service-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 0.5rem;
}

.service-header h3 {
  font-size: 1.5rem;
  color: #2d3748;
  margin: 0;
}

.badges {
  display: flex;
  gap: 0.5rem;
}

.badge {
  background-color: #ebf4ff;
  color: #4299e1;
  padding: 0.25rem 0.75rem;
  border-radius: 12px;
  font-size: 0.875rem;
  font-weight: 500;
}

.rating {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 0.5rem;
}

.stars {
  color: #f6ad55;
}

.rating-text {
  color: #718096;
}

.new-badge {
  background-color: #9ae6b4;
  color: #276749;
  padding: 0.25rem 0.75rem;
  border-radius: 20px;
  font-weight: 600;
  font-size: 0.9rem;
}

.distance {
  color: #718096;
  font-size: 0.875rem;
  margin-bottom: 0.5rem;
}

.description {
  color: #4a5568;
  margin-bottom: 1rem;
  line-height: 1.5;
}

.services-offered {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
  margin-bottom: 1rem;
}

.service-tag {
  background-color: #f7fafc;
  color: #4a5568;
  padding: 0.25rem 0.75rem;
  border-radius: 12px;
  font-size: 0.875rem;
}

.price-book {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: auto;
}

.price {
  color: #718096;
}

.amount {
  color: #2d3748;
  font-weight: 600;
  font-size: 1.25rem;
}

.book-button {
  background-color: #4a5568;
  color: white;
  border: none;
  padding: 0.75rem 1.5rem;
  border-radius: 6px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s;
}

.book-button:hover {
  background-color: #2d3748;
  transform: translateY(-2px);
}

/* Pagination */
.pagination {
  display: flex;
  justify-content: center;
  gap: 0.5rem;
  margin-top: 2rem;
}

.page-button {
  background: white;
  border: 1px solid #e2e8f0;
  padding: 0.5rem 1rem;
  border-radius: 6px;
  font-size: 1rem;
  color: #4a5568;
  cursor: pointer;
  transition: all 0.2s;
}

.page-button.active {
  background-color: #4a5568;
  color: white;
  border-color: #4a5568;
}

.page-button:hover:not(.active) {
  background-color: #f7fafc;
}

@media (max-width: 1024px) {
  .content-wrapper {
    grid-template-columns: 1fr;
  }

  .filters {
    position: static;
    margin-bottom: 2rem;
  }
}

@media (max-width: 768px) {
  .service-item {
    flex-direction: column;
  }

  .service-image {
    width: 100%;
    height: 200px;
  }

  .price-book {
    flex-direction: column;
    gap: 1rem;
    align-items: stretch;
  }
}
</style>