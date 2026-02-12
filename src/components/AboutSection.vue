<script setup lang="ts">
// No props or state needed for this static content
</script>

<template>
  <div class="about-container">
    <div class="about-content">
      <h1>About Qwicka</h1>
      
      <section class="about-section">
        <h2>Our Mission</h2>
        <p>Qwicka connects homeowners with trusted local service professionals. We're committed to making home services hassle-free while ensuring quality and reliability.</p>
      </section>

      <section class="about-section">
        <h2>How It Works</h2>
        <div class="process-grid">
          <div class="process-card">
            <h3>1. Search</h3>
            <p>Enter your ZIP code and the service you need to find top-rated professionals in your area.</p>
          </div>
          <div class="process-card">
            <h3>2. Compare</h3>
            <p>View detailed profiles, ratings, and pricing to choose the right professional for your needs.</p>
          </div>
          <div class="process-card">
            <h3>3. Book</h3>
            <p>Schedule your service directly through our platform with our secure booking system.</p>
          </div>
          <div class="process-card">
            <h3>4. Review</h3>
            <p>After service completion, share your experience to help maintain our high-quality standards.</p>
          </div>
        </div>
      </section>

      <section class="about-section">
        <h2>Quality Assurance</h2>
        <div class="trust-points">
          <div class="trust-item">
            <h3>Verified Professionals</h3>
            <p>All service providers undergo thorough background checks and must maintain valid licenses and insurance.</p>
          </div>
          <div class="trust-item">
            <h3>Rating System</h3>
            <p>We enforce a strict 3-star minimum rating requirement. Companies falling below this threshold are automatically suspended until they improve their service quality.</p>
          </div>
          <div class="trust-item">
            <h3>Secure Payments</h3>
            <p>All transactions are processed through our secure payment system, with funds held in escrow until service completion.</p>
          </div>
        </div>
      </section>

      <section class="about-section">
        <h2>For Service Providers</h2>
        <div class="provider-info">
          <h3>Joining Our Platform</h3>
          <p>Service providers can join Qwicka through our verification process:</p>
          <ul>
            <li>Complete business profile and documentation</li>
            <li>Pass background and license verification</li>
            <li>Pay annual membership fee</li>
            <li>Maintain minimum 3-star rating</li>
          </ul>
          <div class="membership-note">
            <p><strong>Membership Fee Structure:</strong></p>
            <ul>
              <li>Basic Listing: $299/year</li>
              <li>Premium Listing: $599/year (includes priority placement and advanced features)</li>
              <li>Enterprise Solutions: Custom pricing for large service providers</li>
            </ul>
          </div>
        </div>
      </section>

      <section class="about-section">
        <h2>Consumer Protection</h2>
        <div class="protection-info">
          <h3>Our Guarantee</h3>
          <p>Every service booked through Qwicka is backed by our satisfaction guarantee:</p>
          <ul>
            <li>Verified reviews from real customers</li>
            <li>Dispute resolution support</li>
            <li>Up to $1,000 property damage protection</li>
            <li>Money-back guarantee if not satisfied</li>
          </ul>
        </div>
      </section>
    </div>
  </div>
</template>

<style scoped>
.about-container {
  min-height: calc(100vh - 200px);
  background-color: #f7fafc;
  padding: 4rem 2rem;
}

.about-content {
  max-width: 1200px;
  margin: 0 auto;
}

h1 {
  font-size: 3rem;
  color: #2d3748;
  margin-bottom: 2rem;
  text-align: center;
  font-weight: 800;
}

.about-section {
  margin-bottom: 4rem;
  background: white;
  padding: 2rem;
  border-radius: 12px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

.about-section h2 {
  color: #2d3748;
  font-size: 2rem;
  margin-bottom: 1.5rem;
  font-weight: 700;
}

.about-section h3 {
  color: #4a5568;
  font-size: 1.5rem;
  margin-bottom: 1rem;
  font-weight: 600;
}

.about-section p {
  color: #4a5568;
  line-height: 1.6;
  margin-bottom: 1rem;
}

.process-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 2rem;
  margin-top: 2rem;
}

.process-card {
  padding: 1.5rem;
  background-color: #f7fafc;
  border-radius: 8px;
  text-align: center;
}

.process-card h3 {
  color: #2d3748;
  margin-bottom: 1rem;
}

.trust-points {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 2rem;
  margin-top: 2rem;
}

.trust-item {
  padding: 1.5rem;
  background-color: #f7fafc;
  border-radius: 8px;
}

.provider-info, .protection-info {
  background-color: #f7fafc;
  padding: 1.5rem;
  border-radius: 8px;
  margin-top: 1rem;
}

.provider-info ul, .protection-info ul {
  list-style-type: disc;
  margin-left: 1.5rem;
  margin-bottom: 1.5rem;
}

.provider-info li, .protection-info li {
  color: #4a5568;
  margin-bottom: 0.5rem;
}

.membership-note {
  margin-top: 1.5rem;
  padding-top: 1.5rem;
  border-top: 1px solid #e2e8f0;
}

.membership-note ul {
  list-style-type: none;
  margin-left: 0;
}

@media (max-width: 768px) {
  .about-container {
    padding: 2rem 1rem;
  }

  h1 {
    font-size: 2.5rem;
  }

  .about-section {
    padding: 1.5rem;
  }

  .process-grid, .trust-points {
    grid-template-columns: 1fr;
  }
}
</style>