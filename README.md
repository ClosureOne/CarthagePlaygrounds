# CarthagePlaygrounds

Allow Playgrounds to use pre-built Carthage frameworks.

 - Create an aggregate target
 - Add a script phase to copy the frameworks from Carthage/Build/iOS/ to BUILT_PRODUCTS_DIR
 - Run aggregate target
 - Import framework in Playground

In you app:
 - Embed frameworks from BUILT_PRODUCTS_DIR, not Carthage/Build/iOS/
 - Add aggregate target to app scheme to re-establish frameworks after a clean.
 
