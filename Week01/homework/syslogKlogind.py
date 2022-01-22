import importlib

import syslogCheck

importlib.reload(syslogCheck)


# klogind authentication failure
def klogind_fail(filename, searchTerms):

    # Call syslogCheck and return the results
    is_found = syslogCheck._syslog(filename, searchTerms)

    # found list
    found = []

    # loop through the results
    for eachFound in is_found:

        # Split the results
        sp_results = eachFound.split(" ")

        # Append the split value to the found list
        found.append(sp_results[4])

    returnedValues = set(found)

    for eachValue in returnedValues:
        print(eachValue)
