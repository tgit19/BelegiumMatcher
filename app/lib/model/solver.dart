import 'matrix.dart';
import 'result.dart';

abstract class AssignmentSolver {
  AssignmentResult solve(Matrix problem);
}
