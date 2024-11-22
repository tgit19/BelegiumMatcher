#include "Utils.h"

std::string trim(std::string s) {
	// removes spaces at the beginning and end of the string
	s.erase(s.begin(), std::find_if(s.begin(), s.end(), [](unsigned char c) {
		return !std::isspace(c);
	}));

	s.erase(std::find_if(s.rbegin(), s.rend(), [](unsigned char c) {
		return !std::isspace(c);
	}).base(), s.end());

	return s;
}

std::vector<std::string> split(std::string const& s, char delim) {
	// divide string into vector of string based on specifiy delimitor
	if (trim(s).empty()) {
		return std::vector<std::string>();
	}

	size_t lastDelim = 0;
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

std::string padLeft(const std::string& s, int len) {
	return std::string(std::max(len - s.length(), 0ull), ' ') + s;
}

std::string padRight(const std::string& s, int len) {
	return s + std::string(std::max(len - s.length(), 0ull), ' ');
}