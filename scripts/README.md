# LeetCode Problem Data Management

This tool helps you manage LeetCode problem data using a spreadsheet and converts it to the JSON format required by the StudyLeetcodeApp.

## Setup

1. Install Python dependencies:
```bash
pip install -r requirements.txt
```

2. Create a Google Sheet or Excel file with the following columns:
   - `category` (required): The problem category (e.g., "Two Pointer", "Binary Tree")
   - `name` (required): Problem name
   - `difficulty` (required): One of "Easy", "Medium", "Hard"
   - `description` (required): Problem description
   - `snippets` (required): Code snippets, one per line
   - `function` (required): Function signature
   - `inputs` (required): Comma-separated list of input examples
   - `outputs` (required): Comma-separated list of output examples
   - `time_complexity_options` (required): Comma-separated list of time complexity options
   - `space_complexity_options` (required): Comma-separated list of space complexity options
   - `correct_time_complexity` (required): Correct time complexity
   - `correct_space_complexity` (required): Correct space complexity

## Example Spreadsheet Format

| category | name | difficulty | description | snippets | function | inputs | outputs | time_complexity_options | space_complexity_options | correct_time_complexity | correct_space_complexity |
|----------|------|------------|-------------|----------|----------|--------|---------|------------------------|-------------------------|------------------------|-------------------------|
| Two Pointer | Two Sum | Easy | Given an array... | hashmap = {}\nfor num in array:\nif target - num in hashmap: | def twoSum(array, target): | [2,7,11,15], 9 | [0,1] | O(n²),O(n),O(n log n),O(1) | O(1),O(n),O(n!),O(n log n) | O(n) | O(n) |

## Usage

1. Save your spreadsheet as either:
   - Excel file (.xlsx)
   - CSV file (.csv)

2. Run the conversion script:
```bash
# For Excel file
python spreadsheet_to_json.py path/to/your/spreadsheet.xlsx

# For CSV file
python spreadsheet_to_json.py path/to/your/spreadsheet.csv

# To specify a different output directory
python spreadsheet_to_json.py path/to/your/spreadsheet.xlsx --output-dir custom/path
```

## Validation

The script performs the following validations:
- Difficulty must be one of: Easy, Medium, Hard
- Time/Space complexity must be valid (e.g., O(1), O(n), O(n²), etc.)
- Snippets must not be empty
- Inputs and outputs must match in number
- All required fields must be present

## Tips for Spreadsheet Usage

1. **Copy-Paste from LeetCode**:
   - Copy problem description directly from LeetCode
   - Use newlines in the snippets column for multiple code lines
   - Use commas to separate multiple inputs/outputs

2. **Formulas**:
   - Use data validation for difficulty (Easy/Medium/Hard)
   - Use data validation for complexity options
   - Use formulas to ensure inputs/outputs match

3. **Collaboration**:
   - Use Google Sheets for real-time collaboration
   - Create a template sheet for others to copy
   - Use comments to discuss problem details

## Output

The script will:
1. Create a directory for each category if it doesn't exist
2. Generate a `problems.json` file in each category directory
3. Print warnings for any validation issues
4. Show a summary of processed problems

## Troubleshooting

Common issues and solutions:
1. **Invalid difficulty**: Make sure to use exactly "Easy", "Medium", or "Hard"
2. **Invalid complexity**: Use standard notation (O(1), O(n), O(n²), etc.)
3. **Mismatched inputs/outputs**: Ensure each input has a corresponding output
4. **Empty snippets**: Make sure to include at least one code snippet
5. **File not found**: Check the path to your spreadsheet file 