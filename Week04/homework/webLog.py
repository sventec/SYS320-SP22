import importlib
import os
import sys
from argparse import ArgumentParser

import yaml

import logCheck

importlib.reload(logCheck)


# Filtered web log events
def web_events(contents, service):

    is_found = []

    # Open the Yaml file
    try:
        with open("searchTerms.yaml", "r") as yf:
            # Because there are multiple documents in the yaml file,
            # we must use safe_load_all, and convert the resultant
            # generator into a list.
            keywords = list(yaml.safe_load_all(yf))
            # Trim to just the search term we want
            keywords = [k for k in keywords if service in k][0]
    # EnvironmentError typically IO related
    except EnvironmentError as e:
        print(e.strerror)

    # For each search term in the service
    for term in keywords[service]:
        # Call syslogCheck and return the results
        for result in logCheck._logs(contents, keywords, service, term):
            is_found.append(result)

    # found list
    found = []

    # loop through the results
    for eachFound in is_found:

        # For each

        # Split the results
        sp_results = eachFound.split(" ")

        # Append the split value to the found list
        found.append(sp_results[8] + " " + sp_results[9] + " " + sp_results[6])

    # Remote duplicates by converting to dict
    hosts = set(found)

    # Print results
    for eachHost in hosts:
        print(eachHost)


def main():
    # parser
    parser = ArgumentParser(
        description="Traverses a directory of log files and searches for terms",
        epilog="Developed by Reed Simon, 20220215",
    )

    # Add argument for directory to search
    parser.add_argument(
        "-d",
        "--directory",
        required=True,
        help="Directory that you want to traverse.",
    )

    # Add argument for search book
    parser.add_argument(
        "-s",
        "--search",
        required=True,
        help="Name of YAML book of search terms to check for in log files.",
    )

    # Parse arguments
    args = parser.parse_args()

    directoryname = args.directory

    # In our story, we will traverse a directory
    # Check if the argument is a directory
    if not os.path.isdir(directoryname):
        print(f"Invalid directory => {directoryname}")
        sys.exit()

    # Loop through all log files in a directory
    for filename in os.listdir(directoryname):
        # Open log file
        with open(directoryname + "/" + filename) as f:
            # Read contents of log file
            contents = f.readlines()
            # Call search function on log file
            web_events(contents, args.search)

    # Call our search function
    # web_events(args.directory, args.search)


if __name__ == "__main__":
    main()
