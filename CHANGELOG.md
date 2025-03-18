# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](Https://conventionalcommits.org) for commit guidelines.

<!-- changelog -->

## [v1.1.1](https://github.com/ash-project/ash_storage/compare/v1.1.0...v1.1.1) (2025-02-11)




### Bug Fixes:

* pass tenant to load in storage related (#101)

* set relationship context on bulk destroy

## [v1.1.0](https://github.com/ash-project/ash_storage/compare/v1.0.4...v1.1.0) (2025-01-27)




### Features:

* allow passing of arguments to related resources (#93)

### Bug Fixes:

* credo

## [v1.0.4](https://github.com/ash-project/ash_storage/compare/v1.0.3...v1.0.4) (2024-10-07)




### Improvements:

* Add attribute_type to configure stored_at timestamp (#56)

## [v1.0.3](https://github.com/ash-project/ash_storage/compare/v1.0.2...v1.0.3) (2024-08-16)




### Improvements:

* deprecate exclude_upsert_actions, as it had unintended side effects

* add `exclude_upsert_actions` configuration

## [v1.0.2](https://github.com/ash-project/ash_storage/compare/v1.0.1...v1.0.2) (2024-07-11)




### Improvements:

* only add storage attribute if it doesn't already exists

## [v1.0.1](https://github.com/ash-project/ash_storage/compare/v1.0.0...v1.0.1) (2024-06-23)




### Bug Fixes:

* set `ash_storage` on the bulk destroy read query

* ensure `ash_storage: true` is set on all destroy invocations

### Improvements:

* update ash for `atomic_upgrade_with` feature

## [v1.0.0](https://github.com/ash-project/ash_storage/compare/v1.0.0...v1.0.0) (2024-05-10)




### Improvements:

* support `base_filter? true` option

## [v1.0.0](https://github.com/ash-project/ash_storage/compare/v1.0.0...v1.0.0) (2024-05-10)




### Improvements:

* support `base_filter? true` option

## [v1.0.0](https://github.com/ash-project/ash_storage/compare/v1.0.0-rc.1...v1.0.0) (2024-05-10)




### Improvements:

* support `base_filter? true` option

## [v1.0.0](https://github.com/ash-project/ash_storage/compare/v1.0.0-rc.0...v0.1.5)

The changelog is being restarted. See `/documentation/0.x-CHANGELOG.md` in GitHub for previous changelogs.

### Breaking Changes:

- [AshStorage] don't use `base_filter` anymore, allowing for more flexible design

### Improvements:

- [AshStorage] support filters on upsert actions

### Improvements:

- [AshStorage] rewritten to support atomics & bulk actions to take advantage of new bulk actions
- [AshStorage] add `exclude_read_actions` to exclude some actions from filtering stored items
- [AshStorage] add `exclude_destroy_actions` to exclude some actions from being intercepted
