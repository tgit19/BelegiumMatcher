#include <iostream>
#include <fstream>
#include <filesystem>
#include <unordered_set>
#include <unordered_map>
#include <memory>

#include "InputReader.h"
#include "Hungarian.h"

IntMatrix transformMatrix(const Data& d, int(*valueFunc)(int, int)) {
	IntMatrix m = std::vector<std::vector<int>>(d.values.size(), std::vector<int>(d.values[0].size(), 0));
	for (int i = 0; i < m.size(); ++i) {
		for (int j = 0; j < m[0].size(); ++j) {
			auto pp = d.values[i][j].personPoints;
			auto wp = d.values[i][j].wgPoints;
			m[i][j] = valueFunc(pp, wp);
		}
	}
	return m;
}

void solveHungarian(Data d, int(*valueFunc)(int, int)) {
	Hungarian h;
	
	auto matrix = transformMatrix(d, valueFunc);
	auto result = h.solveMax(matrix);
	//std::cout << result << std::endl;

	//std::cout << "Cost: " << result.cost << std::endl;
	for (const auto& [wi, pi] : result.assignements) {
		auto person = d.idxPerson[pi];
		auto wg = d.idxWg[wi];
		auto value = d.values[wi][pi];
		std::cout << '(' << person << ';' << wg << ';' << value.personPoints << '/' << value.wgPoints << ") ";
	}
	std::cout << std::endl;
}

void processRoomCounts(std::shared_ptr<Data> data) {
	int realI = 0;
	for (int i = 0; i < data->values.size(); ++i) {
		if (data->roomCounts[realI] > 1) {
			data->idxWg.insert(data->idxWg.begin() + i + 1, data->idxWg[realI]);
			data->values.insert(data->values.begin() + i + 1, data->values[realI]);
			--data->roomCounts[realI];
		} else {
			++realI;
		}
	}
}

void processExtrema(std::shared_ptr<Data> data) {
	for (int i = 0; i < data->values.size(); ++i) {
		for (int j = 0; j < data->values[0].size(); ++j) {
			auto& pp = data->values[i][j].personPoints;
			auto& wp = data->values[i][j].wgPoints;
			if (pp == 0 || wp == 0) {
				pp = 0;
				wp = 0;
			} else if (pp == 15 && wp == 15) {
				pp = 25;
				wp = 25;
			}
		}
	}
}

int main(int argc, char** argv) {
	if (argc != 2) {
		std::cout << "Usage: WG_Planung.exe [inputfile]" << std::endl;
		return -1;
	}

	InputReader ir;

	auto input = ir.readFile(argv[1]);

	if (input == nullptr) return -2;

	processExtrema(input);
	processRoomCounts(input);

	//solve(*input, [](int a, int b) { return a + b; });
	//solve(*input, [](int a, int b) { return a * b; });
	//solve(*input, [](int a, int b) { return a * b * std::max(a, b) / (std::min(a, b) * 2); });

	std::cout << std::endl;

	solveHungarian(*input, [](int a, int b) { return a + b; });
	solveHungarian(*input, [](int a, int b) { return a * b; });
	solveHungarian(*input, [](int a, int b) { return a + b - std::abs(a - b) / 3; });
	//solveHungarian(*input, [](int a, int b) { return a * b * std::max(a, b) / (std::min(a, b) * 2); });

	return 0;
}