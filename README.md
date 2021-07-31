# solid-common-vocab-script

Utility bash scripts for working with Artifact Generator configuration files.

The main function of these scripts is to display and update various version
numbers that commonly appear in these configuration files, such as which
version of the Artifact Generator to use, what version number to use when
generating artifacts, and the versions of dependent libraries.

Other functions include:
 - Fetching specific versions of the Artifact Generator from GitHub.
 - Installing the Artifact Generator locally.
 - Watching local vocabulary files for changes, and re-generating artifacts
   accordingly (meaning local RDF updates can be reflected in near-real-time
   for the developer (locally)).
