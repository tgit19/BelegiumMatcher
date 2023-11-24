#ifndef UTILS_H
#define UTILS_H

#include <vector>
#include <unordered_map>
#include <unordered_set>
#include <string>
#include <iostream>
#include <fstream>
#include <filesystem>
#include <memory>

typedef unsigned int uint;

typedef std::vector<int> IntVec;
typedef std::vector<std::vector<int>> IntMatrix;
typedef std::vector<std::vector<std::string>> StrMatrix;

std::string trim(std::string s);

/*
Splits the string at the delimiter and returns a vector of trimmed strings.
*/
std::vector<std::string> split(std::string const& s, char delim);

std::string padLeft(const std::string& s, int len);
std::string padRight(const std::string& s, int len);

#endif