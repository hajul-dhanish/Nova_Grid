# Changelog

## [0.2.0] - 2026-01-11

- **Auto-fit Column Widths**: Automatically adjusts column widths based on content using a generic recursive measurement system.
- **Simplified Stacked Headers**: Removed mandatory manual width for `StackedHeader`. It now calculates its width automatically based on spanned columns.
- **Automatic Header Filling**: Gaps in stacked headers are now filled automatically for layout consistency.
- **Improved Layout Stability**: Resolved alignment issues between stacked headers and columns.
- **Footer Scrollability**: Added horizontal scrolling to pagination controls to prevent overflows.

## [0.1.1] - 2025-05-27

- Empty row data cell handled.
- Bug Fixes and minor improvements.

## [0.1.0] - 2025-05-20

- Initial release of `NovaGrid` package.
- Highly customizable Flutter data table component.
- Support for:
  - Custom columns and row cells
  - Pagination with navigation controls
  - Stacked headers (multi-level column headers)
  - Empty state widget support
  - Sortable columns
  - Optional header background color and column spacing
