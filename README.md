# Belegium Matcher
A little program developed to find the best solution of matching persons to groups given a rating for each.
The program uses the Hungarian Algorithm which always finds the optimal solution.

## Usage
1. Collect the Data in a csv-file. It should look like this:

    |         | Person1 | Person2 | Person3 |
    | -------:|:-------:|:-------:|:-------:|
    | WG1     | 6       | 12      | 18      |
    | WG2     | 8       | 13      | 7       |
    | WG3     | 10      | 15      | 12      |
    |         |         |         |         |
    |         | WG1     | WG2     | WG3     | 
    | Person1 | 10      | 10      | 8       |
    | Person2 | 11      | 12      | 7       |
    | Person3 | 8       | 14      | 9       |

    There must be an empty line between the first and second table!

2. Download the .exe from the latest Release.
3. Either drag the csv-file on the exe or run the program with the file as argument.\

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
2. Generate project-files for whatever you use cmake, make, visual studio, xcode ...
3. Build
4. Executables are in /bin
