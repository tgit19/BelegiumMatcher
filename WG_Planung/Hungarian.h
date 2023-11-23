#ifndef HUNGARIAN_H
#define HUNGARIAN_H

#include <iostream>
#include <vector>

class Hungarian {
public:
	typedef std::vector<int> RowI;
	typedef std::vector<RowI> MatI;

	struct Pos {
		int row, col;

		Pos(int row, int col) : row(row), col(col) {}
	};

	struct Assignment {
		int a, b;

		Assignment(int a, int b) : a(a), b(b) {}
	};

	typedef std::vector<Pos> Path;

	struct Result {
		int cost;
		std::vector<Assignment> assignements;
	};

private:
	MatI matrix;
	MatI mask;
	RowI rowCover;
	RowI colCover;
	int step;
	int size;
	int pathRow0, pathCol0;

private:
	void findUncoveredZero(int& row, int& col);
	int findStarInRow(int row);
	int findStarInCol(int col);
	int findPrimeInRow(int row);
	void augmentPath(const Path& path);
	void clearPrimes();
	int findSmallestUncovered();
	int findMaxValue(const MatI& values);
	MatI invertMatrix(const MatI& values);

private:
	void step1();
	void step2();
	void step3();
	void step4();
	void step5();
	void step6();

public:
	Result solve(const MatI& original);
	Result solveMax(const MatI& original);

};

std::ostream& operator<<(std::ostream& os, const Hungarian::MatI& m);
std::ostream& operator<<(std::ostream& os, const Hungarian::Result& r);

#endif