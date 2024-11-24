import 'matrix.dart';
import 'result.dart';

abstract class AssignmentSolver<T extends num> {
  AssignmentResult solve(Matrix<T> problem);
}
