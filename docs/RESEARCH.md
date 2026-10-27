# Loop research protocol — M01

**Research state: planned, not conducted.** Zero interviews, usability sessions or beta observations have occurred. Personas below are design hypotheses drawn from PRODUCT, not participant findings. M01 permits proceeding with these explicit assumptions when participants are unavailable. Research is not replaced by agent-generated answers or screenshots.

## Questions and recruitment

Learn how people capture an intention, an attempt, an observation and a next step; which evidence is worth the effort; how irregular practice feels; and whether local ownership/export is understood. Plan 8–12 interviews across at least two disciplines, ideally visual arts, music/voice, language and technical practice. Include irregular learners, people juggling multiple skills, accessibility users and a low-end Android user. Seek five moderated prototype sessions after an interactive M02/M03 surface exists. No participants have been recruited or contacted by the agent; the owner can invite willing volunteers without sharing private recordings.

Use a short voluntary invitation explaining purpose, 30–40 minute duration, optional tasks and the absence of compensation unless explicitly approved. Obtain consent before notes or recordings, permit skipping/withdrawal, and do not collect personal practice media by default. Use adult volunteers initially; any participation by minors requires a separate owner-approved consent/privacy approach. Store only authorized de-identified notes locally, outside Git; no research uploads or third-party analytics. Retention/withdrawal handling must be agreed with the actual participants before collection. This protocol is not a claim of legal approval.

## Interview script

1. Explain the session, voluntary nature and note-taking choice; ask about a recent practice session before showing Loop.
2. “What were you trying to do? How did you decide what to practice?” Ask for a description, not proof or a personal recording.
3. “What told you anything changed?” Probe notes, counts, images, audio and existing tools without suggesting a universal score.
4. “When did you last look back at earlier work? What was hard to find?”
5. “What happens when you miss several days?” Avoid framing irregular practice as failure.
6. “What would you realistically record after a two-minute session? What would feel like work?”
7. “If this stayed only on your phone, what would you expect when replacing or losing the phone?”
8. Show the intention → practice → observation → next-step concept; ask them to explain it back and identify the least useful part.
9. Ask about accessibility/context/device constraints and reminders only if relevant; avoid gathering sensitive health details.
10. Ask permission to quote a de-identified statement, agree retention/withdrawal, thank them and explain next steps. Do not imply skill improvement is proven.

Capture task context, current approach, friction, evidence preference, ownership expectations, stated willingness and contrary evidence. Separate observation, participant quote, interpretation and proposed change. Do not infer retention, demographics or causality from a small qualitative sample.

## Hypothetical personas

| Hypothesis | Context / job | Realistic optional evidence | Design response / risk to test |
|---|---|---|---|
| Occasional learner | Short irregular sessions; wants to resume without guilt | One note or photo; often no numeric measure | Today shows last next-step and easy Start; no streak-loss warning. Test whether even two prompts feel burdensome |
| Cross-skill tinkerer | 2–5 active interests; needs a clear choice and retrievable history | Drawing photo, typing WPM+accuracy, programming result note | Explicit selected skill, per-skill units, archive/filter/search. Test switching cost and incompatible-comparison understanding |
| Deliberate improver | Repeats specific exercises and compares attempts over weeks | Dated audio/image pair or consistent self-entered metric | Stable exercise/metric identity, provenance and Then-vs-Now. Test whether controls make differences understandable without implying objective scoring |

These are roles, not fabricated people. Do not invent ages, success percentages, testimonials, observed behavior or research quotes for them.

## Moderated usability script

Use a fresh empty installation or clearly labeled synthetic design preview. State whether storage, camera/audio and export are real in that tested build. Never present a preview as working persistence. Use consenting participants' own accessibility settings, with no pressure to disclose disability.

| Task | Prompt | Observe / success criterion |
|---|---|---|
| U01 First use | “Create a skill and start practice while offline.” | Skip onboarding, edit name, start without permissions; measure time to Start separately from practice duration; target ≤30s, also report ≤60s threshold, actual taps/confusion |
| U02 Finish | “Finish and save anything useful for next time.” | Optional prompts understood, blank save available, finish-to-save ≤60s target; record attempts, not inferred motivation |
| U03 Repeat | “Return to that skill for another attempt.” | Last next-step found; start within two taps from Today when a current skill/draft exists |
| U04 Denied media | “You don't want microphone access. Keep this session.” | Save note/manual alternatives without permission; no silent recording; retry/settings path understood |
| U05 Compare | “Find two earlier attempts and see what changed.” | Choose same skill/type, dates/source links, A/B exclusivity or non-drag photo mode; ask what comparison does and does not prove |
| U06 Ownership | “Move your journal to another device.” | Find export/restore, explain archive sensitivity and uninstall risk, review counts/collisions and rollback; never delete real data during study |
| U07 Accessibility | Repeat primary flow with large text/reduced motion or screen reader | Reachable controls and comprehensible order; record actual assistive-tech/device and failures |

Collect task completion, errors, help, elapsed time boundaries, quotes with consent and observed confusion. Do not silently add event instrumentation. Interview reports must state actual participants, dates, consenting collection method, device/build and limits. A failed task creates a design issue; it is not edited out of the report.

## Decision and release follow-through

Keep H1–H4 from [ANALYTICS.md](ANALYTICS.md) as hypotheses. Clarify the strict ≤30s Start goal and separately report the one-minute usability threshold; do not include mandatory practice duration in time-to-start. If most participants cannot start within a minute, revise the flow. If >25% of moderated participants abandon the finish flow because of prompts, reconsider burden; report the small sample and raw counts rather than statistical impact.

M02/M13 must carry unresolved research into their review and beta plans. Real participant access is an external input; this document supplies a usable protocol, not completed research. No uplift, retention, crash-free rate or demonstrated skill improvement can be claimed without actual appropriately consented evidence.
