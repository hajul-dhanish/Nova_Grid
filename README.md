# NovaGrid

**NovaGrid** is a highly customizable and modern Flutter table package built to handle everything from simple data lists to advanced tables with stacked headers and pagination.

It is designed for Flutter web and desktop applications where native-feeling, interactive data tables are crucial.

---

## 📄 What It Is

NovaGrid is a flexible and extendable table widget:

- Customizable column definitions
- Auto-fit column widths (content-based scaling)
- Fixed row height for consistent layouts
- Optional pagination
- Support for simplified stacked (merged) headers
- Sortable columns
- Clean, professional UI
- Designed with accessibility and performance in mind

---

## 📝 Basic Usage

```dart
NovaGrid(
  columns: [
    TableColumn(title: 'Name'),
    TableColumn(title: 'Age'),
    TableColumn(title: 'Role'),
  ],
  rows: [
    [Text('Alice'), Text('25'), Text('Engineer')],
    [Text('Bob'), Text('30'), Text('Designer')],
  ],
)
```

---

## 🔢 Example with Auto-fit and Simplified Stacked Headers

```dart
NovaGrid(
  columns: [
    TableColumn(
        title: 'Name',
        autoFit: true, // Automatically expands to fit content
        ),
    TableColumn(title: 'Role', autoFit: true),
    TableColumn(title: 'Country', width: 150),
  ],
  rows: [...],
  showPagination: true,
  rowsPerPage: 10,
  stackedHeaders: [
    StackedHeader(
      startIndex: 0,
      endIndex: 1,
      widget: Center(child: Text('User Details')), // Width is calculated automatically!
    ),
  ],
)
```

---

## 📷 Screenshots

- Basic Table
  ![Basic Table](example/screenshorts/basic_table.png)

- Stacked/Multi-Header Table
  ![Stacked Header Table](example/screenshorts/stacked_header_table.png)

- Pagnated Table
  ![Pagnated Table](example/screenshorts/paginated_table.png)

---

## ✏️ Customization Options

| Property         | Type                   | Description                                   |
| ---------------- | ---------------------- | --------------------------------------------- |
| `columns`        | `List<TableColumn>`    | Defines each column header                    |
| `rows`           | `List<List<Widget>>`   | Defines the cell contents                     |
| `rowHeight`      | `double`               | Height of each row (default: 56)              |
| `rowsPerPage`    | `int?`                 | Optional pagination size                      |
| `showPagination` | `bool`                 | Whether to show pagination controls           |
| `headerColor`    | `Color?`               | Customize header background color             |
| `stackedHeaders` | `List<StackedHeader>?` | Define merged headers across columns          |
| `sortable`       | `bool`                 | Enable column sorting                         |
| `autoFit`        | `bool`                 | (In `TableColumn`) Auto-size based on content |

---

## 🚀 Future Roadmap

- [ ] Sticky headers
- [ ] Export to CSV/Excel
- [ ] Async Pagination
- [ ] In-build search filters

---

## 🌐 Metadata Files

### LICENSE (MIT)

```text
MIT License

Copyright (c) 2025
```

## 🚀 Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

---

## 🙏 Credits

Crafted with passion by Haja Mohdn and lots of coffee.

## ✨ Happy Coding!
