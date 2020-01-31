
# Change Log
All notable changes to this project will be documented in this file.


## [1.0.7] - 2020-01-31

### Added
- **`isPlaying`** field in `PeachCollectorProperties`, for media_seek events
- **`type`**  field in `PeachCollectorContext`
- possibility to add, retrieve and remove custom fields from `PeachCollectorProperties` and `PeachCollectorContext`


## [1.0.6] - 2020-01-24

### Added
- **`playlistID`** and **`inserPosition`** properties in `PeachCollectorProperties`, for media events related to a playlist addition or removal
- `media_playlist_add` and `media_playlist_remove` events helpers

### Changed
- made database saving more secure


## [1.0.5] - 2019-11-22

### Added
- **`shouldCollectAnonymousEvents`** flag, to send events even when an AdvertisingID is not available (and a userID is not defined)

### Changed
- context, properties and metadata are now nullable for media events
- **`unitTesting`** renamed to **`isUnitTesting`**
- framework's deployment target now **10.0** (was 11.0)


## [1.0.4] - 2019-11-20

### Added
- more unit tests

### Changed
- `recommendation_hit` event now only need an **`item_id`** and a **`hit_index`**
- `recommendation_displayed` event doesn't need **`item_displayed`** anymore as the **`items`** array should only contain displayed items

### Fixed
- timestamps are now in milliseconds
- events are now thread safe

## [1.0.3] - 2019-11-8

### Fixed
- timezone value (delta) now in hours

## [1.0.2] - 2019-10-31

### Changed
- Checked *CFBundleDisplayName* before *CFBundleName* to get the client app name

### Fixed
- added missing `hit_index` in context JSON representation
