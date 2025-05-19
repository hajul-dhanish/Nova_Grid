part of '../nova_grid.dart';

class TablePagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;

  const TablePagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.first_page),
          onPressed: currentPage > 0 ? () => onPageChanged(0) : null,
        ),
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed:
              currentPage > 0 ? () => onPageChanged(currentPage - 1) : null,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'Page ${currentPage + 1} of $totalPages',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: currentPage < totalPages - 1
              ? () => onPageChanged(currentPage + 1)
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.last_page),
          onPressed: currentPage < totalPages - 1
              ? () => onPageChanged(totalPages - 1)
              : null,
        ),
      ],
    );
  }
}
