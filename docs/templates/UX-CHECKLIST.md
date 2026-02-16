# UX Checklist

Use this checklist to verify user experience quality before merging features. Focus on usability, accessibility, and user workflow validation.

---

## How to Use This Checklist

1. **Complete during Phase 6.2: UX Review** of the /feature-dev workflow
2. **Test with real users** when possible
3. **Verify each category** applicable to your feature
4. **Document UX decisions** for future reference

---

## User Workflow Validation

### Task Completion

| Check | Status | Notes |
|-------|--------|-------|
| User can complete primary task without confusion | [ ] | |
| Steps are logical and predictable | [ ] | |
| Clear call-to-action for each action | [ ] | |
| Progress indicators for multi-step workflows | [ ] | |
| Clear confirmation after destructive actions | [ ] | |

### Navigation

| Check | Status | Notes |
|-------|--------|-------|
| Back/cancel available where appropriate | [ ] | |
| User knows where they are in the app | [ ] | |
- Easy to return to previous state | [ ] | |
| Breadcrumbs or trail for deep navigation | [ ] | |
| Keyboard shortcuts documented (if applicable) | [ ] | |

---

## Error Message Clarity

### Error Messages Must Be

| Check | Status | Notes |
|-------|--------|-------|
| Written in plain language (no technical jargon) | [ ] | |
| Specific about what went wrong | [ ] | |
- Actionable (tells user how to fix) | [ ] | |
| Appropriately styled (visible, not dismissible) | [ ] | |

### Error Message Examples

| Scenario | Bad | Good |
|----------|-----|-------|
| Invalid email | "Error 400" | "Please enter a valid email address (e.g., user@example.com)" |
| Network failure | "Network error" | "Couldn't connect. Please check your internet and try again." |
| Password mismatch | "Mismatch" | "Passwords don't match. Please try again." |

### Form Validation

| Check | Status | Notes |
|-------|--------|-------|
| Real-time validation feedback | [ ] | |
| Error messages appear near the error | [ ] | |
| Success confirmation after submission | [ ] | |
| Disabled submit button until valid (or clear error on submit) | [ ] | |
| Required fields clearly marked | [ ] | |

---

## Accessibility (WCAG 2.1 AA)

### Visual Accessibility

| Check | Status | Notes |
|-------|--------|-------|
| Color contrast ratio >= 4.5:1 for normal text | [ ] | |
| Color contrast ratio >= 3:1 for large text | [ ] | |
- Not dependent on color alone to convey information | [ ] | |
| Text can be resized up to 200% without loss of content | [ ] | |

### Keyboard Accessibility

| Check | Status | Notes |
|-------|--------|-------|
| All functionality available via keyboard | [ ] | |
- Visible focus indicator on all interactive elements | [ ] | |
| Logical tab order | [ ] | |
| Skip to main content link (for long pages) | [ ] | |
| No keyboard traps | [ ] | |

### Screen Reader Support

| Check | Status | Notes |
|-------|--------|-------|
| All images have alt text | [ ] | |
- Form inputs have associated labels | [ ] | |
| ARIA labels used for custom components | [ ] | |
| Announcements for dynamic content changes | [ ] | |
| Semantic HTML elements used correctly | [ ] | |

### Cognitive Accessibility

| Check | Status | Notes |
|-------|--------|-------|
| Consistent navigation across pages | [ ] | |
| Clear and simple language | [ ] | |
| Error identification and explanation | [ ] | |
| Sufficient time to respond (no timeouts without warning) | [ ] | |

### Accessibility Testing Tools
- ** axe DevTools** (Chrome/Firefox extension)
- ** WAVE** (WebAIM's accessibility evaluation tool)
- ** Lighthouse** (Chrome built-in)
- ** NVDA / JAWS** (Windows screen reader testing)
- ** VoiceOver** (macOS screen reader testing)

---

## Mobile Responsiveness

### Touch Targets

| Check | Status | Notes |
|-------|--------|-------|
| Buttons/tappable areas >= 44x44 pixels | [ ] | |
- Sufficient spacing between interactive elements | [ ] | |
| No hover-only interactions | [ ] | |

### Layout

| Check | Status | Notes |
|-------|--------|-------|
| Content fits viewport without horizontal scroll | [ ] | |
| Text readable without zooming (16px minimum) | [ ] | |
| Forms easy to complete on mobile | [ ] | |
| No content hidden off-screen | [ ] | |

### Mobile-Specific Considerations

| Check | Status | Notes |
|-------|--------|-------|
| Input type matches expected data (email, tel, number) | [ ] | |
- No hover-dependent content | [ ] | |
| Swipe gestures documented (if used) | [ ] | |
| Optimized images for mobile bandwidth | [ ] | |

---

## Performance Perception

| Check | Status | Notes |
|-------|--------|-------|
| Loading indicator for operations > 300ms | [ ] | |
| Skeleton screens for content loading | [ ] | |
| Optimistic UI updates where appropriate | [ ] | |
| Smooth animations (60fps) | [ ] | |
| No layout shifts (CLS) | [ ] | |

---

## Content Clarity

### Language and Tone

| Check | Status | Notes |
|-------|--------|-------|
| Consistent terminology throughout | [ ] | |
- Active voice preferred | [ ] | |
| Concise labels and headings | [ ] | |
| Instructions written for user's skill level | [ ] | |

### Visual Hierarchy

| Check | Status | Notes |
|-------|--------|-------|
| Clear visual hierarchy (size, weight, color) | [ ] | |
- Most important action most prominent | [ ] | |
| Related content grouped visually | [ ] | |
| Sufficient white space | [ ] | |

---

## Empty States

| Check | Status | Notes |
|-------|--------|-------|
| Friendly, helpful empty state messages | [ ] | |
- Clear call-to-action in empty states | [ ] | |
| Illustrations or icons to guide users | [ ] | |

### Empty State Examples
- **No items**: "You don't have any items yet. Create your first item to get started."
- **Search results**: "No results found for '[query]'. Try different keywords or browse categories."
- **Error state**: "Something went wrong. We're working on it. [Try again]"

---

## Loading States

| Check | Status | Notes |
|-------|--------|-------|
| Loading indicator visible | [ ] | |
- Loading indicator placed where content will appear | [ ] | |
| Estimated time provided for long operations | [ ] | |
| User can cancel long-running operations | [ ] | |

---

## Edge Cases

| Check | Status | Notes |
|-------|--------|-------|
| Long text handled gracefully (truncation, wrapping) | [ ] | |
- Empty lists/data handled | [ ] | |
| Zero state shows guidance | [ ] | |
| Error states provide next steps | [ ] | |
| Offline behavior defined (if applicable) | [ ] | |

---

## Internationalization (if applicable)

| Check | Status | Notes |
|-------|--------|-------|
| Text can expand 30-50% for translations | [ ] | |
- Numbers, dates, currencies localized | [ ] | |
| Text direction support (LTR/RTL) | [ ] | |
| Icons work across cultures | [ ] | |

---

## UX Testing Checklist

### Testing Methods
- [ ] **Usability testing**: Observe users completing tasks
- [ ] **Heuristic evaluation**: Expert review against UX principles
- [ ] **A/B testing**: Compare alternatives (if applicable)
- [ ] **Accessibility audit**: Test with screen reader and keyboard
- [ ] **Cross-browser testing**: Chrome, Firefox, Safari, Edge
- [ ] **Cross-device testing**: Desktop, tablet, mobile

### User Feedback Collection
- [ ] Feedback mechanism available
- [ ] Analytics events tracked for user behavior
- [ ] Error monitoring for UX issues (rage clicks, etc.)

---

## UX Completion Checklist

| Category | Pass/Fail | Notes |
|----------|-----------|-------|
| User Workflow | [ ] | |
| Error Messages | [ ] | |
| Accessibility | [ ] | |
| Mobile Responsiveness | [ ] | |
| Performance Perception | [ ] | |
| Content Clarity | [ ] | |
| Empty/Loading States | [ ] | |
| Edge Cases | [ ] | |

**Overall Assessment**: [ ] Pass / [ ] Fail / [ ] Pass with Conditions

**Conditions/Concerns**:


**Reviewer Approval**: [ ] Approved / [ ] Approved with Changes / [ ] Needs Revision

---

## References

- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [Nielsen Norman Group UX Articles](https://www.nngroup.com/articles/)
- [Material Design Guidelines](https://material.io/design)
- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)

---

*End of UX-CHECKLIST template*
