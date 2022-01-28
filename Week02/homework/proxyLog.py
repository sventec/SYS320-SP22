import importlib

import logCheck

importlib.reload(logCheck)


# A generic filter function that can be used for both tasks
def _proxy_events(filename, service, term):

    # Call syslogCheck and return the results
    is_found = logCheck._logs(filename, service, term)

    # Remove duplicates by converting to set, and return the set
    return set(is_found)


# A function to extract tx/rx info from closed messages
def proxy_bytes(filename, service, term):
    # First get the hosts using our filter function
    hosts = _proxy_events(filename, service, term)

    # Creat the empty list of found items
    found = []

    # Calculate max host executable name length
    max_len = max([len(h[0]) for h in hosts])

    # Iterate through our hosts
    for host in hosts:

        # Append the formatted host values
        found.append(f"{host[0] : >{max_len}} | {host[1]}, {host[2]}")

    # Iterate through results and print
    for entry in set(found):
        print(entry)


# A function to extract file info from opened messages
def proxy_opened(filename, service, term):
    # First get the hosts using our filter function
    hosts = _proxy_events(filename, service, term)

    # Creat the empty list of found items
    found = []

    # Calculating the max lengths to generate pretty output
    max_len = {}

    # Create function for finding max length
    def get_max(idx):
        return max([len(h.split(" ")[idx]) for h in hosts])

    # Calculate max host executable name length
    max_len["host"] = get_max(2)
    # Calculate max URL length
    max_len["addr"] = get_max(4)

    # Iterate through our hosts
    for host in hosts:

        # Split the host entry on each space
        sp_results = host.split(" ")

        # Appent the split value to the found list
        # noqa: W503
        found.append(
            f"{sp_results[2] : >{max_len['host']}}"
            + " | "
            + f"{sp_results[4] : ^{max_len['addr']}}"
            + " | "
            + sp_results[8]
        )

    # Print header
    print(
        f"{'Executable' : >{max_len['host']}}"
        + " | "
        + f"{'Address' : ^{max_len['addr']}}"
        + " | "
        + "Proxy"
    )

    # Iterate through results and print
    for entry in set(found):
        print(entry)
