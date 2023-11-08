#include <iostream>
#include <fstream>
#include <filesystem>
#include <unordered_set>
#include <unordered_map>
#include <memory>

typedef unsigned int uint;

using Matrix = std::vector<std::vector<int>>;

struct PrefPair {
	int wgPoints;
	int personPoints;
};

struct Data {
	std::unordered_map<std::string, int> personIdx, wgIdx;
	std::vector<std::string> idxPerson, idxWg;
	std::vector<std::vector<PrefPair>> values;
};

std::string trim(std::string s) {
	s.erase(s.begin(), std::find_if(s.begin(), s.end(), [](unsigned char c) {
		return !std::isspace(c);
	}));

	s.erase(std::find_if(s.rbegin(), s.rend(), [](unsigned char c) {
		return !std::isspace(c);
	}).base(), s.end());

	return s;
}

/*
Splits the string at the delimiter and returns a vector of trimmed strings.
*/
std::vector<std::string> split(std::string const& s, char delim) {
	if (trim(s).empty()) {
		return std::vector<std::string>();
	}

	auto lastDelim = 0;
	std::vector<std::string> parts;
	while (true) {
		auto curDelim = s.find(delim, lastDelim);
		std::string part;

		if (curDelim == std::string::npos) {
			part = s.substr(lastDelim);
		} else {
			part = s.substr(lastDelim, curDelim - lastDelim);
		}
		part = trim(part);

		parts.emplace_back(part);
		lastDelim = curDelim;

		if (curDelim == std::string::npos) {
			return parts;
		}

		lastDelim = curDelim + 1;
	}
}

std::unordered_set<std::string> getNamesFromTableHeader(const std::vector<std::string>& header, const std::string& errorPrefix, int tableNum) {
	std::unordered_set<std::string> names{};
	for (int i = 1; i < header.size(); ++i) {
		const auto& name = header[i];
		if (name.empty()) break;
		const auto& [_, inserted] = names.emplace(name);
		if (!inserted) {
			std::cerr << "Der " << errorPrefix << "-Name " << name << " wird in der "
				<< tableNum << ". Tabelle doppelt verwendet." << std::endl;
		}
	}
	return names;
}

bool checkTableHeaders(const std::vector<std::vector<std::string>>& table, std::unordered_set<std::string> expectedNames, const int checkTableNum, const int sourceTableNum, const std::string& errorPrefix) {
	bool hadError = false;
	auto namesCopy = expectedNames;
	for (int i = 1; i < table.size(); ++i) {
		const auto& name = table[i][0];
		if (namesCopy.find(name) == namesCopy.end()) {
			std::cerr << "Der " << errorPrefix << "-Name " << name << " wird in der " << checkTableNum
				<< "., aber nicht in der " << sourceTableNum << ". Tabelle verwendet." << std::endl;
			hadError = true;
		} else if (expectedNames.erase(name) == 0) {
			std::cerr << "Der " << errorPrefix << "-Name " << name << " wird in der " << checkTableNum
				<< ". Tabelle doppelt verwendet." << std::endl;
			hadError = true;
		}
	}

	for (const auto& n : expectedNames) {
		std::cerr << "Der " << errorPrefix << "-Name " << n << " wird in der " << sourceTableNum
			<< "., aber nicht in der " << checkTableNum << ". Tabelle verwendet." << std::endl;
		hadError = true;
	}
	return hadError;
}

std::string padLeft(const std::string& s, int len) {
	return std::string(std::max(len - s.length(), 0ull), ' ') + s;
}

std::string padRight(const std::string& s, int len) {
	return s + std::string(std::max(len - s.length(), 0ull), ' ');
}

void printTable(const std::vector<std::string>& headerTop, const std::vector<std::string>& headerLeft, const std::vector<std::vector<PrefPair>>& values) {
	std::cout << std::string(10, ' ');
	std::cout << '|';
	for (const auto& h : headerTop) {
		std::cout << '|';
		std::cout << padRight(' ' + h, 10);
	}
	std::cout << std::endl;
	std::cout << std::string((headerTop.size() + 1) * 11 + 1, '-');
	std::cout << std::endl;
	for (int i = 0; i < headerLeft.size(); ++i) {
		std::cout << padRight(' ' + headerLeft[i], 10);
		std::cout << '|';
		for (int j = 0; j < values[i].size(); ++j) {
			std::cout << '|';
			std::cout << padLeft(std::to_string(values[i][j].personPoints) + '/' + std::to_string(values[i][j].wgPoints) + ' ', 10);
		}
		std::cout << std::endl;
	}
}

std::shared_ptr<Data> readInput(const char* path) {
	bool hadError = false;
	std::ifstream file;
	file.open(path, std::ios::in);
	if (!file.is_open()) {
		std::cerr << "Die Datei konnte nicht geöffnet werden '" << path << "'.\n"
			<< "Du befindest dich momentan im Pfad " << std::filesystem::current_path() << std::endl;
		file.close();
		return nullptr;
	}

	std::vector<std::vector<std::string>> tables;

	std::string line;
	while (std::getline(file, line)) {
		std::vector<std::string> entries = split(line, ';');
		bool empty = true;
		for (const auto& e : entries) {
			if (!e.empty()) {
				empty = false;
				break;
			}
		}
		if (empty) {
			entries.clear();
		}
		tables.emplace_back(std::move(entries));
	}

	tables.erase(
		tables.begin(),
		std::find_if(tables.begin(), tables.end(), [](const auto& row) { return !row.empty(); })
	);
	tables.erase(
		std::find_if(tables.rbegin(), tables.rend(), [](const auto& row) { return !row.empty(); }).base(),
		tables.end()
	);

	int firstEmptyLine = -1;
	bool prevLineEmpty = false;
	int lastCorrectEmptyLine = -1;
	for (int i = 0; i < tables.size(); ++i) {
		const auto& row = tables[i];
		if (row.empty()) {
			if (firstEmptyLine == -1) {
				firstEmptyLine = i;
				prevLineEmpty = true;
			} else if (!prevLineEmpty) {
				std::cerr << "Fehler. Leere Zeilen sollten als Trennung ziwschen den Tabellen benutzt werden. Zeile " << (i + 1) << " sollte nicht leer sein." << std::endl;
				hadError = true;
			}
		} else if (prevLineEmpty) {
			lastCorrectEmptyLine = i - 1;
			prevLineEmpty = false;
		}
	}
	if (hadError) {
		return nullptr;
	}

	if (firstEmptyLine == 0 || lastCorrectEmptyLine == -1) {
		std::cerr << "Fehler. Es gibt keine zwei durch eine leere Zeile getrennten Tabellen." << std::endl;
		return nullptr;
	}

	std::vector<std::vector<std::string>> table1{tables.begin(), tables.begin() + firstEmptyLine};
	std::vector<std::vector<std::string>> table2{tables.begin() + lastCorrectEmptyLine + 1, tables.end()};

	auto wgs = getNamesFromTableHeader(table1[0], "WG", 1);
	auto persons = getNamesFromTableHeader(table2[0], "Personen", 2);

	if (wgs.empty() || persons.empty()) {
		std::cerr << "In einer Tabelle wurden keine WGs oder Personen angegeben." << std::endl;
	}

	hadError |= checkTableHeaders(table1, persons, 1, 2, "Personen");
	hadError |= checkTableHeaders(table2, wgs, 2, 1, "WG");

	if (hadError) {
		return nullptr;
	}

	std::unordered_map<std::string, int> personIdx{};
	std::unordered_map<std::string, int> wgIdx{};
	std::vector<std::string> idxPerson{};
	std::vector<std::string> idxWg{};

	{
		int i = 0;
		for (auto it = wgs.begin(); it != wgs.end(); ++it, ++i) {
			idxWg.push_back(*it);
			wgIdx[*it] = i;
		}
	}

	{
		int i = 0;
		for (auto it = persons.begin(); it != persons.end(); ++it, ++i) {
			idxPerson.push_back(*it);
			personIdx[*it] = i;
		}
	}

	std::vector<std::vector<PrefPair>> values{};
	for (int i = 0; i < idxPerson.size(); ++i) {
		values.emplace_back(std::vector<PrefPair>(idxWg.size(), {0, 0}));
	}

	for (int y = 1; y < table1.size(); ++y) {
		int pIdx = personIdx[table1[y][0]];
		for (int x = 1; x < wgs.size() + 1; ++x) {
			int wIdx = wgIdx[table1[0][x]];

			int v;
			try {
				v = std::stoi(table1[y][x]);
			} catch (std::invalid_argument e) {
				std::cerr << "In der 1. Tabelle bei " << table1[y][0] << " " << table1[0][x] << " sollte eine Zahl stehen." << std::endl;
				hadError = true;
				continue;
			}

			values[pIdx][wIdx].personPoints = v;
		}
	}

	for (int y = 1; y < table2.size(); ++y) {
		int wIdx = wgIdx[table2[y][0]];
		for (int x = 1; x < persons.size() + 1; ++x) {
			int pIdx = personIdx[table2[0][x]];

			int v;
			try {
				v = std::stoi(table2[y][x]);
			} catch (std::invalid_argument e) {
				std::cerr << "In der 2. Tabelle bei " << table2[y][0] << " " << table2[0][x] << " sollte eine Zahle stehen." << std::endl;
				hadError = true;
				continue;
			}

			values[pIdx][wIdx].wgPoints = v;
		}
	}

	if (hadError) {
		return nullptr;
	}

	printTable(idxWg, idxPerson, values);

	auto data = Data();
	data.idxPerson = idxPerson;
	data.idxWg = idxWg;
	data.personIdx = personIdx;
	data.wgIdx = wgIdx;
	data.values = values;

	return std::make_shared<Data>(data);
}

void printResult(int score, const std::vector<std::pair<int, int>>& path) {
	std::cout << std::to_string(score) << ": ";
	for (const auto& [p, w] : path) {
		std::cout << '(' << p << ';' << w << ") ";
	}
	std::cout << std::endl;
}

typedef std::vector<std::pair<int, int>> Path;
typedef std::unordered_map<int, std::vector<Path>> Results;

void recurse(const Data& data, uint32_t pFlags, uint32_t wFlags, Path& path, int score, Results& results) {
	if (pFlags == 0 || wFlags == 0) {
		auto it = results.find(score);
		if (it == results.end()) {
			results[score] = std::vector<Path>{path};
		} else {
			results[score].push_back(path);
		}
		//printResult(score, path);
		return;
	}
	int i = 0;
	while (((1 << i) & pFlags) == 0) ++i;

	bool found = false;

	for (int j = 0; j < data.idxWg.size(); ++j) {
		if ((1 << j) & wFlags) {
			auto pref = data.values[i][j];
			if (pref.personPoints == 0 || pref.wgPoints == 0) continue;

			found = true;

			int value = pref.personPoints * pref.wgPoints;

			path.emplace_back(i, j);
			recurse(data, pFlags & ~(1 << i), wFlags & ~(1 << j), path, score + value, results);
			path.pop_back();
		}
	}

	if (!found) {
		auto it = results.find(score);
		if (it == results.end()) {
			results[score] = std::vector<Path>{path};
		} else {
			results[score].push_back(path);
		}
	}
}

void solve(const Data& data) {
	uint32_t pFlags = 0;
	uint32_t wFlags = 0;
	for (int i = 0; i < data.idxPerson.size(); ++i) {
		pFlags |= (1 << i);
	}

	for (int i = 0; i < data.idxWg.size(); ++i) {
		wFlags |= (1 << i);
	}

	auto path = Path();
	auto results = Results();

	recurse(data, pFlags, wFlags, path, 0, results);

	auto maxScore = -1;
	for (auto it = results.begin(); it != results.end(); ++it) {
		if (it->first > maxScore) {
			maxScore = it->first;
		}
	}

	if (maxScore == -1) {
		std::cerr << "Es gab keine mögliche Kombination" << std::endl;
		return;
	}

	auto bestPaths = results[maxScore];
	std::cout << std::endl;
	std::cout << "Score: " << maxScore << std::endl << std::endl;
	for (const auto& p : bestPaths) {
		for (const auto& [per, wg] : p) {
			std::cout << '(' << data.idxPerson[per] << ';' << data.idxWg[wg] << ") ";
		}
		std::cout << std::endl;
	}
}

int main(int argc, char** argv) {
	if (argc != 2) {
		std::cout << "Usage: WG_Planung.exe [inputfile]" << std::endl;
		return -1;
	}

	auto input = readInput(argv[1]);
	solve(*input);
}