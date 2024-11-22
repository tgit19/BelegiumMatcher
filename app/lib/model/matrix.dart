import 'dart:math';

import 'package:belegium_matcher/model/dimension.dart';

class Matrix {
  /// dimension of this matrix
  final Dimension dimension;

  /// data storage
  final List<List<double>> data;

  /// constructor to create a matrix
  Matrix(this.dimension)
      : data = List<List<double>>.generate(
          dimension.m,
          (_) => List<double>.filled(dimension.n, 0),
        );

  /// factory constructor to create a square matrix
  factory Matrix.square(int dimension) => Matrix(
        Dimension.square(dimension),
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
  factory Matrix.fromData(List<List<double>> data) {
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
  List<double> operator [](int index) => data[index];

  /// opertator to write cell of the matrix
  void operator []=(List<int> position, double value) {
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
        matrix[[i, j]] = data[i][j] + other[i][j];
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
        matrix[[i, j]] = data[i][j] - other[i][j];
      }
    }

    return matrix;
  }

  /// operator to multiply two matrices
  Matrix operator *(Matrix other) {
    if (dimension.n != other.dimension.m) {
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
        double sum = 0;
        for (int r = 0; r < dimension.n; r++) {
          sum += data[i][r] * other[r][j];
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
        matrix[i][j] = factor * data[i][j];
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
  Matrix submatrix(List<int> position) {
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

  /// method to calculate the determinant of this matrix
  double determinant() {
    if (dimension.m != dimension.n) {
      throw ArgumentError("Matrix dimension must be quadratic.");
    }

    // Base cases for 1x1 and 2x2 matrix
    if (dimension.n == 1) {
      return data.first.first;
    } else if (dimension.n == 2) {
      return (data[0][0] * data[1][1] - data[0][1] * data[1][0]);
    }

    double det = 0;

    // Calculate subdeterminates for first row
    for (int j = 0; j < dimension.n; j++) {
      // Create a minor matrix by excluding the current row and column
      Matrix minor = submatrix([0, j]);

      // Use cofactor expansion along the first row
      det += pow(-1, j) * data[0][j] * minor.determinant();
    }

    return det;
  }

  /// method to calculate the adjugate of this matrix
  Matrix adjugate() => cofactorMatrix().transpose();

  /// method to calculate the cofactor matrix
  Matrix cofactorMatrix() {
    if (dimension.m != dimension.n) {
      throw ArgumentError("Matrix dimension must be quadratic.");
    }

    Matrix matrix = Matrix(dimension);

    for (int i = 0; i < dimension.n; i++) {
      for (int j = 0; j < dimension.n; j++) {
        // Create the minor matrix by excluding the ith row and jth column
        Matrix minor = submatrix([i, j]);

        // Cofactor calculation with sign change
        matrix[i][j] = ((i + j) % 2 == 0 ? 1 : -1) * minor.determinant();
      }
    }

    return matrix;
  }

  /// calculate the inverse matrix
  Matrix? invert() {
    if (dimension.m != dimension.n) {
      throw ArgumentError("Matrix dimension must be quadratic.");
    }

    double det = determinant();

    if (det == 0) {
      return null;
    }

    return adjugate().scale(1 / det);
  }

  @override
  String toString() => data.fold<String>(
        "",
        (String current, List<double> m) => m.fold<String>(
          "$current\n",
          (String line, double value) => "$line\t$value",
        ),
      );
}
