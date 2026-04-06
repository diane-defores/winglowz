---
title: "Window Management & Tiling"
description: "Organize your windows efficiently with tiling and Windows window-management tools."
sidebar:
  label: "Tiling"
  order: 7
---

> A well-organized screen means a well-organized mind. Tiling turns your desktop into a structured workspace.

## Why window management matters

How many times a day do you use Alt+Tab to find a lost window? How many times do you resize two windows side by side by hand? Those micro-interruptions break your concentration.

**Tiling** (automatic window layout) solves that problem. Every window has its place, visible and reachable, without overlap.

## FancyZones: the reference on Windows

FancyZones is part of **Microsoft PowerToys**, a set of free Microsoft utilities. It is by far the best tiling solution on Windows.

### Installation

```powershell
winget install Microsoft.PowerToys
```

### Creating your zones

1. Open PowerToys settings > FancyZones
2. Click **Launch layout editor**
3. Choose a template or create a custom layout
4. Define your zones by drawing them on the screen

### Recommended layouts

**For an ultrawide or 27"+ display:**
- 3 columns: main in the center (50%), secondary on the sides (25% each)

**For a standard 24" display:**
- 2 equal columns for side-by-side work
- 1 large + 2 stacked zones for focus with references

**For multiple monitors:**
- Main screen: 2-3 work zones
- Secondary screen: communication + monitoring

### Daily use

| Action | How |
|--------|-----|
| Put a window into a zone | Hold `Shift` while moving the window |
| Change zone with the keyboard | `Win + Ctrl + Alt + Arrow` |
| Switch layouts | Set a shortcut in the settings |

**Tip**: create multiple layouts and switch between them based on what you are doing. One for coding, one for writing, one for communication.

## AquaSnap: improve native snap

If FancyZones feels too complex, AquaSnap is a simpler alternative that improves Windows' native snap behavior.

**What it adds:**
- Snap to corners (quarter screens)
- Magnetic windows that stick together
- Simultaneous resizing of adjacent windows
- Always-on-top windows
- Transparency for inactive windows

## Other tools

| Tool | Approach | Best for |
|------|----------|----------|
| **WindowGrid** | Right-click overlay grid | Precise placement without setup |
| **MaxTo** | Predefined regions per display | Advanced multi-monitor workflows |
| **Divvy** | Fast placement grid | Simplicity, one shortcut |
| **GlazeWM** | True automatic tiling manager | Users coming from Linux (i3/sway) |
| **Komorebi** | Scriptable tiling manager | Power users who want an i3-like setup on Windows |

## What level of window management do you actually need?

The classic mistake is looking for "the best tool" too early. In practice, it is better to choose your **complexity level** first.

### Level 1: native Windows snap

If your need is simply to place two or three windows side by side without thinking, stay with the native system:
- `Win + Left/Right`
- `Win + Z`
- virtual desktops

That is enough for many people. If you have not yet hit the limits of those gestures, there is no reason to add another tool layer.

### Level 2: FancyZones as the default recommendation

As soon as you want repeatable zones, a real screen logic, or multiple layouts depending on context, **FancyZones** becomes the best entry point.

It is our central recommendation because:
- it is stable
- it is maintained
- it is part of PowerToys
- it adds real structure without forcing you to rebuild your entire workstation

### Level 3: intermediate tools for specific needs

If FancyZones does not match your exact need, there are useful alternatives:
- **AquaSnap** if you mainly want to improve native snapping
- **WindowGrid** if you want very precise placement without heavy setup
- **MaxTo** if you want a highly structured multi-monitor workstation

These tools are interesting when your problem is concrete and identified. They are much less interesting if you just want "more power" in the abstract.

### Level 4: real tiling managers for advanced users

If you are coming from Linux, i3, Sway, or Hyprland, you will naturally look at **GlazeWM** or **Komorebi**.

They become relevant if:
- you want a more automatic tiling logic
- you accept configuring your environment
- you can tolerate less-smooth compatibility with some Windows apps

In short:
- **native** if your need is simple
- **FancyZones** for most serious users
- **AquaSnap / WindowGrid / MaxTo** for targeted intermediate cases
- **GlazeWM / Komorebi** only if you genuinely want to import Linux tiling culture into Windows

## Automatic vs. manual tiling

On Linux, tiling window managers (i3, Sway, Hyper) **automatically** manage the position of every window. You open an app, it takes its place. You open a second one, the space splits.

On Windows, that level of automation is harder to achieve. **GlazeWM** and **Komorebi** get close, but they require configuration and can conflict with certain apps.

If you are coming from something like **Hyprland**, it is worth stating clearly: there is no perfect equivalent on Windows. You can recover part of the logic with FancyZones, AquaSnap, GlazeWM, or Komorebi, but not the same level of overall control or the same deep system integration.

**Our recommendation**: start with FancyZones. It is the best balance between power and stability. If you want to go further, test GlazeWM.

## A complete keyboard workflow

The ultimate goal: never touch the mouse to organize your windows. Here is a typical workflow:

1. **Launch an app**: `Alt + Space` (through your launcher) > type the name > Enter
2. **Place the window**: `Win + Ctrl + Alt + Arrow` to send it into a zone
3. **Switch between windows**: `Alt + Tab` or, better, app-specific shortcuts
4. **Change desktops**: `Win + Ctrl + Left/Right`
5. **Maximize/restore**: `Win + Up`

### Native shortcuts to know

| Action | Shortcut |
|--------|----------|
| Snap left / right | `Win + Left/Right` |
| Snap to quarter screen | `Win + Left` then `Win + Up/Down` |
| Maximize | `Win + Up` |
| Minimize | `Win + Down` |
| Minimize all | `Win + D` |
| Move to another monitor | `Win + Shift + Left/Right` |

## Where to start

1. Install **PowerToys** and enable FancyZones
2. Create **2 layouts**: one for focus, one for multitasking
3. Force yourself to use `Shift + drag` for a week
4. Add keyboard shortcuts gradually
5. Once it feels natural, explore GlazeWM if you want to go further

## Official resources

- [Microsoft PowerToys](https://github.com/microsoft/PowerToys) - FancyZones and PowerToys Run in one suite.
- [AquaSnap](https://www.nurgo-software.com/products/aquasnap) - the simpler alternative to native tiling.
- [WindowGrid](https://windowgrid.net/) - precise click-to-grid placement.
- [MaxTo](https://maxto.net/) - predefined regions per display.
- [Divvy](https://mizage.com/divvy/) - grid-based window placement.
- [GlazeWM](https://glazewm.com/) - automatic tiling on Windows, i3-style.
- [Komorebi](https://github.com/LGUG2Z/komorebi) - the scriptable tiling manager for Windows.
