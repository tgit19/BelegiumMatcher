class TablePosition {
  final int? row;
  final int? column;
  final int? rowOffset;

  /// constructor of a position
  /// positions can be
  ///  - a full row
  ///  - a full column
  ///  - a cell
  const TablePosition(
    this.row,
    this.column, [
    this.rowOffset,
  ]) : assert(row != null || column != null);

  @override
  String toString() =>
      "TablePosition(row: $row (+$rowOffset), column: $column)";
}
