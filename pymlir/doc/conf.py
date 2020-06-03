import os
import sys
sys.path.insert(0, os.path.abspath('..'))
project = 'pyMLIR'
copyright = '2020, Scalable Parallel Computing Laboratory, ETH Zurich'
author = 'Scalable Parallel Computing Laboratory, ETH Zurich'
release = '0.5'
extensions = ['sphinx.ext.autodoc']
templates_path = ['_templates']
exclude_patterns = ['_build', 'Thumbs.db', '.DS_Store']
html_theme = 'sphinx_rtd_theme'
html_static_path = ['_static']

master_doc = 'index'
