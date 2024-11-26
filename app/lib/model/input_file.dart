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
  InputException? error;

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

    // get wgs names from the first tables
    wgs.addAll(
      _getNamesFromTableHeader(tables.first.first),
    );

    // get person names from the second tables
    persons.addAll(
      _getNamesFromTableHeader(
        tables.last.first,
        headerErrorOffset: table.first.length + 2,
      ),
    );

    // check for errors in table headers
    _checkTableHeader(
      tables.first,
      persons,
      headerErrorOffset: table.first.length + 2,
    );
    _checkTableHeader(
      tables.last,
      wgs,
      tableErrorOffset: table.first.length + 2,
    );

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

    // get wgs names from the first tables
    wgs.addAll(
      _getNamesFromTableHeader(tables.first.first),
    );

    // get person names from the second tables
    persons.addAll(
      _getNamesFromTableHeader(
        tables.last.first,
        headerErrorOffset: table.first.length,
      ),
    );

    // check for errors in table headers
    _checkTableHeader(
      tables.first,
      persons,
      headerErrorOffset: table.first.length,
    );
    _checkTableHeader(
      tables.last,
      wgs,
      tableErrorOffset: table.first.length,
    );

    return _parseTables();
  }

  /// internal metod to clear old data
  void _clear() {
    tables.clear();
    wgs.clear();
    persons.clear();
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
    List<String> lines = content.split('\n');

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

  /// internal method to verify if table headers match
  /// \throws InputException if dimensions dont match
  /// \throws InputException if name is missing
  /// \throws InputException if wrong ordered
  void _checkTableHeader(
    MatrixStorage<String> table,
    List<String> header, {
    int tableErrorOffset = 0,
    int headerErrorOffset = 0,
  }) {
    if (header.length != table.length - 1) {
      error = InputException(
        "Dimension missmatch detected",
        tableErrorOffset > headerErrorOffset
            ? TablePosition(null, 0)
            : TablePosition(headerErrorOffset, null),
        tableErrorOffset != 0 ? tableErrorOffset : null,
      );

      throw error!;
    }

    List<String> tableHeader = [];

    for (int i = 1; i < table.length; i++) {
      tableHeader.add(table[i][0]);
    }

    for (int i = 0; i < header.length; i++) {
      if (!header.contains(tableHeader[i])) {
        error = InputException(
          "Name is missing",
          TablePosition(tableErrorOffset + i + 1, 0),
        );

        throw error!;
      }

      if (!tableHeader.contains(header[i])) {
        error = InputException(
          "Name is missing",
          TablePosition(headerErrorOffset, i),
        );

        throw error!;
      }

      if (header[i] != tableHeader[i]) {
        error = InputException(
          "Wrong name order",
          tableErrorOffset > headerErrorOffset
              ? TablePosition(tableErrorOffset + i + 1, 0)
              : TablePosition(headerErrorOffset, i),
        );

        throw error!;
      }
    }
  }

  /// internal method to parse loaded tables to matrices
  List<Matrix<int>> _parseTables() => [
        _parseTable(tables.first),
        _parseTable(tables.last),
      ];

  /// internal method to parse a single table to its matrix
  Matrix<int> _parseTable(MatrixStorage<String> table) {
    Matrix<int> matrix = Matrix<int>(
      Dimension(table.length - 1, table.first.length - 1),
    );

    for (int i = 0; i < table.length - 1; i++) {
      for (int j = 0; j < table.first.length - 1; j++) {
        matrix[i][j] = int.parse(table[i + 1][j + 1]);
      }
    }

    return matrix;
  }
}
