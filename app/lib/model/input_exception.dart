import 'table_position.dart';

class InputException extends FormatException {
  @override
  TablePosition get source => super.source;

  const InputException(
    super.message,
    TablePosition super.source, [
    super.offset,
  ]);
}
