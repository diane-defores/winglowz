/** @jsxImportSource react */
import { useState, useEffect } from "react"

const testimonials = [
  {
    name: "Florin Muresan",
    role: "CEO & Co-Founder at Squirrly",
    title: "One of the Best Deals I Purchased All Year!",
    quote:
      "I just spent 20 minutes in it and I'm already wondering what I've been doing with my life until now :)) Lots of goodies to improve my work. I love it! I thought I was being productive and that my setup was good and adapted for speed... but I guess I was wrong. There's a lot to go through and it's so well organized. I feel like I've discovered hidden treasure.",
    rating: 5,
    verified: true,
  },
  {
    name: "Alex",
    role: "Verified Purchaser",
    title: "Actionable Advice and Profound Market Research",
    quote:
      "This product contains lots of useful information, obviously the authors are experts in market analysis and productivity tools. I like the idea of working smarter, not harder, and one can achieve this by applying the right tools for the job. Nice, they even covered how to stay focused, what tools to use to eliminate distractions and not to procrastinate!",
    rating: 5,
    verified: true,
  },
  {
    name: "HoangV",
    role: "Verified Purchaser",
    title: "Love it!",
    quote:
      "I was skeptical at first. It was not easy to buy truly helpful Notion templates. But I made the right decision. It contains numerous information about various \"handy hacks\" to make me much more productive without having to search too much. I feel lucky that I pulled the trigger — Desktop Enhanced already more than paid off my investment.",
    rating: 5,
    verified: true,
  },
  {
    name: "Digital Nomad",
    role: "Verified Purchaser",
    title: "Must have for Windows user",
    quote:
      "Even if one is a Windows geek, one will find golden nuggets on hacks, shortcuts which save time and fasten your work. Very neatly organized in sections. Already got my money's worth. As the name of the product will definitely enhance the way one will use their Windows OS.",
    rating: 5,
    verified: true,
  },
  {
    name: "g273",
    role: "Verified Purchaser",
    title: "Best ROI ever!!!",
    quote:
      "This list of useful apps and websites will optimize the crap out of your life \"literally\". Thank you for putting this together.",
    rating: 5,
    verified: true,
  },
  {
    name: "lamefusioncake",
    role: "Verified Purchaser",
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
      <div className="relative min-h-[200px]">
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
            <h3 className="text-white font-semibold text-base mb-3">
              &ldquo;{t.title}&rdquo;
            </h3>
          )}
          <p className="text-zinc-400 text-sm italic mb-4 leading-relaxed">
            &ldquo;{t.quote}&rdquo;
          </p>
          <div className="flex items-center justify-center gap-2">
            <div className="w-8 h-8 rounded-full bg-zinc-800 flex items-center justify-center text-xs font-bold text-zinc-300">
              {t.name[0]}
            </div>
            <div className="text-left">
              <p className="text-zinc-300 text-sm font-medium">{t.name}</p>
              <p className="text-zinc-500 text-xs">
                {t.role}
                {t.verified && (
                  <span className="ml-1" style={{ color: "var(--brand-green)" }}>Verified Purchaser</span>
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
                ? "w-6"
                : "w-2 bg-zinc-700 hover:bg-zinc-500"
            }`}
            style={index === current ? { background: "var(--brand-cyan)" } : undefined}
            aria-label={`Go to testimonial ${index + 1}`}
          />
        ))}
      </div>
    </div>
  )
}
