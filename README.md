# Belegium Matcher
A little program developed to find the best solution of matching persons to groups given a rating for each.
The program uses the Hungarian Algorithm which always finds the optimal solution.

## Usage
1. Collect the Data in a csv-file. It should look like this:

    |         | Person1 | Person2 | Person3 |
    | -------:|:-------:|:-------:|:-------:|
    | WG1     | 6       | 12      | 8      |
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

## Build
If you want to build the project from source:
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
