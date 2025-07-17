#!/usr/bin/env python

# run like:
# /transform_json_to_markdown_index.py ./sitelist PATH_TO_RESULTS_DIR

import pandas as pd
import json
import sys
import os
from pathlib import Path

# setup
sitelistf = sys.argv[1];
aggjdir = sys.argv[2];


def convert_datframe_to_html_table(df, outputf):
    try:
        html_table_string = df.to_html(
            index=False,               # Do not include the DataFrame index as a column
            na_rep='nan',              # Represent NaN values as 'N/A'
            float_format='%.1f'        # Format float numbers to one decimal places
        )

        # Create a complete HTML document with the table
        # We'll use a simple HTML template with basic styling for a clean look
        html_content = f"""
        <html lang="en">
          <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Metics Table</title>
          </head>
          <body>
            <div class="table-container">
            {html_table_string}
            </div>
          </body>
        </html>
        """

        # Write the complete HTML content to the specified output file
        with open(outputf, 'w', encoding='utf-8') as f:
            f.write(html_content)

    except FileNotFoundError:
        print(f"Error: One of the files was not found. Please check paths.", file=sys.stderr)
        sys.exit(1)
    except json.JSONDecodeError:
        print(f"Error: Could not decode JSON from '{inputf}'. Ensure it's a valid JSON file.", file=sys.stderr)
        sys.exit(1)
    except pd.errors.EmptyDataError:
        print(f"Error: No data to parse from '{inputf}'. The JSON file might be empty.", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"An unexpected error occurred: {e}", file=sys.stderr)
        sys.exit(1)


def deserialize_sitelist_file(sitelist):
    # read sitelist file
    if os.path.exists(sitelistf):
        try:
            with open(sitelistf, 'r') as f:
                sites = [line.strip() for line in f if line.strip()]
                if not sites:
                    print(f"Error: nothing in sitelist file '{sitelistff}'")
                    sys.exit(3)
                print(f"input sitelist file '{sitelistf}' found of length {len(sites)}")
                return sites

        except Exception as e:
            print(f"Error: failed to read the site file, as : {e}")
            return
    else:
        print(f"Error: input file '{sitelistf}' not found")
        sys.exit(1)


def deserialize_aggregate_json_file(jsonf):
    """
    Reads an aggregate json file and returns the json content as data
    Args:
        jsonf (str): The path to the input aggregate JSON file.
    """
    if os.path.exists(jsonf):
        try:
            with open(jsonf, 'r', encoding='utf-8') as f:
                data = json.load(f)
                # Ensure the JSON data is a list of dictionaries or a dictionary
                # that can be directly converted to a DataFrame
                if not isinstance(data, (list, dict)):
                    print(f"Error: JSON data in '{jsonf}' is not in a recognized format for DataFrame creation (list or dictionary).", file=sys.stderr)
                    sys.exit(4)
                #print(f"input json aggregate data file '{jsonf}' found and usable")
                return data

        except Exception as e:
            print(f"Error: failed to read the data file, as : {e}")
            return
    else:
        print(f"Error: input file '{jsonf}' not found")
        sys.exit(2)


def convert_aggregate_json_to_markdown_index(sitelist, jdir):
    """
    Reads data files in directory and orders into a sitelist json file for conversion to
    python dataframe and then html table.
    Args:
        sitelist (str): The path to the input sitelist text file, one site per line
        jdir (str): The path to the directory containing aggregate json files
    """

    # Find all files in the directory that end with "-aggregate.json"
    # aggregate json file has fields: platform, date, test, url.
    # aggregate json filename schema: date-platform-test-aggregate.json
    # NB: The .glob() method returns a generator, so we convert it to a list
    pdir = Path(jdir)
    aggregate_files = list(pdir.glob('*-aggregate.json'))

    # Order index in same was as the (minimized-url) sorted sitelist.
    aggindex = []
    sites = deserialize_sitelist_file(sitelist)
    for site in sites:
        miniurl = None
        date = None
        matchplatform = []
        for file_path in aggregate_files:
            data = deserialize_aggregate_json_file(file_path)
            if data.get('url') == site:
                platform = data.get('platform')
                miniurl = data.get('test')
                date = data.get('date')
                matchplatform.append(platform)
        if matchplatform:
            matchplatform.sort()
            print(f"{miniurl} found results for {matchplatform}")

            #miniurllink = f"[{miniurl}]({site})"
            miniurllink = f'<a href="{site}">{miniurl}</a>'
            result_object = {
                'site_url': miniurllink,
                'date': date,
                'platform1': matchplatform[0],
                'platform2': matchplatform[1] if len(matchplatform) > 1 else "",
                'platform3': matchplatform[2] if len(matchplatform) > 2 else "",
                'platform4': matchplatform[3] if len(matchplatform) > 3 else ""
            }
            aggindex.append(result_object)
        else:
            result_object = {
                'site_url': miniurllink,
                'date': "",
                'platform1': "",
                'platform2': "",
                'platform3': "",
                'platform4': ""
            }
            aggindex.append(result_object)

    # Now, make aggindex into a data frame.
    df = pd.DataFrame(aggindex)
    convert_datframe_to_html_table(df, "multi-test-index-by-date.html")


# do the thing
convert_aggregate_json_to_markdown_index(sitelistf, aggjdir)
