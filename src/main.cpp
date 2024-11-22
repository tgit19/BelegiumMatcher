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

/*
Copies wg if there are multiple empty rooms
*/
void processRoomCounts(std::shared_ptr<Data> data) {
	int j = 0;
	for (int i = 0; i < data->values.size(); ++i) {
		if (data->roomCounts[j] > 1) {
			data->idxWg.insert(data->idxWg.begin() + i + 1, data->idxWg[j]);
			data->values.insert(data->values.begin() + i + 1, data->values[j]);
			--data->roomCounts[j];
		} else {
			++j;
		}
	}
}

/*
Adjust values for vetos and perfect matches
*/
void processExtrema(std::shared_ptr<Data> data, int zusatzpunkte_direct_match) {
	for (int i = 0; i < data->values.size(); ++i) {
		for (int j = 0; j < data->values[0].size(); ++j) {
			auto& pp = data->values[i][j].personPoints;
			auto& wp = data->values[i][j].wgPoints;
			if (pp == 0 || wp == 0) {
				pp = -100;
				wp = -100;
			} else if (pp == 15 && wp == 15) {
				pp = 15 + zusatzpunkte_direct_match;
				wp = 15 + zusatzpunkte_direct_match;
			}
		}
	}
}

int main(int argc, char** argv) {
	if (argc < 2) {
		std::cout << "Usage: Belegium_Matcher.exe [inputfile] (optional number of extra points for direct match)" << std::endl;
		return -1;
	}
	
	int zusatzpunkte_direct_match = 10;
	
	if (argc == 3) {
        zusatzpunkte_direct_match = std::stoi(argv[2]);  // Konvertiert das zweite Argument in einen Integer
		std::cout << "Das Argument für Direct Matches Zusatzpunkte wurde angegeben (standard wäre 10) und hat den Wert " << zusatzpunkte_direct_match << std::endl;
	} else {
		std::cout << "Es wurde kein Argument für Direct Matches Zusatzpunkte dahinter übergeben, daher wird standard 10 verwendet" << std::endl;
	}

	InputReader ir;

	auto input = ir.readFile(argv[1]);

	if (input == nullptr) return -2;

	processExtrema(input, zusatzpunkte_direct_match);
	processRoomCounts(input);

	std::cout << std::endl;

	// solve with diffreren heuristics
	std::cout << "The solutions are calculated by using different functions to combine two values into a score." << std::endl;
	std::cout << "The score stand for how good a person and WG fit together and is used to calculate the best configuration of person and WG" << std::endl;
	std::cout << "This maximizes the sum over found person/WG combinations scores" << std::endl;
	std::cout << "To calculate the score of a possible person/WG combination the score a person gives to a WG (a) and the score a WG gives to a person are considered (b)" << std::endl;
	std::cout << std::endl;
	// I an not 100% sure a and b are this way and not the other one around
	std::cout << "Solution 1: a+b" << std::endl;
	// It promotes matches that are generally favorable to both parties but doesn't necessarily maximize the degree of mutual preference.
	// 10 / 1 will be picked over 5 / 5
	solveHungarian(*input, [](int a, int b) { return a + b; });
	
	std::cout << std::endl;
	std::cout << "Solution 2: a*b" << std::endl;
	// This approach prioritizes highly compatible matches but may ignore moderately good matches that could fill more slots effectively.
	solveHungarian(*input, [](int a, int b) { return ((a < 0 || b < 0) ? -1 : +1) * std::abs(a * b); }); // just a*b but fixed for negative numbers
	
	std::cout << std::endl;
	std::cout << "Solution 3: (a + b - |a - b| / 3) small penalty for difference of values => 7/7 is better than 3/11" << std::endl;
	// start with a + b but penatly for difference
	// It favors pairs with balanced mutual preferences
	solveHungarian(*input, [](int a, int b) { return a + b - std::abs(a - b) / 3; }); // small penalty for difference of values => 7/7 is better than 3/11

	std::cout << "\n\nPress enter to exit" << std::endl;
	std::cin.get();

	return 0;
}