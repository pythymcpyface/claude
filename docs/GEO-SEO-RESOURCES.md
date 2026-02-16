# GEO & SEO Resources Reference

**Purpose:** Quick reference for GEO (Generative Engine Optimization) and SEO work in Claude Code projects.

---

## GEO vs SEO Comparison

| Aspect | SEO | GEO |
|--------|-----|-----|
| **Focus** | Traditional search rankings (Google, Bing) | AI-generated answers (ChatGPT, Claude, Perplexity) |
| **Primary Metrics** | Click-through rates, rankings, organic traffic | Citation frequency, AI inclusion, prominence |
| **Query Handling** | Single queries | Chained queries answered within AI |
| **Also Known As** | SEO | AIO, AEO, AIEO, LLM SEO |

**Key Insight:** Proper Schema markup increases AI citation chances by **30-40%**

---

## GEO Platforms (2026)

### Enterprise Solutions

| Platform | Pricing | Best For | Website |
|----------|---------|----------|---------|
| **Profound** | $99-$399/mo | Enterprise AI visibility tracking | tryprofound.com |
| **AthenaHQ** | $295/mo | Comprehensive AI search tracking | athenahq.ai |
| **Writesonic GEO** | Contact | Multi-platform visibility tracking | writesonic.com |

### SMB/Budget Options

| Platform | Pricing | Best For | Website |
|----------|---------|----------|---------|
| **LLMrefs** | $79/mo | Budget-friendly tracking | llmrefs.com |
| **Hall** | Free | Basic GEO tool | usehall.com |

---

## SEO MCP Servers for Claude Code

| Server | Features | API Required | Source |
|--------|----------|--------------|--------|
| **Keywords Everywhere MCP** | Keyword research, volume/CPC data | `KEYWORDS_EVERYWHERE_API_KEY` | github.com/hithereiamaliff/mcp-servers |
| **SEO Workflow MCP** | 15+ SEO analysis tools | `KEYWORDS_EVERYWHERE_API_KEY`, `SERPAPI_KEY` | lopehub.com/mcp/seo-workflows-claude |
| **Rampify MCP** | Site audits, GSC integration | API key | github.com/rampify-dev/rampify-mcp |
| **SEO Review Tools MCP** | SEO Review Tools API integration | API key | seoreviewtools.com/seo-review-tools-mcp-server |

### Web Search MCP Servers

**IMPORTANT:** Google Custom Search JSON API is **CLOSED to new customers** as of 2026.

| Server | Features | API Required |
|--------|----------|--------------|
| **Brave Search MCP** | General queries, RAG pipelines | Brave Search API key |
| **Web Search MCP** | Free, immediate setup | None |
| **OpenWebSearch MCP** | Multi-engine (Bing, Baidu, CSDN) | None |
| **Fetch MCP** | Raw HTML content extraction | None |

---

## Critical Schema Types for GEO

1. **Article** - News and blog content
2. **FAQPage** - Direct question-answer targeting
3. **HowTo** - Step-by-step guides
4. **Organization** - Entity information
5. **Product/Service** - E-commerce and local business

### Schema Markup Example

```json
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [{
    "@type": "Question",
    "name": "What is GEO?",
    "acceptedAnswer": {
      "@type": "Answer",
      "text": "Generative Engine Optimization is the practice of optimizing content for AI-generated answers."
    }
  }]
}
```

---

## Platform-Specific Optimization

| Platform | Key Strategy |
|----------|--------------|
| **Google AI Overviews** | Schema markup, high E-E-A-T, comprehensive answers |
| **ChatGPT** | Clear explanations, cite sources, entity-focused |
| **Perplexity** | Real-time data, authoritative sources, structured data |
| **Claude** | Technical accuracy, clear reasoning, well-structured content |

---

## GEO Optimization Techniques

1. **Entity-Based SEO** - Focus on entities, not just keywords
2. **E-E-A-T Principles** - Experience, Expertise, Authoritativeness, Trustworthiness
3. **Clear Structure** - Use headers, bullet points, and concise language
4. **Direct Answers** - Structure content to answer specific questions
5. **Citation-Worthy Content** - Create authoritative, well-sourced content

---

## Common GEO/SEO Task Prompts

### Content Optimization
```
"Optimize this content for AI search engines"
"Generate Schema.org markup for this [type]"
"Create FAQ content targeting [topic]"
```

### Keyword Research
```
"Analyze keyword opportunities for [topic]"
"Identify citation gaps for [brand]"
"Find long-tail question queries for [industry]"
```

### Technical SEO
```
"Audit this page for AI search optimization"
"Generate structured data for [content type]"
"Review content against E-E-A-T principles"
```

---

## Quick Start by Use Case

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

---

## Open Source Observability Tools

| Tool | Stars | License | Best For |
|------|-------|---------|----------|
| **Langfuse** | 19K+ | MIT | Self-hosted AI observability |
| **Helicone** | - | Open-source | Usage and failure monitoring |
| **Arize Phoenix** | - | Open-source | Enterprise ML+LLM observability |
| **PostHog** | - | Open-source | Self-hosted analytics |

---

## Resources

### Documentation
- [MCP Official Servers](https://github.com/modelcontextprotocol/servers) - 450+ MCP servers
- [Schema.org](https://schema.org/) - Structured data markup
- [Brave Search API](https://brave.com/search/api/) - Web search integration

### Learning
- [GEO Best Practices 2026](https://geneo.app/blog/geo-best-practices-ai-search-engines-2025/)
- [Schema & NLP for AI Search](https://wellows.com/blog/schema-and-nlp-best-practices-for-ai-search/)
- [AI SEO in 2026](https://www.advisable.com/insights/ai-seo-optimize-for-chatgpt-perplexity-ai-search-2026)

### Tools
- [Profound](https://www.tryprofound.com/) - Enterprise GEO tracking
- [LLMrefs](https://llmrefs.com/) - Budget GEO tracking
- [Keywords Everywhere](https://keywordseverywhere.com/) - Keyword research
