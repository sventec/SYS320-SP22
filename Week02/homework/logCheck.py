# Create an interface to search through syslog files
import re
import sys

import yaml

# Open the Yaml file
try:
    with open("searchTerms.yaml", "r") as yf:
        # Because there are multiple documents in the yaml file,
        # we must use safe_load_all, and convert the resultant
        # generator into a list.
        keywords = list(yaml.safe_load_all(yf))
# EnvironmentError typically IO related
except EnvironmentError as e:
    print(e.strerror)


def _logs(filename, service, term):

    # Query the yaml file for the 'term ' or direction and
    # retrieve the strings to search on.

    # Since the safe_load_all function above is a list, we must
    # iterate over the documents in the list and only save values
    # for the relvant document.
    terms = [key[service][term] for key in keywords if service in key][0]

    listOfKeywords = terms.split(",")

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
