Ciao Jaime,

This is what I wrote to generate an RST with all our packages.

I am not sure this is a good solution it was just that I could
not find a better one (Initially I thought it was done automatically
$ by the library and I could simply point to the src directory,
but I did not find anything).

Some of the modules seems to be working nicely, e.g., including:
rawDataReader
-------------
.. automodule:: rawDataReader
    :members:
    :undoc-members:
    :show-inheritance:

ismrmrd
^^^^^^^
.. automodule:: rawDataReader.ismrmrd
    :members:
    :undoc-members:
    :show-inheritance:

siemens
^^^^^^^
.. automodule:: rawDataReader.siemens
    :members:
    :undoc-members:
    :show-inheritance:

In the .rst file, nicely display some of the docstrings from the matlab files.
(Well not so nicely since we need to change the docstring, but ok XD )

However if we try to run on the complete .rst file there are errors. 
I guess it's for you to find out, since I did not manage this morning on the train.

Good Luck,

Mauro