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

    There must be a line without data between the first and second table!

2. Open that file with the executable.

2.a Open a command prompt in the directory of the executable and write: 
"
<executable> <(optional) options...> <name_of_csv_file>
where <name_of_csv_file> gets replaced by the name of the csv file
(it must be in the same directory or insert the relative path to the data)
e.g. in the base folder of the directory on windows:
.\Belegium_Matcher.exe --extra 7 .\tests\t2.csv

2.b Open the executable and select your file with the GUI.

3. There are 4 results using different heuristics.
    You see lists of person-WG-pairs with their rating.
    
    The algorithm generally calculates a value for each pairing and finds the solution with the maximum sum.\
    First, a 15/15 pair is upgraded to a 25/25 pair, and a 0 pair is downgraded to -100/-100.\
    This makes it extremely unlikely that a 0 pair will be selected, because all other solutions would have to be worse.\
    A 15/15 pair is very likely to be selected, but not necessary, because there can be better solutions without a specific perfect match.

   - Solution 1 uses a+b to score the pairs.
   - Solution 2 uses a\*b (result is negated if a or b is -100) This results in A good pairs like 14/14 having more influence on the solution than a 12/12.
   - Solution 3 uses sign(a)\*sign(b)\*a\*b to score the pairs.
   - Solution 4 uses a\*b - (|a-b| / 3), so a 10/4 pair is worse than a 7/7 pair because it subtracts the difference of the scores multiplied by a reasonable factor.

### Options:
- `--help`  
  Show usage information.
  
- `--extra <number>`  
  Specify an optional number of extra points for direct match (default: 10).
  
- `--ff`  
  Enable fast mode, which skips as many interactions as possible and minimizes the output.
  
- `--matrix`  
  When used with `--ff`, don't hide matrices.

### Arguments:
- `FILE`  
  (optional) The file to be used with the program. The program also provides a button to select a file.

## Build
To compile the flutter project from the source code, follow these steps:

1. Install [Flutter](https://flutter.dev)
2. Clone the `BelgiumMatcher` repository
3. Run `cd app` to enter the app directory
4. Run `flutter pub get` to download dependencies
5. Run `flutter run` to start the app