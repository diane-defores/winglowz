/** @jsxImportSource react */
import { useState, useEffect } from "react"

export const testimonials = [
  {
    name: "Florin Muresan",
    role: "CEO & Co-Founder at Squirrly",
    avatarSrc: "https://winflowz.b-cdn.net/Florin_muresan.jpg",
    title: "One of the Best Deals I Purchased All Year!",
    quote:
      "I just spent 20 minutes in it and I'm already wondering what I've been doing with my life until now :)) Lots of goodies to improve my work. I love it! I thought I was being productive and that my setup was good and adapted for speed... but I guess I was wrong. There's a lot to go through and it's so well organized. I feel like I've discovered hidden treasure.",
    rating: 5,
    verified: true,
  },
  {
    name: "Alex",
    role: "Verified Purchaser",
    avatarSrc: "https://winflowz.b-cdn.net/alex-dynapictures.png",
    title: "Actionable Advice and Profound Market Research",
    quote:
      "This product contains lots of useful information, obviously the authors are experts in market analysis and productivity tools. I like the idea of working smarter, not harder, and one can achieve this by applying the right tools for the job. Nice, they even covered how to stay focused, what tools to use to eliminate distractions and not to procrastinate!",
    rating: 5,
    verified: true,
  },
  {
    name: "HoangV",
    role: "Verified Purchaser",
    avatarSrc: "https://images.unsplash.com/photo-1541101767792-f9b2b1c4f127?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&&auto=format&fit=facearea&facepad=3&w=300&h=300&q=80",
    title: "Love it!",
    quote:
      "I was skeptical at first. It was not easy to buy truly helpful Notion templates. But I made the right decision. It contains numerous information about various \"handy hacks\" to make me much more productive without having to search too much. I feel lucky that I pulled the trigger — Desktop Enhanced already more than paid off my investment.",
    rating: 5,
    verified: true,
  },
  {
    name: "Digital Nomad",
    role: "Verified Purchaser",
    avatarSrc: "https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=facearea&facepad=2&w=300&h=300&q=80",
    title: "Must have for Windows user",
    quote:
      "Even if one is a Windows geek, one will find golden nuggets on hacks, shortcuts which save time and fasten your work. Very neatly organized in sections. Already got my money's worth. As the name of the product will definitely enhance the way one will use their Windows OS.",
    rating: 5,
    verified: true,
  },
  {
    name: "g273",
    role: "Verified Purchaser",
    avatarSrc: "/images/headshots/professional-headshot-4.png",
    title: "Best ROI ever!!!",
    quote:
      "This list of useful apps and websites will optimize the crap out of your life \"literally\". Thank you for putting this together.",
    rating: 5,
    verified: true,
  },
  {
    name: "lamefusioncake",
    role: "Verified Purchaser",
    avatarSrc: "/images/headshots/professional-headshot-5.png",
    title: "Useful",
    quote: "Useful. Thank you.",
    rating: 5,
    verified: true,
  },
]

function StarRating({ rating }: { rating: number }) {
  return (
    <div className="flex gap-0.5">
      {Array.from({ length: rating }).map((_, i) => (
        <svg key={i} className="w-4 h-4" viewBox="0 0 24 24" fill="var(--brand-yellow)" stroke="var(--brand-yellow)" strokeWidth="1">
          <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z" />
        </svg>
      ))}
    </div>
  )
}

export function TestimonialCarousel() {
  const [current, setCurrent] = useState(0)
  const [direction, setDirection] = useState<"next" | "prev">("next")
  const [isAnimating, setIsAnimating] = useState(false)

  useEffect(() => {
    const timer = setInterval(() => {
      setDirection("next")
      setIsAnimating(true)
      setTimeout(() => {
        setCurrent((prev) => (prev + 1) % testimonials.length)
        setIsAnimating(false)
      }, 300)
    }, 6000)
    return () => clearInterval(timer)
  }, [])

  const goTo = (index: number) => {
    if (index === current) return
    setDirection(index > current ? "next" : "prev")
    setIsAnimating(true)
    setTimeout(() => {
      setCurrent(index)
      setIsAnimating(false)
    }, 300)
  }

  const t = testimonials[current]

  return (
    <div>
      <div className="relative min-h-52">
        <div
          className="text-center transition-all duration-300"
          style={{
            opacity: isAnimating ? 0 : 1,
            transform: isAnimating
              ? `translateY(${direction === "next" ? "-20px" : "20px"})`
              : "translateY(0)",
          }}
        >
          <div className="flex items-center justify-center gap-1 mb-4">
            <StarRating rating={t.rating} />
          </div>
          {t.title && (
            <h3 className="mb-3 text-base font-semibold text-neutral-950 dark:text-white">
              &ldquo;{t.title}&rdquo;
            </h3>
          )}
          <p className="mb-4 text-sm italic leading-relaxed text-neutral-600 dark:text-zinc-400">
            &ldquo;{t.quote}&rdquo;
          </p>
          <div className="flex items-center justify-center gap-2">
            {t.avatarSrc ? (
              <img
                src={t.avatarSrc}
                alt={`${t.name} avatar`}
                className="h-8 w-8 rounded-full object-cover ring-2 ring-white dark:ring-zinc-900"
                loading="lazy"
              />
            ) : (
              <div className="flex h-8 w-8 items-center justify-center rounded-full bg-neutral-200 text-xs font-bold text-neutral-700 dark:bg-zinc-800 dark:text-zinc-300">
                {t.name[0]}
              </div>
            )}
            <div className="text-left">
              <p className="text-sm font-medium text-neutral-800 dark:text-zinc-300">{t.name}</p>
              <p className="text-xs text-neutral-500 dark:text-zinc-500">
                {t.role}
                {t.verified && (
                  <span className="ml-1 text-green">Verified Purchaser</span>
                )}
              </p>
            </div>
          </div>
        </div>
      </div>

      {/* Dots navigation */}
      <div className="flex items-center justify-center gap-2 mt-6">
        {testimonials.map((_, index) => (
          <button
            key={index}
            onClick={() => goTo(index)}
            className={`h-2 rounded-full transition-all duration-300 ${
              index === current
                ? "w-6 bg-cyan"
                : "w-2 bg-neutral-300 hover:bg-neutral-400 dark:bg-zinc-700 dark:hover:bg-zinc-500"
            }`}
            aria-label={`Go to testimonial ${index + 1}`}
          />
        ))}
      </div>
    </div>
  )
}
