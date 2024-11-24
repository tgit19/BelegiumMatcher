/// helper type for matrix dimensions
class Dimension {
  /// rows
  final int m;

  /// columns
  final int n;

  /// constructor to create a matrix dimension
  const Dimension(this.m, this.n);

  /// factory constructor to create a square dimension
  factory Dimension.square(int dimension) => Dimension(dimension, dimension);

  /// getter to check if dimension is quadratic
  bool get isQuadratic => m == n;

  @override
  int get hashCode => toString().hashCode;

  @override
  bool operator ==(covariant Dimension other) => m == other.m && n == other.n;

  @override
  String toString() => "${m}x$n";
}
