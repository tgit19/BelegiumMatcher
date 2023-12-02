#ifndef HUNGARIAN_H
#define HUNGARIAN_H

#include "Utils.h"

/*
Implementation of the Hungarian Algorithm
Slightly modified version of https://brc2.com/the-algorithm-workshop/
*/
class Hungarian {
public:

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
	IntMatrix matrix;
	IntMatrix mask;
	IntVec rowCover;
	IntVec colCover;
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
	int findMaxValue(const IntMatrix& values);
	IntMatrix invertMatrix(const IntMatrix& values);

private:
	void step1();
	void step2();
	void step3();
	void step4();
	void step5();
	void step6();

public:
	Result solveMin(const IntMatrix& original);
	Result solveMax(const IntMatrix& original);

};

std::ostream& operator<<(std::ostream& os, const IntMatrix& m);
std::ostream& operator<<(std::ostream& os, const Hungarian::Result& r);

#endif