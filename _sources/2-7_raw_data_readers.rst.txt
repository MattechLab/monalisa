Reading Raw Data
================

Before any reconstruction or analysis, we need to parse k-space raw data into MATLAB objects. However, different users may work with different raw data formats — such as Siemens Twix or ISMRMRD.

Monalisa provides two ready-to-use readers for these formats:
- Siemens raw data (Twix format)
- ISMRMRD format

If your data is in another format, the simplest solution is to **convert it to ISMRMRD**.

**Basic Usage**
---------------

Using the data readers is easy. Monalisa provides the ``createRawDataReader`` function, which automatically detects the file format and returns the appropriate reader object:

.. code-block:: matlab

   f = '/your/path/to/raw_data/rawdata.fileExtension';
   autoFlag = false;      % Set to true to enable interactive validation
   % Automatically create the appropriate reader
   reader = createRawDataReader(f, autoFlag);

It is probable that the parser cannot correctly identify the metadata correctly, since different sequence implementation follow different conventions. That is why we prompt the user with a validation table where it is fundamental to correct any wrong entries:

.. image:: ../images/mitosius/param_extract.png

Once the values in the yellow columns are selected, click confirm, to create the reader object. This reader object is passed as input to Monalisa functions, which then use it internally to access raw data and metadata.

**Advanced Details for Developers**
-----------------------------------

Monalisa handles raw data abstraction using the ``RawDataReader`` interface class. This base class defines a standard interface for reading raw MRI data in a vendor-agnostic way.

It defines two main methods:

- ``readMetaData``  
  Parses header information and acquisition parameters from the file, such as:
  - Number of coils
  - Acquisition lines
  - Echo counts
  - Field of view (FOV)  
  It also analyzes the signal to estimate when steady state is reached.

- ``readRawData``  
  Loads and reshapes the actual k-space data into a MATLAB array. Typical dimensions include:
  - Coils
  - Readout points
  - Acquisition lines  
  This method can optionally remove unwanted or non–steady-state lines based on flags.

These methods provide a unified interface, abstracting vendor-specific details while ensuring compatibility across the Monalisa pipeline.

**Implemented Readers**

Monalisa currently includes two subclasses of ``RawDataReader``:

- ``siemens``  
  Uses the **mapVBVD** library to read Siemens raw data.  
  Source: https://github.com/MattechLab/monalisa/tree/main/src/rawDataReader/siemens

- ``ismrmrd``  
  Supports the ISMRMRD file format.  
  Source: https://github.com/MattechLab/monalisa/tree/main/src/rawDataReader/ismrmrd

**Note on mapVBVD**

The Siemens reader uses the external toolbox **mapVBVD**, originally developed by Philipp Ehses:  
https://github.com/pehses/mapVBVD

Please note that these functions are **not part of the core Monalisa toolbox** and are located in:
``monalisa/third_part/twix_for_monalisa/``

**Extending for Other Formats**

If you need to support a different file format, you have two options:

- Convert your dataset to ISMRMRD (recommended if possible)
- Implement a new subclass of ``RawDataReader`` and override:
  - ``readMetaData``
  - ``readRawData``

Source for the base class:  
https://github.com/MattechLab/monalisa/blob/main/src/rawDataReader/mleRawDataReader.m
