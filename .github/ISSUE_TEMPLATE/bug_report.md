---
name: Bug Report
about: Create a report to help us improve
title: "[BUG] [Component] Brief description of issue"
labels: bug, needs-triage
assignees: ''

---

### BUG REPORT TEMPLATE

## Description

A clear and concise description of what the bug is including:

- Where it occurs (specific module/component)
- Observable behaviors
- Impact on functionality

## Steps to Reproduction

_Exact steps to reproduce the behavior. Number each step:_

1. Start from [specific starting point]
2. Execute command: `...`
3. Navigate to: '...'
4. Observe error at [specific point]
5. Additional step (if needed)

## Expected Behavior

What should normally happen in this scenario, including expected:

- Output results
- System reactions
- User experience flow

## Actual Behavior

Detailed description of observed behavior:

- Specific error messages (verbatim)
- Crash details
- Unexpected outputs
- Performance degradation metrics (if applicable)

## Frequency

- [] Once
- [] Multiple times

## Reproducibility

- [] Always reproducible
- [] Intermittent (approx ___% of tries)
- [] Reproduced _**times out of**_ attempts
- Triggers: [e.g. specific inputs, network conditions, etc.]

## Media Evidence

If applicable, attach:

- [ ] Screenshots
- [ ] Animated GIFs
- [ ] Screen recording
- [ ] Crash logs

## Environment

Complete environment details:

- Device: [e.g. MacBook Pro M1 Max, Pixel 7 Pro]
- OS: [e.g. macOS Ventura 13.4, Android 14, iOS 17]
- Browser: [e.g. Chrome 117, Safari 16.4, Firefox ESR]
- Runtime: [e.g. Node v18.12.1, JRE 11.0.19]
- App Version: [e.g. v2.8.3]
- Commit Hash: [if known]
- Flutter: [version]

## Configuration

Relevant configurations:

- Feature flags enabled: [e.g. experimental_search=true]
- User settings: [e.g. dark_mode=on]
- Sample of relevant config file (mask secrets):

```yaml
# config.yaml excerpt
feature_set: basic
```

## Log Files

Relevant log excerpts (wrap in \`\`\`):

```dart

[Include 10-20 lines before/after error]

```

## Stack Trace

Full crash stack trace (if applicable):

```plaintext
[Paste complete trace]
```

## Additional Context

- First occurrence date: [e.g. 2023-10-15]
- Recent changes in environment: [e.g. upgraded Node.js]
- Workarounds being used (if any)
- Related component dependencies

## Severity Impact

- [ ] Catastrophic (system crash/data loss)
- [ ] High (core feature broken)
- [ ] Moderate (workaround exists)
- [ ] Low (cosmetic/minor)

## Sample Code

Minimal repro code/snippet (if applicable):

```dart
// Sample widget that triggers the issue
BuggyWidget(badParam: true)
```

## Checklist

- [ ] I've searched existing issues
- [ ] I've provided all requested details
- [ ] I've included reproduction assets

---
