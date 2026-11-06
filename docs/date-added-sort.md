# Library addition-date sorting

The library menu contains **並び順** with three choices:

- **ファイル名順**: existing natural filename order (the default).
- **追加日時（新しい順）**: newest additions first.
- **追加日時（古い順）**: oldest additions first.

The choice survives app relaunch. Favorites remain at the top; the selected order
applies within the favorites and non-favorites groups. Search keeps that order.
Starting ordered playback uses the chosen library order, including when restoring
last playback. Changing the view's sort does not interrupt or replace a queue that
is already playing.

## Date definition and fallback

The first scan records the file provider's directory-addition date, falling back
to the file's creation date when it is unavailable. If neither exists, all files
first seen in the same scan receive that scan's discovery time. The dates are
stored locally by standardized file path and survive rescans, metadata enrichment,
app restarts, and temporary file unavailability. Files with equal dates use natural
filename order, then the full path, for a deterministic tie-breaker.

This cannot reconstruct historical addition times for files whose provider has no
usable date metadata. Renaming or moving a file to a new path gives it a new stored
entry. A different creation date identifies a replacement at the same path and records
its new addition date. When a provider exposes no creation date, or a replacement
preserves the exact original creation date, same-path replacements cannot be
distinguished reliably and retain the original recorded date.
No iCloud files or file metadata are modified.

## Verification

`LibrarySortOrderTests` covers ascending/descending order, natural filename order,
ties, missing dates, empty/single-track libraries, favorites grouping, ordered
playback input, and preference persistence. `TrackDateAddedStoreTests` covers
persistence, rescans, first-discovery fallback, newly discovered tracks, independent
folders, canonical paths, replacement detection, and malformed saved values.
`TrackFileDatesTests` covers date priority and real local file metadata reads.
`TrackTests` verifies that
metadata enrichment preserves the addition date.
