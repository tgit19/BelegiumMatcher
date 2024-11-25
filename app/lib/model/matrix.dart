import 'dart:math';

import 'dimension.dart';
import 'matrix_storage.dart';

class Matrix<T extends num> {
  /// dimension of this matrix
  final Dimension dimension;

  /// data storage
  final MatrixStorage<T> data;

  /// constructor to create a matrix
  Matrix(
    this.dimension, {
    T? fillValue,
  }) : data = MatrixStorage<T>.generate(
          dimension.m,
          (_) => List<T>.filled(dimension.n, fillValue ?? 0 as T),
        );

  /// factory constructor to create a square matrix
  factory Matrix.square(
    int dimension, {
    T? fillValue,
  }) =>
      Matrix(
        Dimension.square(dimension),
        fillValue: fillValue,
      );

  /// factory constructor for identity matrix
  factory Matrix.identity(int dimension) {
    Matrix<T> matrix = Matrix.square(dimension);

    for (var i = 0; i < dimension; i++) {
      matrix[i][i] = 1 as T;
    }

    return matrix;
  }

  /// factory constructor to create matrix from data
  factory Matrix.fromData(MatrixStorage<T> data) {
    int m = data.length;
    int n = data.first.length;

    Matrix<T> matrix = Matrix(Dimension(m, n));

    for (int i = 0; i < m; i++) {
      for (int j = 0; j < n; j++) {
        matrix[[i, j]] = data[i][j];
      }
    }

    return matrix;
  }

  /// operator to read the rows of the matrix
  List<T> operator [](int index) => data[index];

  /// opertator to write cell of the matrix
  void operator []=(List<int> position, T value) {
    data[position.first][position.last] = value;
  }

  /// operator to add two matrices
  Matrix<T> operator +(Matrix<T> other) {
    if (dimension != other.dimension) {
      throw ArgumentError("Matrix dimensions must be compatible for addition.");
    }

    Matrix<T> matrix = Matrix(dimension);

    for (int i = 0; i < dimension.m; i++) {
      for (int j = 0; j < dimension.n; j++) {
        matrix[[i, j]] = (data[i][j] + other[i][j]) as T;
      }
    }

    return matrix;
  }

  /// operator to substract two matrices
  Matrix<T> operator -(Matrix<T> other) {
    if (dimension != other.dimension) {
      throw ArgumentError("Matrix dimensions must be compatible for addition.");
    }

    Matrix<T> matrix = Matrix(dimension);

    for (int i = 0; i < dimension.m; i++) {
      for (int j = 0; j < dimension.n; j++) {
        matrix[[i, j]] = (data[i][j] - other[i][j]) as T;
      }
    }

    return matrix;
  }

  /// operator to multiply two matrices
  Matrix<T> operator *(Matrix<T> other) {
    if (!dimension.isQuadratic) {
      throw ArgumentError(
          "Matrix dimensions must be compatible for multiplication.");
    }

    Matrix<T> matrix = Matrix(
      Dimension(
        dimension.m,
        other.dimension.n,
      ),
    );

    for (int i = 0; i < dimension.m; i++) {
      for (int j = 0; j < other.dimension.n; j++) {
        T sum = 0 as T;
        for (int r = 0; r < dimension.n; r++) {
          sum = (sum + data[i][r] * other[r][j]) as T;
        }
        matrix[[i, j]] = sum;
      }
    }

    return matrix;
  }

  /// method to copy this matrix
  Matrix<T> copy() {
    Matrix<T> matrix = Matrix(dimension);

    for (int i = 0; i < dimension.m; i++) {
      for (int j = 0; j < dimension.n; j++) {
        matrix[i][j] = data[i][j];
      }
    }

    return matrix;
  }

  /// method to scale this matrix with a scalar factor
  Matrix<T> scale(double factor) {
    Matrix<T> matrix = Matrix(dimension);

    for (int i = 0; i < dimension.m; i++) {
      for (int j = 0; j < dimension.n; j++) {
        matrix[i][j] = (factor * data[i][j]) as T;
      }
    }

    return matrix;
  }

  /// method to transpose this matrix
  Matrix<T> transpose() {
    Matrix<T> matrix = Matrix(
      Dimension(dimension.n, dimension.m),
    );

    for (int i = 0; i < dimension.m; i++) {
      for (int j = 0; j < dimension.n; j++) {
        matrix[j][i] = data[i][j];
      }
    }

    return matrix;
  }

  /// get the submatrix at [position]
  Matrix<T> submatrix(List<int> position) {
    assert(position.first >= 0 && position.last >= 0);
    assert(position.first < dimension.m);
    assert(position.last < dimension.n);
    assert(dimension.m > 1);
    assert(dimension.n > 1);

    Matrix<T> matrix = Matrix(
      Dimension(dimension.m - 1, dimension.n - 1),
    );

    for (int i = 0; i < matrix.dimension.m; i++) {
      int m = i >= position.first ? i + 1 : i;
      for (int j = 0; j < matrix.dimension.n; j++) {
        int n = j >= position.last ? j + 1 : j;
        matrix[i][j] = data[m][n];
      }
    }

    return matrix;
  }

  /// get one vector (row) from the matrix
  Matrix<T> row(int position) {
    Matrix<T> vector = Matrix(
      Dimension(1, dimension.n),
    );

    for (int i = 0; i < dimension.n; i++) {
      vector[0][i] = data[position][i];
    }

    return vector;
  }

  /// get one vector (column) from the matrix
  Matrix<T> column(int position) {
    Matrix<T> vector = Matrix(
      Dimension(dimension.m, 1),
    );

    for (int i = 0; i < dimension.m; i++) {
      vector[i][0] = data[i][position];
    }

    return vector;
  }

  /// method to calculate the determinant of this matrix
  T determinant() {
    if (!dimension.isQuadratic) {
      throw ArgumentError("Matrix dimension must be quadratic.");
    }

    // Base cases for 1x1 and 2x2 matrix
    if (dimension.n == 1) {
      return data.first.first;
    } else if (dimension.n == 2) {
      return (data[0][0] * data[1][1] - data[0][1] * data[1][0]) as T;
    }

    T det = 0 as T;

    // Calculate subdeterminates for first row
    for (int j = 0; j < dimension.n; j++) {
      // Create a minor matrix by excluding the current row and column
      Matrix<T> minor = submatrix([0, j]);

      // Use cofactor expansion along the first row
      det = (det + pow(-1, j) * data[0][j] * minor.determinant()) as T;
    }

    return det;
  }

  /// method to calculate the adjugate of this matrix
  Matrix<T> adjugate() => cofactorMatrix().transpose();

  /// method to calculate the cofactor matrix
  Matrix<T> cofactorMatrix() {
    if (!dimension.isQuadratic) {
      throw ArgumentError("Matrix dimension must be quadratic.");
    }

    Matrix<T> matrix = Matrix(dimension);

    for (int i = 0; i < dimension.n; i++) {
      for (int j = 0; j < dimension.n; j++) {
        // Create the minor matrix by excluding the ith row and jth column
        Matrix<T> minor = submatrix([i, j]);

        // Cofactor calculation with sign change
        matrix[i][j] = (((i + j) % 2 == 0 ? 1 : -1) * minor.determinant()) as T;
      }
    }

    return matrix;
  }

  /// calculate the inverse matrix
  Matrix<T>? invert() {
    if (!dimension.isQuadratic) {
      throw ArgumentError("Matrix dimension must be quadratic.");
    }

    T det = determinant();

    if (det == 0) {
      return null;
    }

    return adjugate().scale(1 / det);
  }

  /// combine two matrices element wise
  Matrix<T> combine(
    Matrix<T> other,
    T Function(T a, T b) combine,
  ) {
    if (dimension != other.dimension) {
      throw ArgumentError(
          "Matrix dimensions must be compatible for combination.");
    }

    Matrix<T> matrix = Matrix(dimension);

    for (int i = 0; i < dimension.m; i++) {
      for (int j = 0; j < dimension.n; j++) {
        matrix[i][j] = combine(data[i][j], other[i][j]);
      }
    }

    return matrix;
  }

  /// extend matrix with rows
  Matrix<T> addRows(Matrix<T> rows) {
    if (dimension.n != rows.dimension.n) {
      throw ArgumentError(
          "Matrix dimensions must be compatible for extension.");
    }
    Matrix<T> matrix = Matrix(
      Dimension(dimension.m + rows.dimension.m, dimension.n),
    );

    int i = 0;

    for (; i < dimension.m; i++) {
      for (int j = 0; j < dimension.n; j++) {
        matrix[i][j] = data[i][j];
      }
    }

    for (int k = 0; k < rows.dimension.m; k++) {
      for (int j = 0; j < dimension.n; j++) {
        matrix[i + k][j] = rows[k][j];
      }
    }

    return matrix;
  }

  /// extend matrix with columns
  Matrix<T> addColumns(Matrix<T> columns) {
    if (dimension.m != columns.dimension.m) {
      throw ArgumentError(
          "Matrix dimensions must be compatible for extension.");
    }
    Matrix<T> matrix = Matrix(
      Dimension(dimension.m, dimension.n + columns.dimension.n),
    );

    for (int i = 0; i < dimension.m; i++) {
      int j = 0;

      for (; j < dimension.n; j++) {
        matrix[i][j] = data[i][j];
      }

      for (int k = 0; k < columns.dimension.n; k++) {
        matrix[i][j + k] = columns[i][k];
      }
    }

    return matrix;
  }

  /// extend matrix to become quadratic
  Matrix<T> quadratic([T? fillValue]) {
    Matrix<T> matrix = Matrix(
      Dimension.square(
        max(dimension.m, dimension.n),
      ),
      fillValue: fillValue,
    );

    for (int i = 0; i < dimension.m; i++) {
      for (int j = 0; j < dimension.n; j++) {
        matrix[i][j] = data[i][j];
      }
    }

    return matrix;
  }

  /// get the value of the lagest entry
  T largestEntry() {
    num number = double.negativeInfinity;

    for (int i = 0; i < dimension.m; i++) {
      for (int j = 0; j < dimension.n; j++) {
        number = max(number, data[i][j]);
      }
    }

    return number as T;
  }

  /// get the value of the smallest entry
  T smallestEntry() {
    num number = double.infinity;

    for (int i = 0; i < dimension.m; i++) {
      for (int j = 0; j < dimension.n; j++) {
        number = min(number, data[i][j]);
      }
    }

    return number as T;
  }

  /// convert matrix to int matrix
  Matrix<int> toInt() {
    Matrix<int> matrix = Matrix(dimension);

    for (int i = 0; i < dimension.n; i++) {
      for (int j = 0; j < dimension.n; j++) {
        matrix[i][j] = data[i][j].toInt();
      }
    }

    return matrix;
  }

  /// convert matrix to double matrix
  Matrix<double> toDouble() {
    Matrix<double> matrix = Matrix(dimension);

    for (int i = 0; i < dimension.n; i++) {
      for (int j = 0; j < dimension.n; j++) {
        matrix[i][j] = data[i][j].toDouble();
      }
    }

    return matrix;
  }

  @override
  String toString() => data.fold<String>(
        "",
        (String current, List<T> m) => m.fold<String>(
          "$current\n",
          (String line, T value) => "$line\t$value",
        ),
      );
}
