import os

# Path to your src directory
src_dir = '../src'

# Convert the relative path to an absolute path
src_dir = os.path.abspath(src_dir)

# Output .rst file
rst_file_path = './rst/3_api.rst'

# Convert the relative path to an absolute path
rst_file_path = os.path.abspath(rst_file_path)

print(src_dir,rst_file_path)

# Title characters for each nesting level
title_chars = ['=', '-', '^', '~']

def underline_title(title, level):
    """
    Generate an underline for the title based on the nesting level.
    """
    char = title_chars[min(level, len(title_chars) - 1)]  # Use the appropriate character
    underline = char * max(len(title), 3)  # Ensure at least 3 characters
    return f"{title}\n{underline}\n"

def generate_rst_for_folder(folder_path, level=0, parent=""):
    """
    Generate the RST content for a given folder and its subfolders.
    Handles cases where folders contain both files and subfolders.
    """
    folder_name = os.path.basename(folder_path)
    print(f"Processing folder: {folder_name}, level: {level}")
    rst_content = ""
    
    # First, gather files and subfolders
    files = []
    subfolders = []
    
    for item in sorted(os.listdir(folder_path), key=str.lower):
        item_path = os.path.join(folder_path, item)
        
        if os.path.isdir(item_path):
            subfolders.append(item_path)
        elif item.endswith('.m'):
            files.append(item)
    
    # Document the folder if it contains files or subfolders
    if files or subfolders:
        if rst_content:
            rst_content += "\n"  # Ensure there is a blank line before the title
        rst_content += underline_title(folder_name, level)
    
    if files:
        # Construct the module path
        module_path = f"{parent}.{folder_name}" if parent else folder_name
        
        # Remove the exact prefix 'src.' if it exists
        if module_path.startswith("src."):
            module_path = module_path[len("src."):]
            
        rst_content += f".. automodule:: {module_path}\n"
        rst_content += f"    :members:\n"
        rst_content += f"    :undoc-members:\n"
        rst_content += f"    :show-inheritance:\n\n"
    
    # Process subfolders recursively
    for subfolder in subfolders:
        subfolder_name = os.path.basename(subfolder)
        module_parent = f"{parent}.{folder_name}" if parent else folder_name
        rst_content += generate_rst_for_folder(subfolder, level + 1, module_parent)
    
    return rst_content

def write_rst_file():
    """
    Write the generated RST content to the file.
    """
    # Open the .rst file for writing
    with open(rst_file_path, 'w') as rst_file:
        # Add the main title
        rst_content = underline_title("API", 0)
        
        # Generate RST for the root 'src' folder
        rst_content += generate_rst_for_folder(src_dir, level=0, parent="")
        
        # Write content to the file
        rst_file.write(rst_content)
        print(f"Generated RST file: {rst_file_path}")

# Run the function to generate the RST file
write_rst_file()
