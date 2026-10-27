# Asset provenance and font records

M02 uses original procedural study artwork and the project's open-loop vector/painter. No stock photo, personal media, participant recording, downloaded illustration or external image-generation service is used. These fixtures are synthetic design references, never real improvement evidence or retail startup data. The Loop name/mark is not a trademark clearance.

Golden fonts are loaded from already installed resources, not copied into Git:

| Resource | Source / observed license | Use and credit |
|---|---|---|
| Roboto Regular/Medium/Bold | Installed Flutter SDK `bin/cache/artifacts/material_fonts/Roboto_LICENSE.txt`: Apache License 2.0 | Read-only test rendering; keep SDK source attribution/license when distributing relevant assets |
| MaterialIcons font/artwork | Installed Flutter SDK `bin/cache/artifacts/material_fonts/MaterialIcons_LICENSE.txt`: Attribution 4.0 International ([CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)) | Icons supplied through the Flutter SDK Material Icons collection, rendered in preview UI; font not copied. Palette/size change for UI; no claim that Loop authored these glyphs |
| Hiragino Sans GB | Existing macOS system font; OS-provided local resource | Read-only CJK golden fallback on the pinned macOS renderer; never redistributed or added to production assets |
| Platform system typography | Existing device/OS resources | Intended production font choice; no custom font package/download introduced |

The actual installed MaterialIcons license differs from Roboto's; do not describe all SDK fonts as Apache-licensed. License-file hashes and rendering context are in [ARTIFACTS.json](verification/design/ARTIFACTS.json). This is a source record, not a completed legal/dependency audit or permission to redistribute OS fonts. M03/M13/M14 must review actual packaged dependencies/notices and store requirements. No legal agreement was accepted for the owner by this work.
