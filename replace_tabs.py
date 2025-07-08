import os
import sys

def replace_tabs_in_file(file_path):
    with open(file_path, 'r') as file:
        content = file.read()
    
    content = content.replace('\t', '    ')
    
    with open(file_path, 'w') as file:
        file.write(content)

# Function to scan directory and subdirectories for specified file types
def scan_and_replace_tabs(directory):
    for root, dirs, files in os.walk(directory):
        for filename in files:
            if (filename.endswith('.cpp') or filename.endswith('.h') or filename.endswith('.cs')) and \
               not (filename.endswith('Generated.cs') or filename.endswith('AutoGen.h') or filename.endswith('AutoGen.cpp')) and \
               not (filename.startswith('ccl') and filename.endswith('Const.h')):
                replace_tabs_in_file(os.path.join(root, filename))

# Check if the directory is provided as a command line argument
if len(sys.argv) != 2:
    print("Usage: python replace_tabs.py <directory>")
else:
    directory = sys.argv[1]
    scan_and_replace_tabs(directory)
    print("Tabs have been replaced with 4 spaces in all .cpp, .h, and .cs files in the specified directory and its subdirectories, excluding *Generated.cs, *AutoGen.h, *AutoGen.cpp, and files starting with 'ccl' and ending with 'Const.h'.")
