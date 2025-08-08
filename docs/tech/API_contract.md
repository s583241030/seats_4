# API Contract (v1)

## Auth
| Method | Path | Body | Notes |
|--------|------|------|-------|
| POST | /auth/request-magic-link | { email \| phone } | שולח לינק |
| POST | /auth/verify | { token } | מחזיר JWT |

## Synagogues
| POST | /synagogues | { name, nusach, address } | יצירת מוסד |
| PATCH | /synagogues/:id/verify | | ע״י צוות מקום-קבוע |

## Map Editor
| POST | /:sid/sections | { … } |
| POST | /:sid/seats/bulk-upsert | [{ … }] |
| PATCH| /:sid/seats/:id/status | { status } |
| ... | ... | ... |

## Rules
| POST | /:sid/rules | { name, dsl } |
| PATCH| /:sid/rules/:id | { enabled } |

## Assignments
| POST | /:sid/assignments/simulate | { strategy, seed } |
| POST | /:sid/assignments/commit | { run_id } |