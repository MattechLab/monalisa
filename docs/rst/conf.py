# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information

project = 'Monalisa'
copyright = '2024, Bastien Milani'
author = 'Bastien Milani'
release = '0.1.0'

# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration

# conf.py

extensions = [
    'sphinxcontrib.matlab',
    'sphinx.ext.mathjax']

mathjax3_config = {
    'tex': {
        'inlineMath': [['$', '$'], ['\\(', '\\)']],
        'displayMath': [['$$', '$$'], ['\\[', '\\]']],
    },
    "TeX": {
        "Macros": {
            "coloneqq": r"\mathrel{\mathpalette\coloneqq@{}}",
            "parallel": r"\parallel",
            # Add other macros if needed
        
        }
    },
}

# Define the relative path to the source directory
matlab_src_dir = '../../src'

# Print for verification (optional)
print(f"matlab_src_dir set to: {matlab_src_dir}")
matlab_src_dir = '/path/to/your/matlab/code'  # Adjust this path

templates_path = ['_templates']
exclude_patterns = ['_build', 'Thumbs.db', '.DS_Store']

primary_domain = "mat"

# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

html_theme = 'alabaster'
html_static_path = ['_static']

# Add custom CSS and JavaScript files
html_css_files = ['custom-navigation.css', 'custom-button.css']

html_js_files = ['custom.js']