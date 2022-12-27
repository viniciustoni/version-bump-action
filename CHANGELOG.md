# Changelog

## v5 - 09/19/2022

- Use `mvn` to detect project version instead of `grep`
- Updated src structure
- Fixed Bumped value is empty
- Using user of workflow initiated to commit

## v4 - 06/16/2021
- Added skip to this action, insert [SKIP BUMP] on commit head (Changeable input commit-skip)
- Added value to check if version got bumped (output `bumped`)
- Added inputs auto-version-bump, auto-version-bump-suffix, auto-version-bump-higher, auto-version-bump-splitter, auto-version-bump-release
	This will automatically bumps version on trigger, additionally with suffix for example 1.0.0-dev1, 1.0.0-dev2
- !Readme update outstanding!

## v3 - 04/10/2021

- Add `version` output
- Refactor to use composite type instead of Dockerfile

## v2 - 01/09/2021

- Use Docker image with dependencies pre-loaded

## v1 - 01/07/2021

- Initial Implementation
