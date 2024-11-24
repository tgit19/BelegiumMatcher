import 'dart:math';

import 'dimension.dart';
import 'matrix_storage.dart';

class Matrix {
  /// dimension of this matrix
  final Dimension dimension;

  /// data storage
  final MatrixStorage<int> data;

  /// constructor to create a matrix
  Matrix(
    this.dimension, {
    int? fillValue,
  }) : data = MatrixStorage<int>.generate(
          dimension.m,
          (_) => List<int>.filled(dimension.n, fillValue ?? 0),
        );

  /// factory constructor to create a square matrix
  factory Matrix.square(
    int dimension, {
    int? fillValue,
  }) =>
      Matrix(
        Dimension.square(dimension),
        fillValue: fillValue,
      );

  /// factory constructor for identity matrix
  factory Matrix.identity(int dimension) {
    Matrix matrix = Matrix.square(dimension);

    for (var i = 0; i < dimension; i++) {
      matrix[i][i] = 1;
    }

    return matrix;
  }

  /// factory constructor to create matrix from data
  factory Matrix.fromData(MatrixStorage<int> data) {
    int m = data.length;
    int n = data.first.length;

    Matrix matrix = Matrix(Dimension(m, n));

    for (int i = 0; i < m; i++) {
      for (int j = 0; j < n; j++) {
        matrix[[i, j]] = data[i][j];
      }
    }

    return matrix;
  }

  /// operator to read the rows of the matrix
  List<int> operator [](int index) => data[index];

  /// opertator to write cell of the matrix
  void operator []=(List<int> position, int value) {
    data[position.first][position.last] = value;
  }

  /// operator to add two matrices
  Matrix operator +(Matrix other) {
    if (dimension != other.dimension) {
      throw ArgumentError("Matrix dimensions must be compatible for addition.");
    }

    Matrix matrix = Matrix(dimension);

    for (int i = 0; i < dimension.m; i++) {
      for (int j = 0; j < dimension.n; j++) {
        matrix[[i, j]] = (data[i][j] + other[i][j]);
      }
    }

    return matrix;
  }

  /// operator to substract two matrices
  Matrix operator -(Matrix other) {
    if (dimension != other.dimension) {
      throw ArgumentError("Matrix dimensions must be compatible for addition.");
    }

    Matrix matrix = Matrix(dimension);

    for (int i = 0; i < dimension.m; i++) {
      for (int j = 0; j < dimension.n; j++) {
        matrix[[i, j]] = (data[i][j] - other[i][j]);
      }
    }

    return matrix;
  }

  /// operator to multiply two matrices
  Matrix operator *(Matrix other) {
    if (!dimension.isQuadratic) {
      throw ArgumentError(
          "Matrix dimensions must be compatible for multiplication.");
    }

    Matrix matrix = Matrix(
      Dimension(
        dimension.m,
        other.dimension.n,
      ),
    );

    for (int i = 0; i < dimension.m; i++) {
      for (int j = 0; j < other.dimension.n; j++) {
        int sum = 0;
        for (int r = 0; r < dimension.n; r++) {
          sum = (sum + data[i][r] * other[r][j]);
        }
        matrix[[i, j]] = sum;
      }
    }

    return matrix;
  }

  /// method to copy this matrix
  Matrix copy() {
    Matrix matrix = Matrix(dimension);

    for (int i = 0; i < dimension.m; i++) {
      for (int j = 0; j < dimension.n; j++) {
        matrix[i][j] = data[i][j];
      }
    }

    return matrix;
  }

  /// method to scale this matrix with a scalar factor
  Matrix scale(double factor) {
    Matrix matrix = Matrix(dimension);

    for (int i = 0; i < dimension.m; i++) {
      for (int j = 0; j < dimension.n; j++) {
        matrix[i][j] = (factor * data[i][j]) as int;
      }
    }

    return matrix;
  }

  /// method to transpose this matrix
  Matrix transpose() {
    Matrix matrix = Matrix(
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
  Matrix submatrix(List position) {
    assert(position.first >= 0 && position.last >= 0);
    assert(position.first < dimension.m);
    assert(position.last < dimension.n);
    assert(dimension.m > 1);
    assert(dimension.n > 1);

    Matrix matrix = Matrix(
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
  Matrix row(int position) {
    Matrix vector = Matrix(
      Dimension(1, dimension.n),
    );

    for (int i = 0; i < dimension.n; i++) {
      vector[0][i] = data[position][i];
    }

    return vector;
  }

  /// get one vector (column) from the matrix
  Matrix column(int position) {
    Matrix vector = Matrix(
      Dimension(dimension.m, 1),
    );

    for (int i = 0; i < dimension.m; i++) {
      vector[i][0] = data[i][position];
    }

    return vector;
  }

  /// method to calculate the determinant of this matrix
  int determinant() {
    if (!dimension.isQuadratic) {
      throw ArgumentError("Matrix dimension must be quadratic.");
    }

    // Base cases for 1x1 and 2x2 matrix
    if (dimension.n == 1) {
      return data.first.first;
    } else if (dimension.n == 2) {
      return (data[0][0] * data[1][1] - data[0][1] * data[1][0]);
    }

    int det = 0;

    // Calculate subdeterminates for first row
    for (int j = 0; j < dimension.n; j++) {
      // Create a minor matrix by excluding the current row and column
      Matrix minor = submatrix([0, j]);

      // Use cofactor expansion along the first row
      det = (det + pow(-1, j) * data[0][j] * minor.determinant()) as int;
    }

    return det;
  }

  /// method to calculate the adjugate of this matrix
  Matrix adjugate() => cofactorMatrix().transpose();

  /// method to calculate the cofactor matrix
  Matrix cofactorMatrix() {
    if (!dimension.isQuadratic) {
      throw ArgumentError("Matrix dimension must be quadratic.");
    }

    Matrix matrix = Matrix(dimension);

    for (int i = 0; i < dimension.n; i++) {
      for (int j = 0; j < dimension.n; j++) {
        // Create the minor matrix by excluding the ith row and jth column
        Matrix minor = submatrix([i, j]);

        // Cofactor calculation with sign change
        matrix[i][j] = (((i + j) % 2 == 0 ? 1 : -1) * minor.determinant());
      }
    }

    return matrix;
  }

  /// calculate the inverse matrix
  Matrix? invert() {
    if (!dimension.isQuadratic) {
      throw ArgumentError("Matrix dimension must be quadratic.");
    }

    int det = determinant();

    if (det == 0) {
      return null;
    }

    return adjugate().scale(1 / det);
  }

  /// combine two matrices element wise
  Matrix combine(
    Matrix other,
    int Function(int a, int b) combine,
  ) {
    if (dimension != other.dimension) {
      throw ArgumentError(
          "Matrix dimensions must be compatible for combination.");
    }

    Matrix matrix = Matrix(dimension);

    for (int i = 0; i < dimension.n; i++) {
      for (int j = 0; j < dimension.n; j++) {
        matrix[i][j] = combine(data[i][j], other[i][j]);
      }
    }

    return matrix;
  }

  /// extend matrix with rows
  Matrix addRows(Matrix rows) {
    if (dimension.n != rows.dimension.n) {
      throw ArgumentError(
          "Matrix dimensions must be compatible for extension.");
    }
    Matrix matrix = Matrix(
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
  Matrix addColumns(Matrix columns) {
    if (dimension.m != columns.dimension.m) {
      throw ArgumentError(
          "Matrix dimensions must be compatible for extension.");
    }
    Matrix matrix = Matrix(
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
  Matrix quadratic([int? fillValue]) {
    Matrix matrix = Matrix(
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

  @override
  String toString() => data.fold<String>(
        "",
        (String current, List<int> m) => m.fold<String>(
          "$current\n",
          (String line, int value) => "$line\t$value",
        ),
      );
}
