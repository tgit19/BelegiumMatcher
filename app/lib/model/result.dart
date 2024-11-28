import 'matrix.dart';

class AssignmentResult {
  final List<MapEntry<int, int>> assignments = [];
  final Matrix<int>? problem;
  int costs = 0;
  String problemOperatrionDescription = "";

  AssignmentResult(this.problem);
}
