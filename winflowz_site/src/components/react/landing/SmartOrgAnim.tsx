/** @jsxImportSource react */
import { useState, useEffect } from "react"

const items = [
  {
    label: "Categorize",
    color: "var(--brand-magenta)",
    icon: (
      <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"><path d="M20 20a2 2 0 0 0 2-2V8a2 2 0 0 0-2-2h-7.9a2 2 0 0 1-1.69-.9L9.6 3.9A2 2 0 0 0 7.93 3H4a2 2 0 0 0-2 2v13a2 2 0 0 0 2 2Z"/><path d="M2 10h20"/></svg>
    ),
  },
  {
    label: "Discover",
    color: "var(--brand-cyan)",
    icon: (
      <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.3-4.3"/></svg>
    ),
  },
  {
    label: "Save",
    color: "var(--brand-yellow)",
    icon: (
      <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"><path d="m19 21-7-4-7 4V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2v16z"/></svg>
    ),
  },
]

export function SmartOrgAnim() {
  const [activeStep, setActiveStep] = useState(0)

  useEffect(() => {
    const interval = setInterval(() => {
      setActiveStep((prev) => (prev + 1) % items.length)
    }, 2000)
    return () => clearInterval(interval)
  }, [])

  return (
    <div className="flex items-center gap-3 relative">
      {items.map((item, i) => {
        const isActive = i === activeStep
        return (
          <div
            key={item.label}
            className="flex flex-col items-center gap-1 transition-transform duration-300"
            style={{
              transform: isActive ? "scale(1.1) translateY(-2px)" : "scale(1) translateY(0)",
            }}
          >
            <div
              className="p-2 rounded-lg border transition-all duration-300"
              style={{
                borderColor: isActive ? item.color : "rgb(63 63 70)",
                backgroundColor: isActive ? `${item.color}15` : "rgb(39 39 42)",
                color: isActive ? item.color : "rgb(161 161 170)",
              }}
            >
              {item.icon}
            </div>
            <span
              className="text-[10px] font-medium transition-colors duration-300"
              style={{ color: isActive ? item.color : "rgb(113 113 122)" }}
            >
              {item.label}
            </span>
          </div>
        )
      })}
    </div>
  )
}
