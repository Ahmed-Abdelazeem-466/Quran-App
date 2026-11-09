# Scroll-wheel ayah-range selectors — v1.3.3

Reminder ayah-range start and end controls now open a Cupertino-style scroll wheel matching the reminder time selector. The range screen remains compact: each field shows its localized label and current ayah, and tapping it opens the wheel with the selected item centered.

The start wheel is bounded by ayahs 1 through the selected Surah's final ayah. The end wheel begins at the currently selected start ayah and ends at the Surah's final ayah. If the start is moved beyond the current end, the end is automatically raised to match it, keeping every range valid. Canceling the wheel leaves the field unchanged; confirming updates the selected ayah range and the Arabic Quran preview immediately.

The existing full-range preview and offline notification content remain unchanged. Release version is `1.3.3+8`, signed with the retained v1.3 release certificate for install-over updates.
