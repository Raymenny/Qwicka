<script setup lang="ts">
import { defineEmits } from 'vue'

const emit = defineEmits(['selectService'])

const services = [
  {
    title: 'Home Maintenance',
    description: 'Complete home care services to keep your living space perfect',
    features: [
      'Regular house cleaning',
      'Appliance repairs & maintenance',
      'Plumbing services',
      'Electrical repairs & installations'
    ]
  },
  {
    title: 'Home Improvement',
    description: 'Transform and enhance your living spaces',
    features: [
      'Interior painting',
      'Flooring installation',
      'Kitchen & bathroom updates',
      'Custom carpentry work'
    ]
  },
  {
    title: 'Outdoor & Landscaping',
    description: 'Professional care for your outdoor spaces',
    features: [
      'Lawn mowing & maintenance',
      'Garden design & care',
      'Tree trimming & removal',
      'Patio & deck services'
    ]
  }
]

const serviceCategories = [
  {
    name: 'Handyperson',
    image: 'https://media.discordapp.net/attachments/481711790129020939/1363241407707615482/Handyperson.png?ex=680550ff&is=6803ff7f&hm=c0bae16f77cdaaa61708d6bc6fe00f44b9060cd29fdab5d107a5beb63a6107c1&=&format=webp&quality=lossless'
  },
  {
    name: 'Landscaping',
    image: 'https://media.discordapp.net/attachments/481711790129020939/1363241408206471218/Landscape.png?ex=680550ff&is=6803ff7f&hm=eea151aa63e97253c68c62e02e8461535b779c156e38a3f4b2f387e208aa46f5&=&format=webp&quality=lossless'
  },
  {
    name: 'Plumbing',
    image: 'https://media.discordapp.net/attachments/481711790129020939/1363241408760250419/Plumbing.png?ex=680550ff&is=6803ff7f&hm=509c21c98d94f952b5cbfdfcdb656640fc207f5c8d41c4a384682c720fe9d423&=&format=webp&quality=lossless'
  },
  {
    name: 'Electrical',
    image: 'https://media.discordapp.net/attachments/481711790129020939/1363241407480856676/Electrical.png?ex=680550ff&is=6803ff7f&hm=eff4f5a80afc343aa73575c9554e58c9cb5a25e16375f2c81cf8d5812431b18d&=&format=webp&quality=lossless'
  },
  {
    name: 'Contractors',
    image: 'https://media.discordapp.net/attachments/481711790129020939/1363241407246237716/Concrete.png?ex=680550ff&is=6803ff7f&hm=4669fbcbed74df8a0a880d432e75820aa849b7753fdfadc4b828cc76df91221f&=&format=webp&quality=lossless'
  },
  {
    name: 'Painting',
    image: 'https://media.discordapp.net/attachments/481711790129020939/1363241408474910840/Painting.png?ex=680550ff&is=6803ff7f&hm=0cfcd017cfe00956cefbc47beb59a3bd55a9720a979ca1f8aa2b5f74dd2175f9&=&format=webp&quality=lossless'
  },
  {
    name: 'Cleaning',
    image: 'https://media.discordapp.net/attachments/481711790129020939/1363241406998777907/Cleaning.png?ex=680550ff&is=6803ff7f&hm=3cd47d3942ae611dd655f0bdd8deecebaf88e331519b13cc62138a77badd3365&=&format=webp&quality=lossless'
  },
  {
    name: 'HVAC',
    image: 'https://media.discordapp.net/attachments/481711790129020939/1363241407938298046/HVAC.png?ex=680550ff&is=6803ff7f&hm=153747f19a235350963c956c1836c04db3e22c40c8bb7650339d875e43aecfdb&=&format=webp&quality=lossless'
  },
  {
    name: 'Windows',
    image: 'https://media.discordapp.net/attachments/481711790129020939/1363241409087410347/Window.png?ex=680550ff&is=6803ff7f&hm=2c60f93ec2898d57b745de5f6df496d7af378972f31bddeb5a81605bb3c65b2b&=&format=webp&quality=lossless'
  }
]

const handleServiceSelect = (service: string) => {
  emit('selectService', service)
}
</script>

<template>
  <section id="services" class="services">
    <div class="service-buttons-container">
      <h2>Popular Services</h2>
      <div class="service-buttons">
        <button 
          v-for="service in serviceCategories"
          :key="service.name"
          @click="handleServiceSelect(service.name)"
          class="service-button"
        >
          <div class="service-button-content">
            <div class="service-image" :style="{ backgroundImage: `url(${service.image})` }"></div>
            <span class="service-name">{{ service.name }}</span>
          </div>
        </button>
      </div>
    </div>

    <h2>Local Services</h2>
    <p class="services-subtitle">Quality home and outdoor services in your neighborhood</p>
    <div class="services-grid">
      <div v-for="service in services" :key="service.title" class="service-card">
        <h3>{{ service.title }}</h3>
        <p class="service-description">{{ service.description }}</p>
        <ul class="service-features">
          <li v-for="feature in service.features" :key="feature">
            {{ feature }}
          </li>
        </ul>
      </div>
    </div>
  </section>
</template>

<style scoped>
.services {
  padding: 6rem 2rem;
  background-color: #f7fafc;
}

.service-buttons-container {
  margin-bottom: 6rem;
  text-align: center;
  position: relative;
}

.service-buttons-container h2 {
  text-align: center;
  color: #2d3748;
  margin-bottom: 2rem;
  font-size: 2.5rem;
  font-weight: 700;
}

.service-buttons {
  display: grid;
  grid-template-columns: repeat(9, 1fr);
  gap: 0.5rem;
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 1rem;
}

.service-button {
  background: none;
  border: none;
  padding: 0;
  cursor: pointer;
  transition: transform 0.2s;
  aspect-ratio: 1;
  width: 100%;
  max-width: 100px;
  margin: 0 auto;
}

.service-button:hover {
  transform: translateY(-4px);
}

.service-button-content {
  position: relative;
  width: 100%;
  height: 100%;
  border-radius: 8px;
  overflow: hidden;
}

.service-image {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-size: cover;
  background-position: center;
  transition: transform 0.3s;
}

.service-button:hover .service-image {
  transform: scale(1.1);
}

.service-name {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  padding: 0.375rem;
  background: linear-gradient(transparent, rgba(0, 0, 0, 0.7));
  color: white;
  font-weight: 600;
  text-align: center;
  font-size: 0.75rem;
}

h2 {
  text-align: center;
  color: #2d3748;
  margin-bottom: 1rem;
  font-size: 2.5rem;
  font-weight: 700;
}

.services-subtitle {
  text-align: center;
  color: #718096;
  margin-bottom: 3rem;
  font-size: 1.1rem;
}

.services-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 2rem;
  max-width: 1200px;
  margin: 0 auto;
}

.service-card {
  padding: 2rem;
  background-color: white;
  border-radius: 12px;
  text-align: left;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  transition: transform 0.2s;
}

.service-card:hover {
  transform: translateY(-4px);
}

.service-card h3 {
  color: #2d3748;
  margin-bottom: 1rem;
  font-size: 1.5rem;
  font-weight: 600;
}

.service-description {
  color: #718096;
  line-height: 1.6;
  margin-bottom: 1.5rem;
}

.service-features {
  list-style-type: none;
  padding: 0;
  margin: 0;
}

.service-features li {
  color: #4a5568;
  padding: 0.5rem 0;
  border-bottom: 1px solid #edf2f7;
}

.service-features li:last-child {
  border-bottom: none;
}

@media (max-width: 1200px) {
  .service-buttons {
    grid-template-columns: repeat(5, 1fr);
  }
}

@media (max-width: 768px) {
  .service-buttons {
    grid-template-columns: repeat(3, 1fr);
  }
}

@media (max-width: 480px) {
  .service-buttons {
    grid-template-columns: repeat(2, 1fr);
    gap: 0.5rem;
  }

  .service-button {
    max-width: 80px;
  }

  .service-name {
    font-size: 0.7rem;
    padding: 0.25rem;
  }
}
</style>