#include "Hungarian.h"

void Hungarian::findUncoveredZero(int& row, int& col) {
	int r = 0;
	int c;
	bool done = false;
	row = -1;
	col = -1;
	for (int r = 0; r < size; ++r) {
		c = 0;
		for (int c = 0; c < size; ++c) {
			if (matrix[r][c] == 0 && rowCover[r] == 0 && colCover[c] == 0) {
				row = r;
				col = c;
				return;
			}
		}
	}
}

int Hungarian::findStarInRow(int row) {
	for (int c = 0; c < size; ++c) {
		if (mask[row][c] == 1) {
			return c;
		}
	}
	return -1;
}

int Hungarian::findStarInCol(int col) {
	for (int r = 0; r < size; ++r) {
		if (mask[r][col] == 1) {
			return r;
		}
	}
	return -1;
}

int Hungarian::findPrimeInRow(int row) {
	for (int c = 0; c < size; ++c) {
		if (mask[row][c] == 2) {
			return c;
		}
	}
	return -1;
}

void Hungarian::augmentPath(const Path& path) {
	for (const auto& p : path) {
		mask[p.row][p.col] = (mask[p.row][p.col] == 1) ? 0 : 1;
	}
}

void Hungarian::clearPrimes() {
	for (auto& row : mask) {
		for (auto& val : row) {
			if (val == 2) {
				val = 0;
			}
		}
	}
}

int Hungarian::findSmallestUncovered() {
	int minVal = std::numeric_limits<int>::max();
	for (int r = 0; r < size; ++r) {
		for (int c = 0; c < size; ++c) {
			if (rowCover[r] == 0 && colCover[c] == 0) {
				minVal = std::min(minVal, matrix[r][c]);
			}
		}
	}
	return minVal;
}

int Hungarian::findMaxValue(const MatI& values) {
	int maxVal = 0;
	for (const auto& row : values) {
		for (const auto& val : row) {
			maxVal = std::max(maxVal, val);
		}
	}
	return maxVal;
}

Hungarian::MatI Hungarian::invertMatrix(const MatI& values) {
	int maxVal = findMaxValue(values);
	MatI m = values;
	for (auto& row : m) {
		for (auto& val : row) {
			val = maxVal - val;
		}
	}
	return m;
}

void Hungarian::step1() {
	for (int r = 0; r < size; ++r) {
		int minVal = std::numeric_limits<int>::max();
		for (int c = 0; c < size; ++c) {
			minVal = std::min(minVal, matrix[r][c]);
		}

		for (int c = 0; c < size; ++c) {
			matrix[r][c] -= minVal;
		}
	}

	for (int c = 0; c < size; ++c) {
		int minVal = std::numeric_limits<int>::max();
		for (int r = 0; r < size; ++r) {
			minVal = std::min(minVal, matrix[r][c]);
		}

		for (int r = 0; r < size; ++r) {
			matrix[r][c] -= minVal;
		}
	}

	step = 2;
}

void Hungarian::step2() {
	for (int r = 0; r < size; ++r) {
		for (int c = 0; c < size; ++c) {
			if (matrix[r][c] == 0 && rowCover[r] == 0 && colCover[c] == 0) {
				rowCover[r] = 1;
				colCover[c] = 1;
				mask[r][c] = 1;
			}
		}
	}

	std::fill(rowCover.begin(), rowCover.end(), 0);
	std::fill(colCover.begin(), colCover.end(), 0);

	step = 3;
}

void Hungarian::step3() {
	int count = 0;
	for (int r = 0; r < size; ++r) {
		for (int c = 0; c < size; ++c) {
			if (mask[r][c] == 1 && colCover[c] == 0) {
				colCover[c] = 1;
				++count;
			}
		}
	}

	step = (count >= size) ? 7 : 4;
}

void Hungarian::step4() {
	int row = -1;
	int col = -1;
	bool done = false;

	while (!done) {
		findUncoveredZero(row, col);
		if (row == -1) {
			step = 6;
			return;
		} else {
			mask[row][col] = 2;
			int starCol = findStarInRow(row);
			if (starCol != -1) {
				col = starCol;
				rowCover[row] = 1;
				colCover[col] = 0;
			} else {
				step = 5;
				pathRow0 = row;
				pathCol0 = col;
				return;
			}
		}
	}
}

void Hungarian::step5() {
	bool done = false;
	int r = -1;
	int c = -1;

	Path path = Path();
	path.emplace_back(pathRow0, pathCol0);
	while (!done) {
		r = findStarInCol(path.back().col);
		if (r > -1) {
			path.emplace_back(r, path.back().col);
		} else {
			done = true;
		}

		if (!done) {
			c = findPrimeInRow(path.back().row);
			path.emplace_back(path.back().row, c);
		}
	}

	augmentPath(path);
	std::fill(rowCover.begin(), rowCover.end(), 0);
	std::fill(colCover.begin(), colCover.end(), 0);
	clearPrimes();
	step = 3;
}

void Hungarian::step6() {
	int minVal = findSmallestUncovered();
	for (int r = 0; r < size; r++) {
		for (int c = 0; c < size; c++) {
			if (rowCover[r] == 1)
				matrix[r][c] += minVal;
			if (colCover[c] == 0)
				matrix[r][c] -= minVal;
		}
	}
	step = 4;
}

Hungarian::Result Hungarian::solve(const MatI& original) {
	if (original.empty() || original[0].empty()) {
		std::cout << "Did not expect empty matrix." << std::endl;
	}

	matrix = original;
	size = std::max(original.size(), original[0].size());
	for (auto& row : matrix) {
		row.resize(size, 0);
	}
	matrix.resize(size, RowI(size, 0));
	mask = std::vector<RowI>(size, RowI(size, 0));
	rowCover = RowI(size, 0);
	colCover = RowI(size, 0);

	bool done = false;
	step = 1;
	while (!done) {
		//std::cout << '\n' << matrix << "\n" << mask << "\n------------" << "\nStep: " << step << std::endl;
		switch (step) {
		case 1: step1(); break;
		case 2: step2(); break;
		case 3: step3(); break;
		case 4: step4(); break;
		case 5: step5(); break;
		case 6: step6(); break;
		case 7: done = true; break;
		}
	}

	mask.resize(original.size());
	for (auto& row : mask) {
		row.resize(mask[0].size());
	}

	Result result{};
	for (int r = 0; r < mask.size(); ++r) {
		for (int c = 0; c < mask[0].size(); ++c) {
			if (mask[r][c] == 1) {
				result.cost += original[r][c];
				result.assignements.emplace_back(r, c);
			}
		}
	}

	return result;
}

Hungarian::Result Hungarian::solveMax(const MatI& original) {
	if (original.empty() || original[0].empty()) {
		std::cout << "Did not expect empty matrix." << std::endl;
	}
	
	int maxValue = findMaxValue(original);

	MatI inverted = invertMatrix(original);

	matrix = inverted;
	size = std::max(original.size(), original[0].size());
	for (auto& row : matrix) {
		row.resize(size, maxValue * 2);
	}
	matrix.resize(size, RowI(size, maxValue * 2));
	mask = std::vector<RowI>(size, RowI(size, 0));
	rowCover = RowI(size, 0);
	colCover = RowI(size, 0);

	bool done = false;
	step = 1;
	while (!done) {
		//std::cout << '\n' << matrix << "\n" << mask << "\n------------" << "\nStep: " << step << std::endl;
		switch (step) {
		case 1: step1(); break;
		case 2: step2(); break;
		case 3: step3(); break;
		case 4: step4(); break;
		case 5: step5(); break;
		case 6: step6(); break;
		case 7: done = true; break;
		}
	}

	mask.resize(original.size());
	for (auto& row : mask) {
		row.resize(original[0].size());
	}

	Result result{};
	for (int r = 0; r < mask.size(); ++r) {
		for (int c = 0; c < mask[0].size(); ++c) {
			if (mask[r][c] == 1) {
				result.cost += original[r][c];
				result.assignements.emplace_back(r, c);
			}
		}
	}

	//std::cout << mask << '\n' << original << std::endl;

	return result;
}

std::ostream& operator<<(std::ostream& os, const Hungarian::MatI& m) {
	for (const auto& row : m) {
		for (const auto& val : row) {
			os << val << "  ";
		}
		os << '\n';
	}
	return os;
}

std::ostream& operator<<(std::ostream& os, const Hungarian::Result& r) {
	os << "Result:\nCost: " << r.cost << '\n';
	for (const auto& asgn : r.assignements) {
		os << asgn.a << " - " << asgn.b << '\n';
	}
	return os;
}
