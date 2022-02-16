# Create an interface to search through syslog files
import os
import re
import sys


def _logs(contents, yaml_data, service, term):

    # Query the yaml file for the 'term ' or direction and
    # retrieve the strings to search on.

    # Since the safe_load_all function above is a list, we must
    # iterate over the documents in the list and only save values
    # for the relvant document.
    # terms = [key[service][term] for key in yaml_data if service in key][0]
    terms = yaml_data[service][term]

    keys = terms.split(",")

    # List to store the results
    results = []
    # For each element in syslog
    for line in contents:
        # For each element in keyword
        # for key in keys:
        # If element 'line' contains element 'keyword'
        # Then print the occurrences
        # print(keys[0])
        x = re.findall(r"" + keys[0] + "", str(line))

        for found in x:
            # Append the returned key words to the results list
            results.append(found)

    # Sort the list
    results = sorted(results)
    # Remove duplicates (convert to set)
    results = list(set(results))

    return results
