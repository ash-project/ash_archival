# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](Https://conventionalcommits.org) for commit guidelines.

<!-- changelog -->
## [Unreleased](https://github.com/ash-project/ash_archival/compare/v1.0.0...main)

## [v1.0.0](https://github.com/ash-project/ash_archival/compare/v1.0.0...v1.0.0) (2024-05-10)




### Improvements:

* support `base_filter? true` option

## [v1.0.0](https://github.com/ash-project/ash_archival/compare/v1.0.0...v1.0.0) (2024-05-10)




### Improvements:

* support `base_filter? true` option

## [v1.0.0](https://github.com/ash-project/ash_archival/compare/v1.0.0-rc.1...v1.0.0) (2024-05-10)




### Improvements:

* support `base_filter? true` option

## [v1.0.0](https://github.com/ash-project/ash_archival/compare/v1.0.0-rc.0...v0.1.5)

The changelog is being restarted. See `/documentation/0.x-CHANGELOG.md` in GitHub for previous changelogs.

### Breaking Changes:

- [AshArchival] don't use `base_filter` anymore, allowing for more flexible design

### Improvements:

- [AshArchival] support filters on upsert actions

### Improvements:

- [AshArchival] rewritten to support atomics & bulk actions to take advantage of new bulk actions
- [AshArchival] add `exclude_read_actions` to exclude some actions from filtering archived items
- [AshArchival] add `exclude_destroy_actions` to exclude some actions from being intercepted
