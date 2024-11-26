class TablePosition {
  final int? row;
  final int? column;

  /// constructor of a position
  /// positions can be
  ///  - a full row
  ///  - a full column
  ///  - a cell
  const TablePosition(
    this.row,
    this.column,
  ) : assert(row != null || column != null);

  @override
  String toString() => "TablePosition(row: $row, column: $column)";
}
