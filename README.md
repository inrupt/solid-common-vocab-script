# solid-common-vocab-script

Utility scripts for working with Artifact Generator vocabulary configuration
files.

The main function of these scripts is to display and update version numbers
for the artifactor generator to use, including the versions of generated
artifacts, and the versions of dependent libraries.

Other functions include:
 - Fetching the Artifact Generator.
 - Installing the Artifact Generator locally.
 - Watching local vocbaulary files for changes, and re-generating artifacts
   accordingly (meaning local RDF updates can be reflected in near-real-time
   for the developer (locally)).
