---
name: irb-protocol
description: |
  Draft IRB protocol documents from research descriptions. Covers study purpose,
  procedures, risks/benefits, informed consent, data security, and participant
  selection. Templates for survey, interview, and secondary data studies.
author: BK
version: 1.0.0
date: 2026-02-20
---

# IRB Protocol Drafting

Draft Institutional Review Board (IRB) protocol documents from research
descriptions. Produces structured templates that researchers can customize
for their institution's specific requirements.

**IMPORTANT DISCLAIMER:** Output is a draft template for the researcher to
review and adapt. This is not legal advice. All protocols must be reviewed
and approved by your institution's IRB office before beginning research.

## When to Use This Skill

Trigger when user:
- Says "IRB protocol", "IRB application", "ethics review"
- Asks about "informed consent" form drafting
- Needs a "human subjects protocol" or "ethics application"
- Wants to determine "exempt vs expedited vs full review"
- Says "write my IRB" or "draft protocol"

## Workflow

### Phase 1: Determine Study Type

Use AskUserQuestion to clarify:
1. **Study type:** Survey, interview, experiment, secondary data analysis, mixed methods?
2. **Population:** Adults, minors, vulnerable populations?
3. **Data type:** Anonymous, confidential, identifiable?
4. **Risk level:** Minimal risk or greater than minimal risk?
5. **Institution:** Which IRB? (different institutions have different forms)

### Phase 2: Determine Review Category

| Category | Criteria | Typical Studies |
|----------|----------|----------------|
| **Exempt** | Minimal risk, no identifiers, educational/survey/public data | Anonymous online surveys, analysis of public datasets |
| **Expedited** | Minimal risk, identifiable but not sensitive | Interviews with adults, identifiable survey data |
| **Full Board** | Greater than minimal risk, vulnerable populations, sensitive topics | Studies with minors, prisoners, or topics involving trauma |

### Phase 3: Draft Protocol Sections

#### 3a. Study Information
- Protocol title
- Principal Investigator and co-investigators
- Funding source (if applicable)
- Expected start and end dates

#### 3b. Study Purpose
- Research questions and hypotheses
- Background and significance (brief, 1-2 paragraphs)
- How this study addresses a gap in knowledge

#### 3c. Participant Selection
- Target population and eligibility criteria
- Inclusion and exclusion criteria
- Recruitment methods and materials
- Expected sample size and justification
- Compensation (if any)

#### 3d. Study Procedures
- Step-by-step description of what participants will do
- Duration of participation
- Location (online, in-person, etc.)
- Data collection instruments (surveys, interview guides)

#### 3e. Risks and Benefits
- Potential risks to participants (psychological, social, economic, physical)
- Steps to minimize each risk
- Potential benefits to participants (if any — "none" is acceptable)
- Potential benefits to society/knowledge

#### 3f. Data Security
- How data will be collected (platform, tools)
- Where data will be stored (encrypted, institutional servers, cloud)
- Who will have access to data
- How long data will be retained
- De-identification procedures
- Data destruction plan

#### 3g. Informed Consent
- Consent process (written, verbal, online click-through)
- Key elements to include:
  - Purpose of the study
  - What participation involves
  - Voluntary nature and right to withdraw
  - Risks and benefits
  - Confidentiality protections
  - Contact information for questions

### Phase 4: Generate Templates

Produce:
1. **Protocol document** (main IRB application narrative)
2. **Informed consent form** (participant-facing, plain language)
3. **Recruitment materials** (email/flyer text, if needed)

## Study-Specific Templates

### Survey Research
- Online platform details (Qualtrics, SurveyMonkey, etc.)
- IP address collection settings
- Attention check and bot detection
- Data download and storage procedures

### Interview Studies
- Recording consent (audio/video)
- Transcription procedures (human vs. automated)
- Member checking plans
- Quote approval process

### Secondary Data Analysis
- Data source and access agreement
- De-identification verification
- Data use agreement requirements
- Variables to be analyzed

## Key Principles

- Use plain language — IRB reviewers and participants should both understand
- Be specific about data security (name the encryption, name the platform)
- Address every risk honestly, even if minimal
- Consent forms should be at 8th grade reading level
- When in doubt, err on the side of more protection
- Always note that this is a DRAFT requiring institutional IRB review
