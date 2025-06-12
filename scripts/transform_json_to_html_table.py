#!/usr/bin/env python

# run like:
# /transform_json_to_md_table.py ./input.json ./output.html

import pandas as pd
import json
import sys
import os

# setup
infile = sys.argv[1];
outfile = sys.argv[2];


def convert_json_to_html_table(inputf, outputf):
    """
    Reads data from a JSON file, converts it into a Pandas DataFrame,
    and then generates an HTML file containing a styled table of that data.

    Args:
        inputf (str): The path to the input JSON file.
        outputf (str): The path to the output HTML file.
    """
    
    # check inputs
    if os.path.exists(inputf):
        print(f"input data file '{inputf}' found")
    else:
        print(f"Error: input json file '{inputf}' not found")
        sys.exit(1)

    if os.path.exists(outputf):
        print(f"Error: output html file '{outputf}' already exists")
        sys.exit(1)
    else:
        print(f"output html file '{outputf}' created")

    # parse data info df and export.        
    try:
        # 1. Read the JSON data from the input file
        with open(inputf, 'r', encoding='utf-8') as f:
            data = json.load(f)

        # Ensure the JSON data is a list of dictionaries or a dictionary
        # that can be directly converted to a DataFrame
        if not isinstance(data, (list, dict)):
            print(f"Error: JSON data in '{inputf}' is not in a recognized format for DataFrame creation (list or dictionary).", file=sys.stderr)
            sys.exit(1)

        # 2. Convert the JSON data into a Pandas DataFrame
        df = pd.DataFrame(data)

        # 3. Convert the DataFrame to an HTML table string
        # Added Tailwind CSS classes for better default styling if included in a web project
        # Using inline styling here for a self-contained HTML file.
        html_table_string = df.to_html(
            index=False,               # Do not include the DataFrame index as a column
            na_rep='N/A',              # Represent NaN values as 'N/A'
            float_format='%.2f',       # Format float numbers to two decimal places
            classes='min-w-full divide-y divide-gray-200 shadow-md rounded-lg overflow-hidden' # Example classes (would need Tailwind setup to fully apply)
        )

        # 4. Create a complete HTML document with the table
        # We'll use a simple HTML template with basic styling for a clean look
        html_content = f"""
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Data Report from JSON</title>
    <!-- Basic styling for the table -->
    <style>
        body {{
            font-family: 'Inter', sans-serif;
            margin: 2rem;
            background-color: #f7f7f7;
            color: #333;
        }}
        h1 {{
            color: #2c3e50;
            text-align: center;
            margin-bottom: 1.5rem;
        }}
        .table-container {{
            margin: 2rem auto;
            max-width: 90%;
            overflow-x: auto; /* Allows horizontal scrolling on small screens */
            border-radius: 0.5rem;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            background-color: #ffffff;
        }}
        table {{
            width: 100%;
            border-collapse: collapse;
            text-align: left;
            border-radius: 0.5rem; /* Rounded corners for the table */
        }}
        th, td {{
            padding: 0.75rem 1rem;
            border-bottom: 1px solid #e2e8f0;
            white-space: nowrap; /* Prevent content from wrapping */
        }}
        th {{
            background-color: #edf2f7;
            font-weight: 600;
            color: #4a5568;
            text-transform: uppercase;
            font-size: 0.875rem;
        }}
        tr:last-child td {{
            border-bottom: none;
        }}
        tbody tr:hover {{
            background-color: #f0f4f8; /* Light hover effect */
        }}
        /* Specific rounded corners for first/last cells */
        table thead tr:first-child th:first-child {{ border-top-left-radius: 0.5rem; }}
        table thead tr:first-child th:last-child {{ border-top-right-radius: 0.5rem; }}
        table tbody tr:last-child td:first-child {{ border-bottom-left-radius: 0.5rem; }}
        table tbody tr:last-child td:last-child {{ border-bottom-right-radius: 0.5rem; }}
    </style>
</head>
<body>
    <h1>Index</h1>

    <div class="table-container">
        {html_table_string}
    </div>
</body>
</html>
        """

        # 5. Write the complete HTML content to the specified output file
        with open(outputf, 'w', encoding='utf-8') as f:
            f.write(html_content)

        print(f"Successfully converted '{inputf}' to '{outputf}'.")

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


convert_json_to_html_table(infile, outfile)
