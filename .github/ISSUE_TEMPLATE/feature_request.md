---
name: Feature Request / Enhancement
about: Suggest an idea for this project
title: "[FEAT] "
labels: enhancement, needs-scoping
assignees: ''

---

### General Feature Request Template  

**Is your feature request related to a problem?**  
Clearly define the pain points or limitations this feature addresses. Focus on:  
- User frustrations (e.g., "Workers struggle with...")  
- Business impacts (e.g., "Causes 30% drop-off in...")  
- Systemic gaps (e.g., "Lacks support for...")  
*Format:*  
- Use bullet points for multi-faceted problems  
- Include metrics where possible (e.g., "40% of users report...")  

---

**Describe the solution you'd like**  
Detail the proposed functionality with specific components:  
1. **Core Mechanism**  
   - Primary interaction flow (e.g., "Users should be able to...")  
   - Key technical components (e.g., "New API endpoint for...")  

2. **User Experience**  
   - UI/UX requirements (e.g., "Modal with form fields for...")  
   - Visual indicators (e.g., "Color-coded status badges...")  

3. **Integration Points**  
   - Data flow (e.g., "Sync with existing X module")  
   - Permission rules (e.g., "Admin-only access to...")  

4. **Edge Case Handling**  
   - Error states (e.g., "Handle offline mode by...")  
   - Validation logic (e.g., "Prevent submission if...")  

*Format:*  
- Numbered sections for major capabilities  
- Sub-bullets for implementation details  

---

**Describe alternatives you've considered**  
List rejected approaches with rationale:  
- **Alternative Solution 1**:  
  Brief description.  
  *Rejected because*: Core drawback (e.g., "Doesn't solve Y issue" or "Too costly for Z reason").  
- **Alternative Solution 2**:  
  ...  

---

**Additional context**  
Provide supporting materials:  
- **Mockups/Diagrams**:  
   Description of visual reference  
- **Technical Notes**:  
  - Dependencies (e.g., "Requires update to X library")  
  - Performance considerations (e.g., "Must handle 1000+ concurrent requests")  
- **User Feedback**:  
  > Quote from user interview/testing  
- **Business Case**:  
  Expected outcomes (e.g., "Target: 20% reduction in churn")  
- **Timeline/Phasing**:  
  Rollout stages (e.g., "Phase 1: Core MVP in Q3")  

---

### Example Application  
*Using template for a "Task Rating Reminder" feature:*  
**Is your feature request related to a problem?**  
- 70% of completed tasks lack ratings, reducing trust signals  
- Workers report 30% income loss from incomplete feedback loops  

**Describe the solution you'd like**  
1. **Automated Reminder System**  
   - Trigger SMS/email 24hrs post-task: "Rate your experience!"  
2. **Escalation Protocol**  
   - Unrated tasks: Auto-send follow-up every 3 days (max 3x)  
3. **Incentivization**  
   - Offer 50 XP for timely ratings  

**Additional context**  
- Mockup: [Link] Notification design  
- Technical: New `rating_reminders` table  

---

> *Pro Tip*:  
> - **Problem Section**: Frame from user perspective  
> - **Solution Section**: Specify "what" not "how" (avoid prescribing code)  
> - **Alternatives**: Show deliberate decision-making  
> - **Context**: Link to research/validation data
---

