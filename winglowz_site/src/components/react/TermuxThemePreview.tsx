/** @jsxImportSource react */
import { useState, useMemo } from "react"
import { termuxThemes, type TermuxTheme } from "../../data/termux-themes"

function generateColorsProperties(theme: TermuxTheme): string {
  const c = theme.colors
  return `# ${theme.name} - Termux color scheme
# Paste this into ~/.termux/colors.properties
# Then run: termux-reload-settings

foreground=${c.foreground}
background=${c.background}
cursor=${c.cursor}

color0=${c.color0}
color1=${c.color1}
color2=${c.color2}
color3=${c.color3}
color4=${c.color4}
color5=${c.color5}
color6=${c.color6}
color7=${c.color7}

color8=${c.color8}
color9=${c.color9}
color10=${c.color10}
color11=${c.color11}
color12=${c.color12}
color13=${c.color13}
color14=${c.color14}
color15=${c.color15}
`
}

function ColorSwatch({ color, label }: { color: string; label: string }) {
  return (
    <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 2 }}>
      <div
        style={{
          width: 28,
          height: 28,
          backgroundColor: color,
          borderRadius: 4,
          border: "1px solid rgba(255,255,255,0.15)",
        }}
        title={`${label}: ${color}`}
      />
      <span style={{ fontSize: 9, opacity: 0.5, fontFamily: "monospace" }}>{label}</span>
    </div>
  )
}

function TerminalPreview({ theme }: { theme: TermuxTheme }) {
  const c = theme.colors
  return (
    <div
      style={{
        backgroundColor: c.background,
        borderRadius: 8,
        overflow: "hidden",
        fontFamily: "'JetBrains Mono', 'Fira Code', 'Cascadia Code', monospace",
        fontSize: 13,
        lineHeight: 1.5,
        border: "1px solid rgba(255,255,255,0.1)",
      }}
    >
      {/* Title bar */}
      <div
        style={{
          backgroundColor: c.color0,
          padding: "6px 12px",
          display: "flex",
          alignItems: "center",
          gap: 8,
        }}
      >
        <div style={{ display: "flex", gap: 6 }}>
          <div style={{ width: 10, height: 10, borderRadius: "50%", backgroundColor: c.color1 }} />
          <div style={{ width: 10, height: 10, borderRadius: "50%", backgroundColor: c.color3 }} />
          <div style={{ width: 10, height: 10, borderRadius: "50%", backgroundColor: c.color2 }} />
        </div>
        <span style={{ color: c.color7, fontSize: 12, opacity: 0.7 }}>Termux</span>
      </div>

      {/* Terminal content */}
      <div style={{ padding: "12px 14px" }}>
        {/* Prompt + command 1 */}
        <div>
          <span style={{ color: c.color4 }}>~/projects/myapp</span>
        </div>
        <div>
          <span style={{ color: c.color5 }}>{"❯ "}</span>
          <span style={{ color: c.foreground }}>git status</span>
        </div>

        {/* Git output */}
        <div style={{ marginTop: 4 }}>
          <span style={{ color: c.foreground }}>On branch </span>
          <span style={{ color: c.color2, fontWeight: "bold" }}>main</span>
        </div>
        <div style={{ color: c.foreground }}>Changes not staged for commit:</div>
        <div>
          <span style={{ color: c.color3 }}>{"  modified: "}</span>
          <span style={{ color: c.foreground }}>src/app.ts</span>
        </div>
        <div>
          <span style={{ color: c.color1 }}>{"  deleted:  "}</span>
          <span style={{ color: c.foreground }}>old-file.js</span>
        </div>
        <div>
          <span style={{ color: c.color2 }}>{"  added:    "}</span>
          <span style={{ color: c.foreground }}>new-feature.ts</span>
        </div>

        {/* Prompt + command 2 */}
        <div style={{ marginTop: 8 }}>
          <span style={{ color: c.color5 }}>{"❯ "}</span>
          <span style={{ color: c.foreground }}>npm run build</span>
        </div>
        <div>
          <span style={{ color: c.color2 }}>{"✓ "}</span>
          <span style={{ color: c.foreground }}>Build successful</span>
        </div>
        <div>
          <span style={{ color: c.color3 }}>{"⚠ "}</span>
          <span style={{ color: c.color3 }}>2 warnings</span>
        </div>
        <div>
          <span style={{ color: c.color1 }}>{"✗ "}</span>
          <span style={{ color: c.color1 }}>Error: missing module &apos;lodash&apos;</span>
        </div>

        {/* Prompt + command 3 */}
        <div style={{ marginTop: 8 }}>
          <span style={{ color: c.color5 }}>{"❯ "}</span>
          <span style={{ color: c.color6 }}>echo</span>
          <span style={{ color: c.color2 }}> &quot;Hello World&quot;</span>
        </div>
        <div style={{ color: c.foreground }}>Hello World</div>

        {/* Blinking cursor */}
        <div style={{ marginTop: 4 }}>
          <span style={{ color: c.color5 }}>{"❯ "}</span>
          <span
            style={{
              backgroundColor: c.cursor,
              width: 8,
              height: 16,
              display: "inline-block",
              animation: "termux-blink 1s step-end infinite",
            }}
          />
        </div>
      </div>
    </div>
  )
}

export default function TermuxThemePreview() {
  const [selectedId, setSelectedId] = useState("nord")
  const [search, setSearch] = useState("")
  const [activeCategory, setActiveCategory] = useState<string>("all")
  const [copied, setCopied] = useState(false)

  const selectedTheme = useMemo(
    () => termuxThemes.find((t) => t.id === selectedId) || termuxThemes[0],
    [selectedId]
  )

  const filteredThemes = useMemo(() => {
    return termuxThemes.filter((t) => {
      const matchesSearch = t.name.toLowerCase().includes(search.toLowerCase())
      const matchesCategory = activeCategory === "all" || t.category === activeCategory
      return matchesSearch && matchesCategory
    })
  }, [search, activeCategory])

  const categories = useMemo(() => {
    const cats = new Map<string, number>()
    cats.set("all", termuxThemes.length)
    for (const t of termuxThemes) {
      cats.set(t.category, (cats.get(t.category) || 0) + 1)
    }
    return cats
  }, [])

  async function handleCopy() {
    const text = generateColorsProperties(selectedTheme)
    try {
      await navigator.clipboard.writeText(text)
      setCopied(true)
      setTimeout(() => setCopied(false), 2000)
    } catch {
      setCopied(true)
      setTimeout(() => setCopied(false), 2000)
    }
  }

  return (
    <div style={{ maxWidth: 900, margin: "0 auto" }}>
      <style>{`
        @keyframes termux-blink {
          50% { opacity: 0; }
        }
        .termux-theme-btn {
          padding: 6px 12px;
          border: 1px solid rgba(255,255,255,0.1);
          border-radius: 6px;
          cursor: pointer;
          font-size: 13px;
          transition: all 0.15s;
          font-family: inherit;
        }
        .termux-theme-btn:hover {
          border-color: rgba(255,255,255,0.3);
        }
        .termux-cat-btn {
          padding: 4px 12px;
          border: none;
          border-radius: 20px;
          cursor: pointer;
          font-size: 12px;
          transition: all 0.15s;
          font-family: inherit;
        }
      `}</style>

      {/* Search + category filters */}
      <div style={{ marginBottom: 16 }}>
        <input
          type="text"
          placeholder="Rechercher un th\u00e8me..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          style={{
            width: "100%",
            padding: "10px 14px",
            borderRadius: 8,
            border: "1px solid rgba(255,255,255,0.15)",
            backgroundColor: "rgba(0,0,0,0.3)",
            color: "inherit",
            fontSize: 14,
            fontFamily: "inherit",
            outline: "none",
            boxSizing: "border-box",
          }}
        />
        <div style={{ display: "flex", gap: 6, marginTop: 8, flexWrap: "wrap" }}>
          {[["all", "Tous"], ["popular", "Populaires"], ["dark", "Sombres"], ["light", "Clairs"]].map(
            ([key, label]) => (
              <button
                key={key}
                className="termux-cat-btn"
                onClick={() => setActiveCategory(key)}
                style={{
                  backgroundColor: activeCategory === key ? "rgba(99,102,241,0.8)" : "rgba(255,255,255,0.08)",
                  color: activeCategory === key ? "#fff" : "inherit",
                }}
              >
                {label} ({categories.get(key) || 0})
              </button>
            )
          )}
        </div>
      </div>

      {/* Layout: theme list + preview */}
      <div style={{ display: "flex", gap: 20, flexDirection: "row", flexWrap: "wrap" }}>
        {/* Theme list */}
        <div
          style={{
            flex: "1 1 250px",
            maxHeight: 520,
            overflowY: "auto",
            display: "flex",
            flexDirection: "column",
            gap: 4,
            paddingRight: 4,
          }}
        >
          {filteredThemes.map((theme) => (
            <button
              key={theme.id}
              className="termux-theme-btn"
              onClick={() => setSelectedId(theme.id)}
              style={{
                display: "flex",
                alignItems: "center",
                gap: 8,
                backgroundColor: selectedId === theme.id ? "rgba(99,102,241,0.15)" : "transparent",
                borderColor: selectedId === theme.id ? "rgba(99,102,241,0.5)" : "rgba(255,255,255,0.08)",
                color: "inherit",
                textAlign: "left",
              }}
            >
              {/* Mini color preview */}
              <div style={{ display: "flex", gap: 2, flexShrink: 0 }}>
                {[theme.colors.background, theme.colors.color1, theme.colors.color2, theme.colors.color4, theme.colors.color5].map(
                  (c, i) => (
                    <div
                      key={i}
                      style={{
                        width: 12,
                        height: 12,
                        borderRadius: 2,
                        backgroundColor: c,
                        border: "1px solid rgba(255,255,255,0.1)",
                      }}
                    />
                  )
                )}
              </div>
              <span style={{ overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>
                {theme.name}
              </span>
            </button>
          ))}
          {filteredThemes.length === 0 && (
            <div style={{ padding: 20, textAlign: "center", opacity: 0.5 }}>Aucun th\u00e8me trouv\u00e9</div>
          )}
        </div>

        {/* Preview panel */}
        <div style={{ flex: "1 1 400px" }}>
          <TerminalPreview theme={selectedTheme} />

          {/* Color palette */}
          <div
            style={{
              marginTop: 12,
              padding: 12,
              borderRadius: 8,
              backgroundColor: "rgba(0,0,0,0.2)",
              border: "1px solid rgba(255,255,255,0.08)",
            }}
          >
            <div style={{ fontSize: 12, opacity: 0.6, marginBottom: 8 }}>Palette</div>
            <div style={{ display: "flex", gap: 6, flexWrap: "wrap", justifyContent: "center" }}>
              <ColorSwatch color={selectedTheme.colors.foreground} label="fg" />
              <ColorSwatch color={selectedTheme.colors.background} label="bg" />
              {Array.from({ length: 16 }, (_, i) => (
                <ColorSwatch
                  key={i}
                  color={selectedTheme.colors[`color${i}` as keyof typeof selectedTheme.colors]}
                  label={`${i}`}
                />
              ))}
            </div>
          </div>

          {/* Copy button */}
          <button
            onClick={handleCopy}
            style={{
              marginTop: 12,
              width: "100%",
              padding: "10px 16px",
              borderRadius: 8,
              border: "none",
              backgroundColor: copied ? "rgba(34,197,94,0.8)" : "rgba(99,102,241,0.8)",
              color: "#fff",
              fontSize: 14,
              cursor: "pointer",
              fontFamily: "inherit",
              fontWeight: 500,
              transition: "background-color 0.2s",
            }}
          >
            {copied ? "Copi\u00e9 !" : `Copier colors.properties \u2014 ${selectedTheme.name}`}
          </button>
        </div>
      </div>
    </div>
  )
}
