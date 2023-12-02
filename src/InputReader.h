#ifndef INPUT_READER_H
#define INPUT_READER_H

#include "Utils.h"

struct PrefPair {
	int wgPoints;
	int personPoints;
};

typedef std::vector<std::vector<PrefPair>> PairMatrix;

struct Data {
	std::unordered_map<std::string, int> personIdx, wgIdx;
	std::vector<std::string> idxPerson, idxWg;
	std::vector<int> roomCounts;
	PairMatrix values;
};

/*
Reads two tables from an csv-file (comma-separated)
*/
class InputReader {
private:
	std::unordered_map<std::string, int> personIdx;
	std::unordered_map<std::string, int> wgIdx;
	std::vector<std::string> idxPerson;
	std::vector<std::string> idxWg;

private:
	std::pair<StrMatrix, StrMatrix>* readTables(std::ifstream& file);

	bool checkTableHeaders(const std::vector<std::vector<std::string>>& table, std::unordered_set<std::string> expectedNames, const int checkTableNum,
		const int sourceTableNum, const std::string& errorPrefix);

	std::unordered_set<std::string> getNamesFromTableHeader(const std::vector<std::string>& header, const std::string& errorPrefix, int tableNum);

	void printTable(const std::vector<std::string>& headerTop, const std::vector<std::string>& headerLeft, const std::vector<std::vector<PrefPair>>& values);

public:
	std::shared_ptr<Data> readFile(const std::string& path);

};

#endif