#include "Hungarian.h"

int main(int argc, char** argv) {
	Hungarian h{};

	Hungarian::MatI values = {
		{82, 83, 69, 92, 30, 54},
		{77, 37, 49, 92, 20, 78},
		{11, 69, 5, 86, 53, 23},
		{80, 90, 98, 23, 98, 120},
		{8, 90, 98, 23, 98, 120}
	};

	auto result = h.solveMax(values);

	std::cout << result << std::endl;

	return 0;
}