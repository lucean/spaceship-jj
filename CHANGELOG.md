### v0.46.0 (2026-10-21)

* Render descriptions and bookmark names literally so that `%` and `\` sequences within them can no longer alter the prompt.
* Collect the details for all subsections with a single `jj` invocation, and detect workspaces without running `jj`.
* Add `SPACESHIP_JJ_SNAPSHOT` to control whether the working copy is snapshotted when rendering.
* Mark conflicted bookmarks with `??`, and hide the bookmark rather than showing a bogus position if its distance can't be determined.
* Ignore the user's `ui.color` setting, and fall back to the default if `SPACESHIP_JJ_DESC_MAX_LENGTH` is not a number.
* Only check for an empty working copy when `SPACESHIP_JJ_DESC_EMPTY_SHOW` is enabled.
* Measure the distance to the nearest bookmark along the shortest path, so that merged commits no longer inflate it.
* Show `SPACESHIP_JJ_ERROR` (`?` by default) when `jj` fails within a workspace, rather than hiding the section.
* Don't run `jj` outside of a workspace when a subsection is used on its own.
* Untrack `.DS_Store` and `.idea/`.

### v0.1.0 (2026-03-21)

* Add bookmark details to section. by @lucean in <https://github.com/lucean/spaceship-jj/pull/23>
* Allow the full commit ID to be displayed. by @lucean in <https://github.com/lucean/spaceship-jj/pull/21>
* Truncate description if greater than maximum permitted length by @lucean in <https://github.com/lucean/spaceship-jj/pull/22>

**Full Changelog**: [v0.1.0](https://github.com/lucean/spaceship-jj/compare/v0.0.3...v0.1.0)

### v0.0.3 (2026-03-17)

* Enforce a jj repo check. by @lucean in <https://github.com/lucean/spaceship-jj/pull/24>

**Full Changelog**: [v0.0.3](https://github.com/lucean/spaceship-jj/compare/v0.0.2...v0.0.3)

### v0.0.2 (2026-03-17)

* Added section to show empty working copy. by @lucean in <https://github.com/lucean/spaceship-jj/pull/15>
* Add commit details to section. by @lucean in <https://github.com/lucean/spaceship-jj/pull/16>

**Full Changelog**: [v0.0.2](https://github.com/lucean/spaceship-jj/compare/v0.0.1...v0.0.2)

### v0.0.1 (2026-03-13)

* Initial release

**Full Changelog**: [v0.0.1](https://github.com/lucean/spaceship-jj/commits/v0.0.1)
