# /geo-seo - GEO (Generative Engine Optimization) & SEO Resources

**Purpose:** Access GEO and SEO intelligence, tools, and recommended integrations for AI search optimization in Claude Code.

---

## Quick Start

For any GEO/SEO task, Claude should leverage:

1. **Understanding GEO vs SEO** - Traditional search vs AI-generated answers
2. **MCP Servers** - SEO data access via Keywords Everywhere, SERPAPI
3. **GEO Platforms** - Enterprise tracking tools (Profound, AthenaHQ)
4. **Best Practices** - Schema markup, E-E-A-T, entity-based optimization

---

## Part 1: Understanding GEO vs SEO

| Aspect | SEO | GEO |
|--------|-----|-----|
| **Focus** | Traditional search rankings (Google, Bing) | AI-generated answers (ChatGPT, Claude, Perplexity) |
| **Primary Metrics** | Click-through rates, rankings, organic traffic | Citation frequency, AI inclusion, prominence |
| **Query Handling** | Single queries | Chained queries answered within AI |
| **Also Known As** | SEO | AIO, AEO, AIEO, LLM SEO |

**Key Insight:** Proper Schema markup increases AI citation chances by **30-40%**

---

## Part 2: Top GEO Platforms for 2026

### Enterprise Solutions

#### 1. **Profound** (Enterprise Leader)
- **Pricing:** ~$99/month entry, ~$399/month professional
- **Features:** Multi-platform AI engine coverage (10+), Share-of-Voice analytics, SOC 2 Type II certified
- **Best For:** Enterprise-grade AI visibility tracking
- **Website:** https://www.tryprofound.com/

#### 2. **AthenaHQ**
- **Pricing:** $295/month (first month $95 discount)
- **Features:** GEO signal tracking, location-level audits, ChatGPT integration
- **Best For:** Brands needing comprehensive AI search tracking
- **Website:** https://athenahq.ai/

#### 3. **Writesonic GEO**
- **Features:** AI visibility tracking across ChatGPT, Google AI Overviews, Claude, 10+ platforms
- **Tools:** Brand mention monitoring, citation gap analysis, competitor analysis
- **Website:** https://writesonic.com/

### SMB/Budget Options

#### 4. **LLMrefs** (Budget Option)
- **Pricing:** $79/month
- **Features:** Focuses on keyword tracking for LLM SEO
- **Best For:** Cost-effective AI search visibility tracking
- **Website:** https://llmrefs.com/

#### 5. **Hall** (Free)
- **Pricing:** Free
- **Features:** Basic GEO platform tool
- **Website:** https://usehall.com/

---

## Part 3: SEO MCP Servers for Claude Code

### Official MCP Servers Repository
- **GitHub:** https://github.com/modelcontextprotocol/servers
- Contains 450+ official and community MCP servers

### SEO-Specific MCP Servers

#### 1. **Keywords Everywhere MCP Server**
- **GitHub:** https://github.com/hithereiamaliff/mcp-servers
- **Features:** SEO data access, keyword research, volume/CPC data
- **Setup:** Requires `KEYWORDS_EVERYWHERE_API_KEY`

#### 2. **Claude SEO Workflow MCP**
- **Features:** 15+ professional SEO analysis tools
- **APIs Required:** `KEYWORDS_EVERYWHERE_API_KEY`, `SERPAPI_KEY`
- **Source:** https://lobehub.com/mcp/yourusername-seo-workflows-claude

#### 3. **Rampify MCP**
- **Features:** Real-time site audits, Google Search Console integration, AI-powered recommendations
- **GitHub:** https://github.com/rampify-dev/rampify-mcp

#### 4. **SEO Review Tools MCP**
- **Features:** Connects AI tools with SEO Review Tools API
- **Website:** https://www.seoreviewtools.com/seo-review-tools-mcp-server/

### Web Search MCP Servers

**IMPORTANT:** Google Custom Search JSON API is **CLOSED to new customers** as of 2026.

| Server | Features | API Key Required |
|--------|----------|------------------|
| **Brave Search MCP** | Best for general queries, RAG pipelines | Brave Search API key |
| **Web Search MCP** | Free, immediate setup | None |
| **OpenWebSearch MCP** | Multi-engine (Bing, Baidu, CSDN) | None |
| **Fetch MCP** | Raw HTML content extraction | None |

---

## Part 4: GEO Best Practices for 2026

### Schema Markup & Structured Data

**Critical Schema Types for GEO:**

1. **Article** - News and blog content
2. **FAQPage** - Direct question-answer targeting
3. **HowTo** - Step-by-step guides
4. **Organization** - Entity information
5. **Product/Service** - E-commerce and local business

### GEO Optimization Techniques

1. **Entity-Based SEO:** Focus on entities, not just keywords
2. **E-E-A-T Principles:** Experience, Expertise, Authoritativeness, Trustworthiness
3. **Clear Structure:** Use headers, bullet points, and concise language
4. **Direct Answers:** Structure content to answer specific questions
5. **Citation-Worthy Content:** Create authoritative, well-sourced content

### Platform-Specific Optimization

| Platform | Key Strategy |
|----------|--------------|
| **Google AI Overviews** | Schema markup, high E-E-A-T, comprehensive answers |
| **ChatGPT** | Clear explanations, cite sources, entity-focused |
| **Perplexity** | Real-time data, authoritative sources, structured data |
| **Claude** | Technical accuracy, clear reasoning, well-structured content |

---

## Part 5: Claude Code Skills for SEO

### Accessing Skills Marketplaces

1. **Official Plugin Marketplace:** Use `/plugin` command in Claude Code
2. **SkillsMP:** https://skillsmp.com - Community agent skills marketplace
3. **GitHub Collection:** https://github.com/daymade/claude-code-skills (35+ production-ready skills)

### Notable SEO Skills

- **SEO-GEO Skill:** Automated AI search optimization for ChatGPT and other platforms
- **Marketing Website Skills:** For SEO-focused projects
- **Keyword Research Assistant:** Specialized prompts for SEO

---

## Part 6: Quick Start Recommendations

### For Enterprise:
- **Profound** or **AthenaHQ** for comprehensive GEO tracking
- **Schema markup implementation** (30-40% citation boost)

### For SMB/Agency:
- **LLMrefs** ($79/mo) for budget-friendly tracking
- **Keywords Everywhere MCP Server** for keyword research

### For Developers:
- **Brave Search MCP** for web search integration
- **SEO Workflow MCP** for comprehensive SEO analysis
- **Open-source observability tools** (Langfuse, PostHog)

### For Content Optimization:
1. Implement structured data (Schema.org)
2. Follow E-E-A-T principles
3. Create FAQ and HowTo content targeting AI queries
4. Build entity authority through consistent branding

---

## Part 7: Self-Hosted & Open Source Options

### Open Source AI Observability Tools (for tracking AI visibility)

1. **Langfuse** - 19K+ GitHub stars, MIT license, self-hostable
2. **Helicone** - Open-source, monitors usage and failures
3. **Arize Phoenix** - Enterprise ML+LLM observability, OTEL tracing
4. **PostHog** - Open-source with self-hosting capabilities

### Free GEO Resources
- **Hall (usehall.com)**: Free GEO platform tool
- **OpenWebSearch MCP**: No API key required, multi-engine support
- **Web Search MCP**: Free web search capabilities

---

## Part 8: GEO/SEO Task Prompts

Use these prompt patterns for common GEO/SEO tasks:

### Content Optimization
```
"Optimize this content for AI search engines (ChatGPT, Claude, Perplexity)"
"Generate Schema.org markup for this [type of content]"
"Create FAQ content targeting [topic] for AI search inclusion"
```

### Keyword Research
```
"Analyze keyword opportunities for [topic] using Keywords Everywhere data"
"Identify citation gaps for [brand] in AI search results"
"Find long-tail question queries for [industry]"
```

### Technical SEO
```
"Audit this page for AI search optimization"
"Generate structured data for [content type]"
"Review this content against E-E-A-T principles"
```

### Competitor Analysis
```
"Analyze competitor AI search visibility for [keywords]"
"Compare our citations vs competitors in ChatGPT/Claude"
"Identify content gaps for AI search ranking"
```

---

## Sources

### GEO Tools Reviews
- [Best Generative Engine Optimization Tools: 2026 Review](https://visible.seranking.com/blog/best-generative-engine-optimization-tools-2026/)
- [Generative Engine Optimization (GEO): The 2026 Guide](https://llmrefs.com/generative-engine-optimization)
- [6 Best GEO Tools for 2026](https://aiclicks.io/blog/best-generative-optimization-tools)
- [Profound Pricing](https://www.tryprofound.com/pricing)

### SEO & MCP Integration
- [Claude's SEO Workflow MCP Server](https://lobehub.com/mcp/yourusername-seo-workflows-claude)
- [Rampify MCP Server](https://github.com/rampify-dev/rampify-mcp)
- [SEO Review Tools MCP](https://www.seoreviewtools.com/seo-review-tools-mcp-server/)

### Best Practices
- [Schema & NLP Best Practices for AI Search](https://wellows.com/blog/schema-and-nlp-best-practices-for-ai-search/)
- [GEO Best Practices 2026](https://geneo.app/blog/geo-best-practices-ai-search-engines-2025/)
- [AI SEO in 2026](https://www.advisable.com/insights/ai-seo-optimize-for-chatgpt-perplexity-ai-search-2026)
- [Elite SEO & GEO Protocol 2026](https://www.kaizen-seo.com/blog/elite-seo-geo-protocol-2026-get-cited-by-ai-search-210)

### MCP & Web Search
- [MCP Official Servers Repository](https://github.com/modelcontextprotocol/servers)
- [How to add Brave Search to Claude Desktop with MCP](https://brave.com/search/api/guides/use-with-claude-desktop-with-mcp/)
- [The Best MCP Servers for Developers in 2026](https://www.builder.io/blog/best-mcp-servers-2026)

---

*Report compiled February 7, 2026*
