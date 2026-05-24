/** @jsxImportSource react */
import { useState, useEffect } from "react"

const shortcuts = [
  { keys: ["Ctrl", "Space"], label: "Quick search" },
  { keys: ["Ctrl", "B"], label: "Bookmark" },
  { keys: ["Ctrl", "Shift", "S"], label: "Save all" },
]

export function KeyboardShortcutAnim() {
  const [pressed, setPressed] = useState(false)
  const [current, setCurrent] = useState(0)

  useEffect(() => {
    const interval = setInterval(() => {
      setPressed(true)
      setTimeout(() => {
        setPressed(false)
        setCurrent((prev) => (prev + 1) % shortcuts.length)
      }, 400)
    }, 3000)
    return () => clearInterval(interval)
  }, [])

  return (
    <div className="flex flex-col gap-2">
      <div className="flex items-center gap-1">
        {shortcuts[current].keys.map((key, i) => (
          <kbd
            key={`${current}-${i}`}
            className="px-2 py-1 text-xs border rounded font-mono transition-all duration-100"
            style={{
              transform: pressed ? "scale(0.92) translateY(2px)" : "scale(1) translateY(0)",
              transitionDelay: `${i * 50}ms`,
              backgroundColor: pressed ? "var(--brand-cyan)" : "rgb(39 39 42)",
              borderColor: pressed ? "var(--brand-cyan)" : "rgb(63 63 70)",
              color: pressed ? "black" : "rgb(212 212 216)",
            }}
          >
            {key}
          </kbd>
        ))}
      </div>
      <span className="text-xs text-zinc-500">
        {shortcuts[current].label}
      </span>
    </div>
  )
}
