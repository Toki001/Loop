# Security, Privacy and Trust Plan

## 1. Privacy promise and scope

Loop v1 is a **personal offline-first practice journal**. No account. No cloud API. No hidden tracking. Camera, photo library, microphone and notifications are optional, requested only when the user initiates the related feature. All journal content, recordings, images and measurements are private to the device unless the user explicitly exports/shares them. **Do not claim encryption at rest unless tested and evidenced on supported devices**, and distinguish file-based OS protections from app-managed encryption.

## 2. Assets and threats

Protected assets: session reflections, audio of voice/singing, images of people/locations/art, skill notes, imported files, practice schedules, purchased entitlement data (if future), device identifiers (if any), archive copies, local encryption keys. Threats: device loss/unlocked device access, malicious archive/path traversal, third-party media app access, temporary file leakage, unauthorized cloud backup, accidental share, corruption, OS eviction, app uninstall, package supply-chain compromise, data exposure in logs/crash services, user-entered HTML/links, destructive upgrade/migration, screenshots visible in task switcher.

### Minimum controls

- Data directory is app-private; no world-readable files, no open Android external-storage writes, avoid broad storage permission, use scoped pickers.
- Prefer OS protected storage and test iOS Data Protection / Android sandbox+backup configuration. If choosing app-managed SQL encryption, review maintained driver/library, encrypted DB and WAL/journal handling, key rotation/recovery and performance; verify native startup and background behavior. Lack of encrypted media must not be papered over as encryption.
- Never expose absolute paths in UI logs, exported telemetry, share intents beyond desired export artifact.
- Sanitized filename uses random asset ID; verify MIME magic bytes, measured size/dimensions/duration and hash. Restrict inputs, reject link escapes, canonicalize all paths, defend decompression bombs.
- Permission prompts show value context. Denied permission yields working alternate path (manual note); microphone is never hot-mic in background.
- Keep media recording indicator and Stop action obvious. Handle phone calls, headset disconnect, app background, interruptions and audio session cleanup.
- Strip GPS EXIF where practical, preserve original orientation, make transformation explicit. Don't silently upload or transform user work.
- External links open through OS safely, no WebView executing user-generated code. Programming practice attachments are inert text or screenshots; do not evaluate submitted code.
- Archive input bounded by compressed/uncompressed limits, file count, path depth, count mismatch and checksum; defend ZIP slip and duplicate entry attacks; validate all files before transactional restore.
- Device biometric lock is optional roadmap only; no false sense of protection.
- Avoid user content in analytics, exception reports, screenshot filenames, commit history and CI artifacts.

## 3. Data inventory and handling

| Data | Storage | Retention | Export | Delete |
|---|---|---|---|---|
| Skill metadata/goals | SQLite private app data | until user deletes | yes | yes |
| Session notes/metrics | SQLite | until delete | yes | yes |
| Image/audio evidence | app-private media directory | until delete | yes | yes including thumbnails |
| Reminder schedule | SQLite + OS notification registry | until canceled/deleted | yes schedule intent, not OS internal IDs | yes |
| Diagnostic log (local only) | memory/bounded local, opt-in support sharing | short fixed bound if persisted | no raw user content | clear on request |
| Subscription/telemetry | **not present in v1** | N/A | N/A | N/A |

Store no contacts, location tracking, microphone raw buffers after user stops unless intentionally saved as attachment, advertising ID or persistent cross-app device identity. User choice to share archive moves it to another app/system; disclose recipient controls.

## 4. Export and total deletion

Export must be user-initiated and create versioned, validated archive with clear message: contains sensitive personal notes/media; protect before sharing. Provide optional passphrase mode only after rigorous authenticated encryption/KDF implementation and round-trip/recovery tests; do not invent own crypto. Device temp archives removed on completion/error after share lifecycle is over. Plaintext export must warn that file is unencrypted. Import cannot steal files from unexpected paths, cannot overwrite user history without preview/consent, cannot erase original on failure. Deleting all data requires prominent destructive confirmation; remove DB records, private media, caches, pending drafts and scheduled notifications, with OS backup caveats clearly disclosed. Keep privacy policy precise about external system backups or cloud sharing.

## 5. Store and legal compliance

Publish accessible privacy policy URL and in-app policy. Verify Apple App Privacy disclosure, Privacy Manifest requirements for included SDKs, camera/microphone/photo permission purpose strings, App Tracking Transparency if ever relevant (not v1), Google Play Data safety and permission justifications, target API levels, backup behaviors and subscriptions if introduced. Because the product may handle audio recordings, do not describe data as anonymous or not sensitive casually. Consult applicable jurisdictional rules including the Philippines Data Privacy Act and broader markets where distributed; owner/legal review required, not a claim of legal compliance from a coding agent. Choose appropriate app age rating and content approach for minors.

## 6. Security test matrix

| Failure mode | Required test |
|---|---|
| Permission denied/revoked mid-record | no crash, saved data intact, recorder released, alternate manual flow |
| Disk full on save | transaction failure handled, old data untouched, temp file cleaned |
| Process killed during export | no corrupted final archive promoted; source unaffected |
| Import untrusted ZIP | traversal, symlink, duplicate paths, absurd compression ratio, corrupt checksum rejected |
| Platform backup/restore | app and media consistency, no orphan paths, no sensitive files in public storage |
| Database migration interrupted | recovery and resumability, no silent reset |
| User deletes skill with sessions | explicit scope choice, dependent records/media reconciled |
| Screenshots/logs/crash tooling | no notes/audio/files/secrets in external logs by default |
| Dependency update | license/security scan and basic native smoke test |

## 7. Security release gates

P0: data loss/corruption; unauthorized file access; accidental audio capture; archive traversal; secret leak; high-probability crash on launch — block release. P1: untrusted file hang, data deletion incomplete, permissions lock core user out, large accessible navigation failure — block public release. Every issue tracked with owner, reproducible steps, tested fix and regression test.
