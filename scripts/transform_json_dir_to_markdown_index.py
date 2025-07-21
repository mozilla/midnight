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


def replace_between(original_str, start_marker, end_marker, replacement_str):
    start_index = original_str.find(start_marker)
    if start_index == -1:
        return original_str

    end_index = original_str.find(end_marker, start_index)
    if end_index == -1:
        return original_str

    part_before = original_str[:start_index]
    part_after = original_str[end_index + len(end_marker):]
    return part_before + replacement_str + part_after


def make_html_table_head(date):
    sthead = f"""
<thead>
  <tr>
    <th rowspan="2">test url</th>
    <th colspan="4">{date}</th>
  </tr>
  <tr>
    <th>phone</th>
    <th>phone-talkback</th>
    <th>tablet</th>
    <th>tablet-talkback</th>
  </tr>
</thead>
"""
    return sthead


def convert_dataframe_to_html_table(df, outputf, date):
    try:
        # NB escape=False required if html is embedded
        html_table_string = df.to_html(escape=False, index=False, na_rep='nan', float_format='%.1f')

        # Create a complete HTML document with the table
        # We'll use a simple HTML template with basic styling for a clean look
        html_content_base = f"""
<html lang="en">
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Results Index</title>
</head>
<body>
  <div class="table-container">
    {html_table_string}
  </div>
</body>
</html>
        """

        # Customize table elements for this data.

        # tables
        startt = "<table border"
        endt = ">"
        customtable = f"""<table>"""
        html_content1 = replace_between(html_content_base, startt, endt, customtable)

        # theads
        startw = "<thead>"
        endw = "</thead>"
        customthead = make_html_table_head(date)
        html_content2 = replace_between(html_content1, startw, endw, customthead)

        # Write the complete HTML content to the specified output file
        with open(outputf, 'w', encoding='utf-8') as f:
            f.write("## test result index \n")
            f.write("\n")
            f.write(html_content2)

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


# read sitelist file
def deserialize_sitelist_file(sitelist):
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


def shorten_platform(platform):
    short = None
    if platform == "android-15-ptablet":
        short = "tablet"
    if platform == "android-15-ptablet-talkback":
        short = "tablet-tb"
    if platform == "android-15-p8":
        short = "phone"
    if platform == "android-15-p8-talkback":
        short = "phone-tb"
    return short


# List of fails per date/platform/site/browser
chromefail = []
firefoxfail = []
def make_metadata_string(date, platform, miniurl):
    meta = f"{date}-{platform}-{miniurl}"
    return meta


# n == index, starts at 0
def create_platform_link(date, platforms, miniurl, n):
    plink = ""
    if len(platforms) > n:
        platf = platforms[n];
        metadata = make_metadata_string(date, platf, miniurl)

        # from html linking to markdown, link to the to-be-parsed html not md
        #page = f"/pages/{metadata}.md"
        page = f"pages/{metadata}.html"
        plink = f"""<a href="{page}">Y</a>"""

        # overwrite if error
        chromep = metadata in chromefail
        firefoxp = metadata in firefoxfail
        if chromep and firefoxp:
            plink = "❌ chrome, firefox"
        else:
            if chromep:
                plink = "❌ chrome"
            if firefoxp:
                plink = "❌ firefox"
    return plink


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
    date = None
    aggindex = []
    sites = deserialize_sitelist_file(sitelist)
    for site in sites:
        miniurl = None
        matchplatform = []
        for file_path in aggregate_files:
            data = deserialize_aggregate_json_file(file_path)
            if data.get('url') == site:
                date = data.get('date')
                platform = data.get('platform')
                miniurl = data.get('test')
                if not 'chrome' in data:
                    chromefail.append(make_metadata_string(date, platform, miniurl))
                if not 'firefox' in data:
                    firefoxfail.append(make_metadata_string(date, platform, miniurl))
                matchplatform.append(platform)
        if matchplatform:
            matchplatform.sort()
            print(f"{miniurl} found results for {matchplatform}")
            miniurllink = f"""<a href="{site}">{miniurl}</a>"""
            result_object = {
                'site_url': miniurllink,
                'platform1': create_platform_link(date, matchplatform, miniurl, 0),
                'platform2': create_platform_link(date, matchplatform, miniurl, 1),
                'platform3': create_platform_link(date, matchplatform, miniurl, 2),
                'platform4': create_platform_link(date, matchplatform, miniurl, 3)
            }
            aggindex.append(result_object)
        else:
            result_object = {
                'site_url': miniurllink,
                'platform1': "",
                'platform2': "",
                'platform3': "",
                'platform4': ""
            }
            aggindex.append(result_object)

    # Now, make aggindex into a data frame.
    df = pd.DataFrame(aggindex)
    ofile = f"{date}-multi-test-index.md"
    convert_dataframe_to_html_table(df, ofile, date)


# do the thing for one date
convert_aggregate_json_to_markdown_index(sitelistf, aggjdir)
