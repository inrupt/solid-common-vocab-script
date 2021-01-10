# solid-common-vocab-script

Utility scripts for working with Artifact Generator vocabulary configuration
files.

The main function of these scripts is to displaying and update version numbers
for the artifactor generator to use, generated artifacts and the versions of
dependent libraries.

Other functions include:
 - fetching the Artifact Generator 
 - installing the Artifact Generator locally
 - watching local vocbaulary files for changes, and re-generating artifacts
   accordingly (meaning local RDF updates can be reflected in near real-time
   for the developer locally)