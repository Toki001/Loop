# Loop critical behavioral acceptance scenarios

These are executable-style examples for Codex to translate into unit/widget/integration tests. Scenarios are contractual, not claims that tests have already been written.

## A01 — Fresh offline first use

**Given** Loop is freshly installed with zero database records and airplane mode on  
**When** I start the app, choose Drawing, create a skill, practice for one minute, and save with only a note  
**Then** no sign-in or media permission was needed, the completed session appears on Today and Skill detail, and I can close and reopen Loop without losing it.

## A02 — Timer background exclusion

**Given** a timed session is running  
**When** I practice 90 active seconds, background Loop for 5 minutes, return, practice another 30 seconds, and finish  
**Then** recorded practice is about 120 seconds (within documented timer tolerance), background interval excluded, an interruption indicator is available, and session counted once.

## A03 — Duplicate completion prevention

**Given** a running session  
**When** Finish is tapped twice quickly while saving  
**Then** there is one completed session row, one set of metrics, no orphan media and the UI transitions exactly once.

## A04 — Manual vs timed duration

**Given** the user manually logs 20 minutes of language shadowing  
**When** the session is saved  
**Then** analytics show 20 minutes with manual source provenance and do not claim a live timer measured that duration.

## A05 — Evidence and permission denial

**Given** I deny microphone/photo permission  
**When** I finish a session  
**Then** I can still save notes and metrics, and a clear re-enable path appears if I choose Record later; microphone is never active silently.

## A06 — Then vs Now photos

**Given** the same Drawing skill has two completed sessions with different aspect-ratio photos on different days  
**When** I open Then vs Now and select them  
**Then** both are rendered without stretch, chronological date labels link to the original sessions, and a screen-reader accessible alternative to slider is available.

## A07 — Audio A/B exclusivity

**Given** two Singing audio attachments  
**When** A is playing and I press Play on B  
**Then** A stops before B starts, and exiting/backgrounding stops player resources appropriately.

## A08 — Invalid metric comparison

**Given** one typing metric is WPM and another is errors per minute, or a metric schema version changed unit  
**When** I attempt a direct numeric comparison  
**Then** Loop prevents a false delta and explains incompatibility without showing green 'improvement' arrows.

## A09 — No denominator

**Given** a baseline of zero and a later reading of 10  
**When** progress is calculated  
**Then** absolute change can show +10 but percent change is not displayed or shown as undefined with explanation; UI never displays infinity/NaN.

## A10 — Goal is qualitative

**Given** a goal "perform one song at an open mic"  
**When** no milestone is marked completed  
**Then** Loop does not display an invented 37% goal-completion percentage; goal shows qualitative state.

## A11 — Export/restore integrity

**Given** 5 skills, 30 sessions, three images and two audio files with known hashes  
**When** I export archive, import into clean second device, and complete review  
**Then** session/goal/metric counts and media hashes match the source, references resolve and user content appears on correct sessions.

## A12 — Malicious import safety

**Given** an archive with `../../outside.txt`, duplicated file names, corrupt checksums or unsupported schema  
**When** restore starts  
**Then** it rejects before committing any records or writing outside temp private storage, explains the failure and leaves the original DB/media intact.

## A13 — Data deletion completeness

**Given** Loop holds media, sessions, reminders and thumbnails  
**When** I confirm Clear All Data after reviewing irreversible warning  
**Then** data and private media are cleared, OS notifications canceled and fresh launch is empty; lingering external exported archives and system backups are truthfully excluded from the deletion claim.

## A14 — Large text and accessibility

**Given** a supported small Android or iPhone device with 200% text and reduced motion  
**When** I navigate Today → Skills → Practice → Finish → Progress → Library  
**Then** no content or controls become unreachable, buttons remain accessible, chart data has text equivalents and essential navigation doesn't depend on motion or color.

## A15 — Repeatable data upgrade

**Given** a database fixture from the last released schema containing real sessions with media  
**When** I open the newer application  
**Then** migrations preserve records, newer queries run, no media references are orphaned and the application reports recovery instructions if migration fails without resetting history.

## A16 — Offline search and archived skills

**Given** older sessions and an archived Guitar skill  
**When** I search for an exercise/notes keyword and show archived skills  
**Then** relevant sessions remain retrievable without network, skill archiving doesn't erase history and chart totals respect filters.

## A17 — Local reminders and DST

**Given** a practice reminder on selected weekdays at 19:30  
**When** OS permission is denied, a timezone changes, or the reminder is disabled  
**Then** practice functions regardless, OS notifications aren't duplicated, and schedule delivery is described as best effort.

## A18 — App integrity before publication

**Given** a signed production candidate  
**When** QA inspects a clean install, app metadata/permissions, debug logs, sample data, export sharing and all primary controls  
**Then** there are no fake sessions, TODO buttons, active hidden data transfers, debug credentials, nonfunctional paywalls or inaccurate privacy claims. Human owner explicitly approves publication.

## Mapping to milestones

A01 M03/M05/M07; A02–04 M06; A05 M07/M08; A06–08 M09; A09–10 M10; A11–13 M12; A14 M02/M13; A15 M04/M13; A16 M05/M10; A17 M11; A18 M14/M15.
