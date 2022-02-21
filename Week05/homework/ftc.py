# CLI program to parse Forensic Toolkit Collections

import argparse
import csv
import os
import sys

import yaml


# Parse arguments for our program
def parse_args():
    # parser
    parser = argparse.ArgumentParser(
        description="Parses Forensic Toolkit Collections from a directory",
        epilog="Developed by Reed Simon, 2022-02-21",
    )

    # Add argument to ftc.py
    parser.add_argument(
        "-d",
        "--directory",
        required=True,
        help="Directory that contains the collections files.",
    )

    # Add argument to ftc.py
    parser.add_argument(
        "-s",
        "--search",
        required=True,
        help="Name of YAML document containing search strings.",
    )

    # Parse arguments
    args = parser.parse_args()

    # Check if the dir argument is a directory
    if not os.path.isdir(args.directory):
        print(f"Invalid directory => {args.directory}")
        sys.exit()

    # Return parsed args
    return args


# Walk a directory and append the contents of each file to a list
def walk_csv_dir(rootdir):
    # List to save files
    f_list = []

    # Crawl through the provided directory
    for root, _, filenames in os.walk(rootdir):
        for f in filenames:
            f_list.append(root + "/" + f)

    # List to save file contents
    csv_contents = []

    # Iterate through the list of files
    for file in f_list:
        with open(file, "r", encoding="utf-8") as f:
            # Read in each line as a list
            # ID, arguments, hostname, name, path, pid, username
            reader = csv.DictReader(f)
            for row in reader:
                csv_contents.append(row)

    return csv_contents


# Load all yaml documents from search terms
def load_yaml(file, document):

    # Add all our rules to a list to by pass dictionary key/value names
    with open(file, "r", encoding="utf-8") as f:
        yaml_rules = list(yaml.safe_load_all(f))

    # Iterate through the list of rules and select desired rule
    for rule in yaml_rules:
        if document in rule.keys():
            return rule[document]

    # If reached here, document does not exist
    print(f"Error: Specified document {document} does not exist in search terms")
    sys.exit()


def main():
    args = parse_args()

    contents = walk_csv_dir(args.directory)

    yaml_data = load_yaml("searchTerms.yaml", args.search)

    # Output attach descriptons

    # Iterate through each line in the file contents
    for line in contents:
        # Iterate through each search term in the yaml file
        for term in yaml_data.get("search"):
            # Check if the search term is in the line
            if term in line.values():
                # Output the line's information
                print(
                    "Type: {} | {} | {} | {} | {} | {} | {}".format(
                        yaml_data["type"],
                        line["arguments"],
                        line["hostname"],
                        line["name"],
                        line["path"],
                        line["pid"],
                        line["username"],
                    )
                )


if __name__ == "__main__":
    main()
