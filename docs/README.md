## Setting Up the Virtual Environment for the documentation
```bash
# Clone the repository
git clone <repository-url>
cd <repository-directory>

# Create and activate the virtual environment
conda create --name monalisadoc python=3.8
conda activate monalisadoc

# Install dependencies
pip install sphinx sphinxcontrib-matlabdomain
```

You are know ready to edit the documentation. If you want to have an understanding on how sphinx works look at their doc: https://www.sphinx-doc.org/en/master/usage/quickstart.html. It is basically a nice tool to build the documentation html files for your library, to later host on a website. The concept is similar to our SOPS, in the sense that we need to edit some text files that are automatically interpreted. Here is a primer of the syntax for .res files: https://www.sphinx-doc.org/en/master/usage/restructuredtext/basics.html. But you can always ask for help to chatGPT.

## Basic Usage: How to write/edit the documentation
You can see in the index.rst file a toc tree
```bash
.. toctree::
   :maxdepth: 2
   :caption: Contents:

   coil_sensitivity_map
   mythosis_prepare_data
   writing_reconstruction_script
```

Here is defined the basic structure of the documentation. To name, for example coil_sensitivity_map, a .rst file is associated with the same name. You can have a look at any of the .rst file, and compare it to the documentation, to understand what is going on. 


## Basic Usage: How to build the html files
Once you did some modification to the documentation, to apply those modification to the html files, you can simply run
```bash
cd docs/
make html
```

## Basic Usage: How visualize documentation (html file)

```bash
cd _build/html
open index.html   # On macOS
start index.html  # On Windows
```