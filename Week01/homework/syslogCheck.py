# Create an interface to search through syslog files
import re
import sys


def _syslog(filename, listOfKeywords):

    # Open syslog file and save as 'contents'
    with open(filename) as f:
        # Read file into 'contents'
        contents = f.readlines()

    # List to store the results
    results = []
    # For each element in syslog
    for line in contents:
        # For each element in keyword
        for eachKeyword in listOfKeywords:
            # If element 'line' contains element 'keyword'
            # Then print the occurrences
            x = re.findall(r"" + eachKeyword + "", line)
            # print(x)

            for found in x:
                # Append the returned key words to the results list
                results.append(found)

    # Check to see if there are results
    if len(results) == 0:
        print("No Results")
        sys.exit(1)

    # Sort the list
    results = sorted(results)
    # Remove duplicates (convert to set)
    results = set(results)

    return results
