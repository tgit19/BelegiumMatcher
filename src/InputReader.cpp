#include "InputReader.h"

std::pair<StrMatrix, StrMatrix>* InputReader::readTables(std::ifstream& file) {
	std::vector<std::vector<std::string>> tables{};

	std::vector<std::string> lines{};

	unsigned semicolon = 0;
	unsigned comma = 0;

	{
		std::string line;
		while (std::getline(file, line)) {
			for (char c : line) {
				if (c == ';') semicolon++;
				else if (c == ',') comma++;
			}
			lines.emplace_back(line);
		}
	}

	const char delimiter = (semicolon > comma) ? ';' : ',';
	for (const auto& line : lines) {
		std::vector<std::string> entries = split(line, delimiter);
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


	// remove empty lines before and after
	tables.erase(
		tables.begin(),
		std::find_if(tables.begin(), tables.end(), [](const auto& row) { return !row.empty(); })
	);
	tables.erase(
		std::find_if(tables.rbegin(), tables.rend(), [](const auto& row) { return !row.empty(); }).base(),
		tables.end()
	);

	bool hadError = false;

	// check for other empty lines
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

	return new std::pair<StrMatrix, StrMatrix>(table1, table2);
}

std::shared_ptr<Data> InputReader::readFile(const std::string& path) {
	bool hadError = false;
	std::ifstream file;
	file.open(path, std::ios::in);
	if (!file.is_open()) {
		std::cerr << "Die Datei konnte nicht geoeffnet werden '" << path << "'.\n"
			<< "Du befindest dich momentan im Pfad " << std::filesystem::current_path() << std::endl;
		file.close();
		return nullptr;
	}

	auto tables = readTables(file);;

	auto table1 = tables->first;
	auto table2 = tables->second;

	// collect names
	auto wgs = getNamesFromTableHeader(table1[0], "WG", 1);
	auto persons = getNamesFromTableHeader(table2[0], "Personen", 2);

	if (wgs.empty() || persons.empty()) {
		std::cerr << "In einer Tabelle wurden keine WGs oder Personen angegeben." << std::endl;
	}

	// check names
	hadError |= checkTableHeaders(table1, persons, 1, 2, "Personen");
	hadError |= checkTableHeaders(table2, wgs, 2, 1, "WG");

	if (hadError) {
		return nullptr;
	}

	// make name-mapping
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
	for (int i = 0; i < idxWg.size(); ++i) {
		values.emplace_back(std::vector<PrefPair>(idxPerson.size(), {0, 0}));
	}

	// read values
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

			values[wIdx][pIdx].personPoints = v;
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

			values[wIdx][pIdx].wgPoints = v;
		}
	}

	if (hadError) {
		return nullptr;
	}

	printTable(idxPerson, idxWg, values);

	std::cout << "WGs mit mehr als einem freien Zimmer (Lass den Namen der WG leer, wenn es keine weiteren mehr gibt):" << std::endl;
	bool done = false;
	std::vector<int> roomCounts(wgs.size(), 1);
	while (!done) {
		std::cout << "Name der WG:" << std::endl;
		std::string wgName;
		std::getline(std::cin, wgName);

		if (wgName.empty()) {
			break;
		}

		auto it = wgIdx.find(wgName);
		if (it == wgIdx.end()) {
			std::cout << "Es gibt keine WG namens " << wgName << std::endl;
			continue;
		}
		std::cout << "Anzahl freier Zimmer:" << std::endl;
		std::string numStr;
		std::getline(std::cin, numStr);
		int roomNum;
		try {
			roomNum = std::stoi(numStr);
		} catch (const std::invalid_argument& e) {
			(void)e; // just to get rid of the "unreferenced local" warning
			std::cout << "Das ist keine Zahl" << std::endl;
			continue;
		}
		if (roomNum < 1) {
			std::cout << "Die Anzhal freier Zimmer sollte mindestens 1 sein";
			continue;
		}

		roomCounts[it->second] = roomNum;
	}

	auto data = Data();
	data.idxPerson = idxPerson;
	data.idxWg = idxWg;
	data.personIdx = personIdx;
	data.wgIdx = wgIdx;
	data.values = values;
	data.roomCounts = roomCounts;

	return std::make_shared<Data>(data);
}

bool InputReader::checkTableHeaders(const std::vector<std::vector<std::string>>& table, std::unordered_set<std::string> expectedNames, const int checkTableNum, const int sourceTableNum, const std::string& errorPrefix) {
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

std::unordered_set<std::string> InputReader::getNamesFromTableHeader(const std::vector<std::string>& header, const std::string& errorPrefix, int tableNum) {
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

void InputReader::printTable(const std::vector<std::string>& headerTop, const std::vector<std::string>& headerLeft, const std::vector<std::vector<PrefPair>>& values) {
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