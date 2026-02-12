# Qwicka 🔧

A platform for finding local workers like plumbers, electricians, and contractors. This was a group project where we built a service marketplace with a realistic feel using bot workers to populate the platform.

**[Live Demo](https://qwicka-raymenny.vercel.app)** (Deploy this when ready)

---

## What This Does

Basically a local services marketplace. You can browse workers in your area, see their profiles and ratings, and request their services. We also made it so you can sign up as a worker yourself and get requests from people needing help.

The cool part is we added bot workers that make it feel like a real active platform even though it's just a demo. Makes testing way easier and looks legit in demos.

**Main features:**
- Browse local services (plumbers, electricians, contractors, etc.)
- View worker profiles with ratings and reviews
- Request services from workers
- Sign up as a worker and receive requests
- User authentication and profiles
- Bot workers for realistic marketplace feel

---

## My Role

This was a group project. I mainly handled the frontend but also did some backend work. Built most of the UI components and helped with the authentication system.

**What I worked on:**
- Sign-in/authentication pages
- User profile system
- Service browsing interface
- Hero section and landing page
- Connected frontend to backend
- Helped set up the bot worker system

---

## Tech Stack

**Frontend:**
- Vue 3 (Composition API)
- TypeScript for type safety
- Vite for development
- CSS for styling

**What I learned:**
- First time using Vue (came from React)
- TypeScript in a real project
- Working with a team on git (merge conflicts are fun lol)
- Component-based architecture in Vue
- Props and emits in Vue vs React

---

## Project Structure

```
qwicka/
├── src/
│   ├── components/
│   │   ├── HeroSection.vue
│   │   ├── LocalServices.vue
│   │   ├── WorkRequests.vue
│   │   ├── UserProfile.vue
│   │   └── SignIn.vue
│   ├── App.vue
│   └── style.css
├── tsconfig files
└── package.json
```

---

## Features

### For Service Seekers
- Browse available workers by category
- View detailed worker profiles
- See ratings and reviews
- Request services with details
- Track your service requests

### For Workers
- Create worker profile
- Set your services and rates
- Receive service requests
- Manage your availability
- Build reputation through ratings

### Bot System
We added bot workers that:
- Populate the marketplace with realistic profiles
- Have varied ratings and reviews
- Make the platform feel active and established
- Help demonstrate features during demos

---

## What I Learned

**Technical stuff:**
- Vue 3 is pretty different from React but makes sense once you get it
- TypeScript catches so many bugs before they happen
- Working with a team means planning components before building
- Git conflicts are way less scary after doing this project
- Props in Vue feel cleaner than React honestly

**Team stuff:**
- Communicating about component interfaces
- Dividing work so we're not stepping on each other
- Code reviews actually help catch mistakes
- Merging branches without breaking everything

---

## Challenges

**Vue vs React:**
I learned React first, so Vue felt weird at first. The template syntax and different way of handling state took some getting used to. But once I got it, Vue's reactivity system is actually pretty nice.

**TypeScript:**
Adding types to everything felt slow at first, but it saved us from so many runtime errors. Worth it.

**Team coordination:**
Making sure our components worked together without constantly breaking each other's code. We got better at this as we went.

**Bot system:**
Making the bots feel realistic without overdoing it. Had to balance having enough content to feel real but not so much it's obviously fake.

---

## Running It Locally

```bash
# Clone it
git clone https://github.com/Raymenny/qwicka.git
cd qwicka

# Install
npm install

# Run
npm run dev
```

Open `http://localhost:5173`

---

## Future Ideas

If we had more time:
- Actually deploy it with a real backend
- Add real-time chat between users and workers
- Payment integration
- Map view of nearby workers
- Mobile app version
- More worker categories
- Actual scheduling system
- Reviews and ratings that persist

---

## Screenshots

### Landing Page
![Hero Section](./screenshots/hero.png)

### Browse Services
![Services](./screenshots/services.png)

### Worker Profile
![Profile](./screenshots/profile.png)

### Sign In
![Sign In](./screenshots/signin.png)

---

## Team Project

Built this as a group project to learn Vue and work on something more complex than solo projects. Good experience working with others and managing a shared codebase.

---

## Connect With Me

**Ivan Munguia**
- LinkedIn: [linkedin.com/in/ivan-munguia-283a96271](https://www.linkedin.com/in/ivan-munguia-283a96271)
- GitHub: [@Raymenny](https://github.com/Raymenny)

Looking for internships in software development!

---

## License

MIT

---

Built this to learn Vue and team development. Not actually deployed but works locally - check it out if you want to see Vue 3 + TypeScript in action.
