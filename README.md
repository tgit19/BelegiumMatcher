# Belegium Matcher
A little program developed to find the best solution of matching persons to groups given a rating for each.
The program uses the Hungarian Algorithm which always finds the optimal solution.

## Usage
1. Collect the Data in a csv-file. It should look like this:

    |         | Person1 | Person2 | Person3 |
    | -------:|:-------:|:-------:|:-------:|
    | WG1     | 6       | 12      | 8       |
    | WG2     | 8       | 13      | 7       |
    | WG3     | 10      | 15      | 12      |
    |         |         |         |         |
    |         | WG1     | WG2     | WG3     |
    | Person1 | 10      | 10      | 8       |
    | Person2 | 11      | 12      | 7       |
    | Person3 | 8       | 14      | 9       |

    There must be an empty line between the first and second table!

2. Download the .exe from the folder bin\Release-windows-x86_64\Belegium_Matcher.exe
3. Open a command prompt in the directory of the executable and write: 
"
Belegium_Matcher.exe <name_of_csv_file> <(optional) number_of_extra_points_for_direct_match>
" (without the "")
where <name_of_csv_file> gets replaced by the name of the csv file
(it must be in the same directory or insert the relative path to the data)
e.g. in the base folder of the directory:
.\bin\Release-windows-x86_64\Belegium_Matcher.exe .\tests\t2.csv 7

4. There are 3 results using different heuristics.
    You see lists of person-WG-pairs with their rating:
    ```
    Solution 1:
    (WG3;Person1;10/8) (WG2;Person2;13/12) (WG1;Person3;18/8)
    Solution 2:
    (WG3;Person1;10/8) (WG2;Person2;13/12) (WG1;Person3;18/8)
    Solution 3:
    (WG3;Person1;10/8) (WG2;Person2;13/12) (WG1;Person3;18/8)
    ```

    The algorithm generally calculates a value for each pairing and finds the solution with the maximum sum.\
    First, a 15/15 pair is upgraded to a 25/25 pair, and a 0 pair is downgraded to -100/-100.\
    This makes it extremely unlikely that a 0 pair will be selected, because all other solutions would have to be worse.\
    A 15/15 pair is very likely to be selected, but not necessary, because there can be better solutions without a specific perfect match.

   - Solution 1 uses a+b to score the pairs.
   - Solution 2 uses a\*b (result is negated if a or b is -100) This results in A good pairs like 14/14 having more influence on the solution than a 12/12.
   - Solution 3 uses a\*b - (|a-b| / 3), so a 10/4 pair is worse than a 7/7 pair because it subtracts the difference of the scores multiplied by a reasonable factor.

## Build
If you want to build the old C++ project from source:
1. Install [premake](https://premake.github.io/)
    - download for windows (and add it to environment path)
2. Generate project-files for whatever you use cmake, make, visual studio, xcode ...
    - (install MSBuild by downlaoding the visual studio build tools 2022
    (and add it to environment path))
3. Build
    - premake5 vs2022
    - MSBuild Belegium_Matcher.sln /p:Configuration=Release /p:Platform="x64"
4. Executables are in /bin
    - execute: see 3.
    - e.g. .\bin\Release-windows-x86_64\Belegium_Matcher.exe .\tests\t2.csv 7

To compile the flutter project from the source code, follow these steps:

1. Install [Flutter](https://flutter.dev)
2. Clone the `BelgiumMatcher` repository
3. Run `cd app` to enter the app directory
4. Run `flutter pub get` to download dependencies
5. Run `flutter run` to start the app