import 'dart:io';

import 'dimension.dart';
import 'table_position.dart';
import 'input_exception.dart';
import 'matrix.dart';
import 'matrix_storage.dart';

class InputFile {
  /// internal file handle
  final File _file;

  /// content of the file
  final MatrixStorage<String> table = [];

  /// loaded tables (wgs, persons)
  final List<MatrixStorage<String>> tables = [];

  final List<String> wgs = [];
  final List<String> persons = [];

  /// store details of input errors
  FormatException? error;

  /// constructor for input files
  InputFile(String filepath) : _file = File(filepath);

  /// method to load content
  Future<List<Matrix<int>>> load() async {
    // clear old data
    _clear();

    // split the table
    _splitTable(
      await _getContent(),
    );

    // transform input data and perform validation checks
    _transformData();

    return _parseTables();
  }

  /// method to load content synchronously
  List<Matrix<int>> loadSync() {
    // clear old data
    _clear();

    // split the table
    _splitTable(
      _getContentSync(),
    );

    // transform input data and perform validation checks
    _transformData();

    return _parseTables();
  }

  /// internal metod to clear old data
  void _clear() {
    tables.clear();
    wgs.clear();
    persons.clear();
    error = null;
  }

  /// internal method to load file content
  /// \throws FileSystemException if file doesnt exist
  /// \throws FormatException on missing lines
  Future<String> _getContent() async {
    // throw error if file doesn't exist
    if (!await _file.exists()) {
      throw FileSystemException("File not found", _file.path);
    }

    // get file content
    String content = await _file.readAsString();

    // count the lines
    int lineCount = RegExp('\n').allMatches(content).length;

    if (lineCount < 4) {
      throw FormatException("Multiple lines required", content);
    }

    return content;
  }

  /// internal method to load file content
  /// \throws FileSystemException if file doesnt exist
  /// \throws FormatException on missing lines
  String _getContentSync() {
    // throw error if file doesn't exist
    if (!_file.existsSync()) {
      throw FileSystemException("File not found", _file.path);
    }

    // get file content
    String content = _file.readAsStringSync();

    // count the lines
    int lineCount = RegExp('\n').allMatches(content).length;

    if (lineCount < 4) {
      throw FormatException("Multiple lines required", content);
    }

    return content;
  }

  /// internal method to split table into [tables]
  /// \throws InputException (2) on wrong count of empty lines
  void _splitTable(String content) {
    // set the delimiter character
    String delimiter = _determineDelimiter(content);

    // split content into its lines
    List<String> lines = content.replaceAll('\r', '').split('\n');

    // clear data of old tables
    table.clear();

    // count empty lines
    int emptyCount = 0;

    // remember first empty lines position
    int? tableSplitPosition;

    // current line position
    int currentLine = 0;

    for (String line in lines) {
      // skip empty lines
      if (line.isEmpty) continue;

      // split line into its entries
      List<String> entries = line.split(delimiter);
      bool empty = true;

      // search for entry with content
      for (String entry in entries) {
        if (entry.isNotEmpty) {
          empty = false;
          break;
        }
      }

      if (!empty) {
        // only add lines which are not empty
        table.add(
          _stripLine(entries),
        );
      } else {
        table.add(entries);
        emptyCount += 1;
        tableSplitPosition ??= currentLine;

        if (emptyCount > 1) {
          error = InputException(
            "Multiple empty lines detected",
            TablePosition(currentLine, null),
          );

          throw error!;
        }
      }

      currentLine++;
    }

    if (emptyCount == 0) {
      error = InputException(
        "No empty line detected",
        TablePosition(currentLine - 1, null),
      );

      throw error!;
    }

    // make sure tables it empty
    tables.clear();

    // add first table
    tables.add(
      table.sublist(0, tableSplitPosition!),
    );

    // add second table withoud the empty line
    tables.add(
      table.sublist(tableSplitPosition + 1, table.length),
    );
  }

  /// internal method to determine the delimiter character in [content]
  String _determineDelimiter(String content) {
    // count occurrence of ; and , to determine delimiter character
    int semicolon = RegExp(';').allMatches(content).length;
    int comma = RegExp(',').allMatches(content).length;

    // return delimiter character
    return semicolon > comma ? ';' : ',';
  }

  /// internal method to strip empty elements from line end
  List<String> _stripLine(List<String> line) {
    List<String> stripped = [];

    for (String entry in line) {
      if (entry.isEmpty && stripped.isNotEmpty) {
        break;
      }

      stripped.add(entry);
    }

    return stripped;
  }

  /// internal method to transform input data and run some validation checks
  void _transformData() {
    // sort tables to prevent wrong name order
    tables[0] = _sortedTable(
      tables[0],
    );

    tables[1] = _sortedTable(
      tables[1],
      tableErrorOffset: tables[0].length + 1,
    );

    // get wgs names from the first table
    wgs.addAll(
      _getNamesFromTableHeader(
        tables[0][0],
      ),
    );

    // get person names from the second table
    persons.addAll(
      _getNamesFromTableHeader(
        tables[1][0],
        headerErrorOffset: tables[0].length + 1,
      ),
    );

    // check for errors in table headers
    _checkTableHeader(
      tables[0],
      persons,
      columnHeaderErrorOffset: tables[0].length + 1,
    );

    _checkTableHeader(
      tables[1],
      wgs,
      tableErrorOffset: tables[0].length + 1,
    );
  }

  /// internal method to extract names from header
  /// \throws InputException for name duplicates
  /// \throws InputException if no names found
  List<String> _getNamesFromTableHeader(
    List<String> header, {
    int headerErrorOffset = 0,
  }) {
    final List<String> names = [];

    for (int i = 1; i < header.length; i++) {
      // exit if first empty header entry is detected
      if (header[i].isEmpty) break;

      // prevent multiple identical names
      if (header
              .where(
                (element) => element == header[i],
              )
              .length >
          1) {
        error = InputException(
          "Name duplicate found",
          TablePosition(headerErrorOffset, i),
        );

        throw error!;
      }

      names.add(header[i]);
    }

    if (names.isEmpty) {
      error = InputException(
        "No names found in header",
        TablePosition(headerErrorOffset, null),
      );

      throw error!;
    }

    // return list of names
    return names;
  }

  /// internal method to sort [table] dependend on its [rowHeader] and [columnHeader]
  MatrixStorage<String> _sortedTable(
    MatrixStorage<String> table, {
    int tableErrorOffset = 0,
  }) {
    List<String> rowHeader = [];

    for (int i = 1; i < table.length; i++) {
      // prevent multiple identical names
      if (table[i]
              .where(
                (element) => element == table[i][0],
              )
              .length >
          1) {
        error = InputException(
          "Name duplicate found",
          TablePosition(tableErrorOffset + i + 1, 0),
        );

        throw error!;
      }

      rowHeader.add(
        table[i][0],
      );
    }

    List<String> columnHeader = _getNamesFromTableHeader(table[0]);

    List<String> desiredRowHeader = rowHeader.toList();
    List<String> desiredColumnHeader = columnHeader.toList();

    // sort row header
    desiredRowHeader.sort(
      (a, b) => a.compareTo(b),
    );

    // sort column header
    desiredColumnHeader.sort(
      (a, b) => a.compareTo(b),
    );

    // check if rows need to be resorted
    bool rowNeedsSort = false;
    for (int i = 0; i < rowHeader.length; i++) {
      if (rowHeader[i] != desiredRowHeader[i]) {
        rowNeedsSort = true;
        break;
      }
    }

    // check if columns need to be resorted
    bool columnNeedsSort = false;
    for (int i = 0; i < columnHeader.length; i++) {
      if (columnHeader[i] != desiredColumnHeader[i]) {
        columnNeedsSort = true;
        break;
      }
    }

    // abort if no resort needed
    if (!rowNeedsSort && !columnNeedsSort) return table;

    // remember size of the table
    Dimension size = Dimension(table.length, table[0].length);
    MatrixStorage<String> newTable = [];

    // handle header row
    if (columnNeedsSort) {
      newTable.add(
        _sortedColumn(table, columnHeader, desiredColumnHeader, 0),
      );
    } else {
      newTable.add(table[0]);
    }

    // handle the rest
    for (int i = 1; i < size.m; i++) {
      if (columnNeedsSort) {
        newTable.add(
          _sortedColumn(
            table,
            columnHeader,
            desiredColumnHeader,
            1 + rowHeader.indexOf(desiredRowHeader[i - 1]),
          ),
        );
      } else if (rowNeedsSort) {
        newTable.add(
          table[1 + rowHeader.indexOf(desiredRowHeader[i - 1])],
        );
      } else {
        newTable.add(
          table[i],
        );
      }
    }

    return newTable;
  }

  /// internal method to sort columns of [table] based on
  ///  [columnHeader] vs [desiredColumnHeader] and the [currentRow]
  List<String> _sortedColumn(
    MatrixStorage<String> table,
    List<String> columnHeader,
    List<String> desiredColumnHeader,
    int currentRow,
  ) {
    List<String> newRow = [
      table[currentRow][0],
    ];

    for (int j = 0; j < columnHeader.length; j++) {
      newRow.add(
        table[currentRow][1 + columnHeader.indexOf(desiredColumnHeader[j])],
      );
    }

    return newRow;
  }

  /// internal method to verify if table headers match
  /// \throws InputException if dimensions dont match
  /// \throws InputException if name is missing
  /// \throws InputException if wrong ordered
  void _checkTableHeader(
    MatrixStorage<String> table,
    List<String> otherRowHeader, {
    int tableErrorOffset = 0,
    int columnHeaderErrorOffset = 0,
  }) {
    if (otherRowHeader.length != table.length - 1) {
      error = InputException(
        "Dimension missmatch detected",
        tableErrorOffset > columnHeaderErrorOffset
            ? TablePosition(null, 0, tableErrorOffset)
            : TablePosition(columnHeaderErrorOffset, null),
      );

      throw error!;
    }

    List<String> columnHeader = [];

    for (int i = 1; i < table.length; i++) {
      columnHeader.add(table[i][0]);
    }

    for (int i = 0; i < otherRowHeader.length; i++) {
      if (!otherRowHeader.contains(columnHeader[i])) {
        error = FormatException(
          "Name is missing",
          columnHeader[i],
        );

        throw error!;
      }

      if (!columnHeader.contains(otherRowHeader[i])) {
        error = FormatException(
          "Name is missing",
          otherRowHeader[i],
        );

        throw error!;
      }
    }
  }

  /// internal method to parse loaded tables to matrices
  List<Matrix<int>> _parseTables() => [
        _parseTable(tables[0]),
        _parseTable(tables[1]),
      ];

  /// internal method to parse a single table to its matrix
  Matrix<int> _parseTable(MatrixStorage<String> table) {
    Matrix<int> matrix = Matrix<int>(
      Dimension(table.length - 1, table[0].length - 1),
    );

    for (int i = 0; i < table.length - 1; i++) {
      for (int j = 0; j < table[0].length - 1; j++) {
        matrix[i][j] = int.parse(table[i + 1][j + 1]);
      }
    }

    return matrix;
  }
}
