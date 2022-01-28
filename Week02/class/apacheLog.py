import importlib

import logCheck

importlib.reload(logCheck)


# SSH authentication failures
def apache_events(filename, service, term):

    # Call syslogCheck and return the results
    is_found = logCheck._logs(filename, service, term)

    # found list
    found = []

    # loop through the results
    for eachFound in is_found:

        # Split the results
        sp_results = eachFound.split(" ")

        # Append the split value to the found list
        found.append(sp_results[3] + " " + sp_results[0] + " " + sp_results[1])

    # Remote duplicates by converting to dict
    hosts = set(found)

    # Print results
    for eachHost in hosts:
        print(eachHost)
