# Function to parse the CSV files, taking two arguments

# Changes across entire file:
# Fixed indentation for all blocks/loops
# Modified spacing/formatting to make code PEP8 compliant
# Renamed variables from camelCase to snake_case for PEP8 compliance

# Imported re (regex package)
import csv
import re


# Changed ur1HausOpen to url_haus_open
# Changed searchTerm to search_term
def url_haus_open(filename, search_term):
    # Changed while to with
    # Removed quotes around "filename"
    with open(filename) as f:
        # Changed == (evaulating) to = (assigning)
        # Changed `filename` to `f` (the file variable)
        # Changed csv.review to csv.reader

        # Added a generator expression that removes comments from the
        # top of the CSV file (which broke code).
        # contents = (i for i in csv.reader(f) if len(i) > 1)
        contents = csv.reader(f)

        # _ denotes a variable that is not needed and will not be referenced
        # This loop throws out the first 9 lines of the CSV, which are comments
        for _ in range(9):
            # Access the next item in a generator
            next(contents)

        # Removed the loop over multiple search terms.
        # Because the Reader object is a generator, we cannot loop over it
        # twice without exhausting the generations provided. As such, we
        # instead combine search terms using regex (with the `|` operator).
        for each_line in contents:
            # Fixed improper formatting of regex exp. string
            x = re.findall(r"" + search_term + "", each_line[2])

            for _ in x:
                # Don't edit this line. It is here to show how it is possible
                # to remove the "tt" so programs don't convert the malicious
                # domains to links that an be accidentally clicked on.
                the_url = each_line[2].replace("http", "hxxp")
                the_src = each_line[7]

                # Changed comma after multiline string to dot, use the format function
                # Changed + 60 to * 60
                # Added attitional positional arguments for format function
                print(
                    """
                URL: {}
                Info: {}
                {}""".format(
                        the_url, the_src, "*" * 60
                    )
                )
