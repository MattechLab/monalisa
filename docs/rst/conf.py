import os
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
    'sphinx.ext.mathjax',
    'sphinx.ext.autodoc',
]

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

# Convert the relative path to an absolute path
absolute_path = os.path.abspath(matlab_src_dir)

# Print the absolute path
print(f"the matlab src absolute_path is: {absolute_path}")

templates_path = ['../_templates']
exclude_patterns = ['../_build', 'Thumbs.db', '.DS_Store']

matlab_short_links = True  # Use MATLAB-like shorter links in documentation
matlab_auto_link = "basic"  # Automatically link references to functions/classes
primary_domain = "mat" # Set MATLAB as the primary domain

# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

html_theme = 'alabaster'
html_static_path = ['../_static']

# Add custom CSS and JavaScript files
html_css_files = ['custom-navigation.css', 'custom-button.css', 'important.css', 'tip.css']

html_js_files = ['custom.js']
