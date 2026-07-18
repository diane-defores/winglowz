export const testimonialPeople = [
  {
    name: 'Florin Muresan',
    role: 'CEO & Co-Founder at Squirrly',
    avatarSrc: 'https://winflowz.b-cdn.net/Florin_muresan.jpg',
    title: 'One of the Best Deals I Purchased All Year!',
    quote:
      "I just spent 20 minutes in it and I'm already wondering what I've been doing with my life until now :)) Lots of goodies to improve my work. I love it! I thought I was being productive and that my setup was good and adapted for speed... but I guess I was wrong. There's a lot to go through and it's so well organized. I feel like I've discovered hidden treasure.",
    rating: 5,
    verified: true,
  },
  {
    name: 'Alex',
    role: 'Verified Purchaser',
    avatarSrc: 'https://winflowz.b-cdn.net/alex-dynapictures.png',
    title: 'Actionable Advice and Profound Market Research',
    quote:
      'This product contains lots of useful information, obviously the authors are experts in market analysis and productivity tools. I like the idea of working smarter, not harder, and one can achieve this by applying the right tools for the job. Nice, they even covered how to stay focused, what tools to use to eliminate distractions and not to procrastinate!',
    rating: 5,
    verified: true,
  },
] as const

export const testimonialAvatarSources = testimonialPeople.map(({ avatarSrc }) => avatarSrc)
