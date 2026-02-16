# /ui-ux - UI/UX Design Resources and Skills

**Purpose:** Access design intelligence, patterns, and recommended tools for UI/UX work in Claude Code.

---

## Quick Start

For any UI/UX task, Claude should leverage:

1. **Built-in Vision** - Screenshot analysis, mockup-to-code conversion
2. **UI/UX Patterns** - Design guidelines, color/typography expertise
3. **Recommended Skills** - Specialized design capabilities (if installed)
4. **MCP Integrations** - Figma, design tools (if configured)

---

## Built-in Vision Capabilities

Claude Code has native vision capabilities for UI/UX work:

- **Screenshot Analysis** - Attach any UI screenshot for analysis
- **Mockup to Code** - Convert visual designs to production code
- **Visual Debugging** - CSS inspection, layout review
- **Design System Understanding** - Extract patterns from images

**Usage:**
```
"Analyze this screenshot and extract the color palette"
"Convert this UI mockup to React + Tailwind"
"Review this design against accessibility guidelines"
```

---

## Recommended Skills (Install for Enhanced Capability)

### Priority 1: UI/UX Pro Max
- **GitHub:** [nextlevelbuilder/ui-ux-pro-max-skill](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill)
- **Install:** Add to `~/.claude/skills/`
- **Capabilities:**
  - Searchable design knowledge base
  - UI styles and components library
  - Color palettes and typography pairings
  - Chart types and data visualization
  - UX guidelines and best practices

### Priority 2: Frontend Design Plugin (Official)
- **Source:** [anthropics/claude-code](https://github.com/anthropics/claude-code/blob/main/plugins/frontend-design/skills/frontend-design/SKILL.md)
- **Install:** Via Claude Code plugin marketplace
- **Capabilities:**
  - Production-grade frontend interfaces
  - Bold aesthetic choices
  - High-impact animations
  - Contextual design decisions

### Priority 3: Shadcn UI + Tailwind v4
- **Source:** [smithery.ai](https://smithery.ai/skills/acejou27/shadcn-ui) or [skills.sh](https://skills.sh/jezweb/claude-skills/tailwind-v4-shadcn)
- **Capabilities:**
  - shadcn/ui component expertise
  - Tailwind v4 integration
  - React 19 support
  - TypeScript and Radix UI primitives

### Priority 4: Screenshot-to-Code
- **Source:** [onewave-ai/claude-skills](https://skills.sh/onewave-ai/claude-skills/screenshot-to-code)
- **Capabilities:**
  - Convert UI screenshots to production code
  - Support for HTML/CSS, React, Vue
  - Design pattern detection

---

## MCP Integrations (Design Tools)

### Figma MCP (Top Integration)

**Official:**
- Catalog: [figma.com/mcp-catalog](https://www.figma.com/mcp-catalog/)
- Docs: [code.claude.com/docs/en/mcp](https://code.claude.com/docs/en/mcp)

**Community Implementations:**
- [karthiks3000/figma-mcp-server](https://github.com/karthiks3000/figma-mcp-server)
- [samsen-studio/claude-to-figma](https://lobehub.com/zh/mcp/samsen-studio-claude-to-figma)

**Use Cases:**
- AI-powered design-to-code conversion
- Design system analysis
- Direct Figma file reading from Claude
- 75% reduction in UI development time (reported)

**Tutorials:**
- [Builder.io Guide](https://www.builder.io/blog/claude-code-figma-mcp-server)
- [YouTube: Design to Code](https://www.youtube.com/watch?v=_gdtY2V3Zx8)
- [html.to.design Guide](https://html.to.design/blog/from-claude-to-figma-via-mcp/)

---

## Recommended Stacks

### For Modern React Development
1. **UI/UX Pro Max** - Design intelligence and patterns
2. **Shadcn UI Skill** - Component library expertise
3. **Tailwind v4 Skill** - Styling framework
4. **Figma MCP** - Design tool integration

### For Screenshot-to-Code Workflows
1. **Screenshot-to-Code Skill** - Conversion logic
2. **Frontend Design Plugin** - Polish and refinement
3. **Built-in Vision** - Image analysis

### For Design System Work
1. **Figma MCP** - Design file access
2. **UI/UX Pro Max** - Pattern knowledge
3. **Notion MCP** - Documentation

---

## UI/UX Task Prompts

Use these prompt patterns for common UI/UX tasks:

### Color & Typography
```
"Suggest a color palette for [type of app, e.g., healthcare dashboard]"
"Recommend typography pairings for a [context]"
"Analyze the accessibility of this color scheme"
```

### Component Design
```
"Design a [component] following shadcn/ui patterns"
"Create a reusable [component] with Tailwind v4"
"Review this component for UX best practices"
```

### Layout & Spacing
```
"Create a responsive grid layout for [content]"
"Review this layout for mobile-first design"
"Suggest spacing improvements for this page"
```

### Accessibility
```
"Review this design against WCAG AA standards"
"Check color contrast ratios for this palette"
"Suggest keyboard navigation improvements"
```

### Design-to-Code
```
"Convert this Figma design to React + Tailwind"
"Analyze this screenshot and reproduce the UI"
"Extract the design tokens from this mockup"
```

---

## Learning Resources

### Video Tutorials
- [I Tried Frontend-Design Plugin](https://www.youtube.com/watch?v=DVlHZufvP10)
- [Claude Code + Figma MCP Server](https://www.youtube.com/watch?v=_gdtY2V3Zx8) (51K+ views)
- [The Ultimate Shadcn UI + Claude Code Workflow](https://www.youtube.com/watch?v=qutWPWDlzRw)
- [My 3-Step Claude Skill for Perfect UX Design](https://www.youtube.com/watch?v=nDHXLXLnwlIaY)

### Articles & Guides
- [Improving Frontend Design through Skills](https://claude.com/blog/improving-frontend-design-through-skills) (Official Anthropic)
- [Top 10 Claude Code Plugins to Try in 2026](https://www.firecrawl.dev/blog/best-claude-code-plugins)
- [Best MCP Servers for Developers in 2026](https://www.builder.io/blog/best-mcp-servers-2026)
- [Demystifying Design Systems using Figma's MCP](https://www.designsystemscollective.com/demystifying-design-systems-and-using-figmas-mcp-with-claude-cli-674d1b66468b)

### Community
- [Reddit: Front End UI/UX with Claude Code](https://www.reddit.com/r/ClaudeAI/comments/1prwaow/front_end_uiux_with_claude_code_hours_of_work_to/)
- [Reddit: Struggling to Generate Polished UI](https://www.reddit.com/r/ClaudeAI/comments/1m43nk2/struggling_to_generate_polished_ui_with_claude/)

---

## Plugin Marketplaces

| Marketplace | URL | Focus |
|-------------|-----|-------|
| Claude Plugin Marketplace | [claudemarketplaces.com](https://claudemarketplaces.com/) | General AI tools |
| Build with Claude | [buildwithclaude.com/plugins](https://www.buildwithclaude.com/plugins) | Official directory |
| MCP Market | [mcpmarket.com](https://mcpmarket.com/) | MCP servers catalog |
| Smithery.ai | [smithery.ai/skills](https://smithery.ai/skills) | Skills marketplace |
| Skills.sh | [skills.sh](https://skills.sh/) | Aggregated skills |

---

## Awesome Lists

- [Awesome Claude Skills](https://github.com/travisvn/awesome-claude-skills) - Curated collection
- [Claude Plugin Marketplace (GitHub)]](https://github.com/DennisLiuCk/claude-plugin-marketplace) - Chinese translations
