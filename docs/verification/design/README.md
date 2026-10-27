# M02 design artifacts

Native Flutter widget goldens are design references, not device screenshots or app-function evidence. Each image includes the synthetic-preview label. No private media, participant data or external image service was used.

See the [preview harness](../../../design_preview/README.md) and [screen contract](../../SCREEN_DESIGN.md) for layout/state/motion rules. `goldens/` holds 225 generated references (224 matrix cases plus one simulated-keyboard case): ten screens and four recovery states × four viewport sizes × two themes × two text scales, plus the keyboard case. `ARTIFACTS.json` records path, SHA-256, provenance and review status after image review. The baseline checker accepts only PNGs in this exact directory whose hashes match that manifest; new/changed binaries require review.

Human/agent visual inspection is sampled, with exact files listed in the M02 report; automated layout/golden comparison covers all cases. The goldens use SDK Roboto/MaterialIcons on the recorded macOS/Flutter renderer; production uses OS typography and requires native screenshot comparison after M03. There are no real phone screenshots, media-playback results, persistence tests, store assets or user-research findings in this directory.
