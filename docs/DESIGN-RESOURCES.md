# Design Resources Reference

**Purpose:** Quick reference for UI/UX design work in Claude Code projects.

---

## Built-in Vision Capabilities

Claude Code has native vision for UI/UX work:

| Capability | Usage |
|------------|-------|
| Screenshot Analysis | Attach any UI screenshot for analysis |
| Mockup to Code | Convert visual designs to production code |
| Visual Debugging | CSS inspection, layout review |
| Design System Extraction | Extract patterns from images |

**Example Prompts:**
- "Analyze this screenshot and extract the color palette"
- "Convert this UI mockup to React + Tailwind"
- "Review this design against accessibility guidelines"

---

## Color & Typography

### Getting Color Palettes
```
"Suggest a color palette for [type of app, e.g., healthcare dashboard]"
"Analyze the accessibility of this color scheme"
"Generate a monochromatic palette with accent color"
```

### Typography Pairings
```
"Recommend typography pairings for a [context]"
"Suggest fonts for a data-heavy dashboard"
"Recommend a font stack for accessibility"
```

### Accessibility Standards
- WCAG AA requires 4.5:1 contrast for normal text
- WCAG AA requires 3:1 contrast for large text (18pt+)
- WCAG AAA requires 7:1 contrast for normal text

---

## Component Design Patterns

### Shadcn/ui Patterns (Recommended)
- Installation: `npx shadcn@latest init`
- Component philosophy: Copy-paste, fully customizable
- Built on Radix UI primitives
- Tailwind CSS styling

### Common Component Patterns
```
"Design a [component] following shadcn/ui patterns"
"Create a reusable [component] with Tailwind v4"
"Review this component for UX best practices"
```

---

## Layout & Spacing

### Responsive Design
```
"Create a responsive grid layout for [content]"
"Review this layout for mobile-first design"
"Suggest spacing improvements for this page"
```

### Touch Targets (Mobile)
- Minimum size: 44x44 pixels (iOS HIG)
- Recommended: 48x48 pixels (Android Material)
- Spacing between targets: 8px minimum

---

## Accessibility Checklist

### WCAG 2.1 AA Requirements

| Category | Check |
|----------|-------|
| Color | Contrast ratios meet standards |
| Keyboard | All functionality available via keyboard |
| Screen Reader | Proper ARIA labels and roles |
| Forms | Inputs have associated labels |
| Focus | Visible focus indicators |
| Images | Meaningful alt text |
| Errors | Error messages are descriptive and linked to inputs |

### Testing Tools
- axe DevTools (Chrome extension)
- WAVE (web accessibility evaluation tool)
- Lighthouse (built into Chrome)

---

## Design-to-Code Workflow

### From Figma
1. **Figma MCP** - Direct Figma file access
2. Built-in vision - Screenshot analysis
3. Prompt: "Convert this Figma design to React + Tailwind"

### From Screenshot
1. Attach screenshot directly to Claude
2. Prompt: "Analyze this UI and generate production code"
3. Specify: framework, styling approach, component library

### From Design Handoff
1. Use `/ui-ux` for design pattern reference
2. Specify exact requirements (tokens, spacing, colors)
3. Request component extraction

---

## Recommended Stacks

### Modern React
```
Framework: React 19
Styling: Tailwind CSS v4
Components: shadcn/ui
Icons: Lucide React
Fonts: Inter or Geist
```

### Vue 3
```
Framework: Vue 3
Styling: Tailwind CSS v4
Components: Shadcn-vue or Headless UI
Icons: Heroicons or Phosphor
```

### Next.js
```
Framework: Next.js 15
Styling: Tailwind CSS v4
Components: shadcn/ui
Icons: Lucide React
Fonts: next/font (optimized)
```

---

## Common UI Tasks

### Dashboard Layout
```
"Create a dashboard layout with:
- Sidebar navigation (collapsible)
- Top bar with search and user menu
- Main content area with cards
- Responsive design for mobile"
```

### Data Table
```
"Create a data table with:
- Sorting on all columns
- Pagination
- Row selection
- Filter/search
- Responsive design"
```

### Form Design
```
"Create a form with:
- Proper labels and error messages
- Validation feedback
- Accessible error states
- Loading states on submit"
```

### Modal/Dialog
```
"Create a modal dialog with:
- Focus trap
- Escape key to close
- Click outside to close
- Accessibility attributes (ARIA)"
```

---

## Animation Guidelines

### Recommendations
- Keep animations under 300ms for UI feedback
- Use easing functions (ease-out is most natural)
- Respect `prefers-reduced-motion` media query
- Animate transform and opacity (performance)

### Tailwind Animation Utilities
```css
/* Add to tailwind.config.js */
animate-in, fade-in, slide-in-from-bottom
```

---

## Dark Mode

### Implementation Strategy
```javascript
// Tailwind v4 with CSS variables
:root {
  --background: 0 0% 100%;
  --foreground: 222.2 84% 4.9%;
}

.dark {
  --background: 222.2 84% 4.9%;
  --foreground: 210 40% 98%;
}
```

### Best Practices
- Test both modes thoroughly
- Ensure sufficient contrast in both
- Consider system preference (`prefers-color-scheme`)
- Provide manual toggle option

---

## Resources

### Documentation
- [Tailwind CSS](https://tailwindcss.com/docs)
- [shadcn/ui](https://ui.shadcn.com)
- [Radix UI](https://www.radix-ui.com/primitives)
- [Lucide Icons](https://lucide.dev)

### Learning
- [Refactoring UI](https://www.refactoringui.com/) - Design principles for developers
- [UI/UX Pro Max](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill) - Design knowledge base
- [Frontend Design Plugin](https://github.com/anthropics/claude-code) - Official Anthropic

### Inspiration
- [Mobbin](https://mobbin.com) - Mobile app patterns
- [UI Sources](https://uisources.com) - Web app patterns
- [Dribbble](https://dribbble.com) - Creative designs
- [Awwwards](https://www.awwwards.com) - Award-winning sites
