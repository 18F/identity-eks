# System

This is where the system services are set up!  To add more system services,
just create an argocd application yaml file and add it in the kustomization.yaml file.

The default project is where these should live, as that seems to give you the ability
to deploy anywhere with anything.  Other, non-system things should have their own
projects that specify what namespaces they can live in and what repos they are allowed
to pull from.

We are also generally placing services that we have tested in the base directory at the
top level of this repo.  You can look at some of the others for examples of how that
works.
