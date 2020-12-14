# Terraform!

This cluster will be running terraform whenever git changes happen for particular branches.

* The system directory holds various system services that we want running.
* The tf directory holds the various environments that need deployment in subdirectories.
* The `set-deploykey.sh` script can be run to copy the deploy-key into the kubernetes secret.

## What happens

* CI builds the terraform container from identity-tfcontainer.

This cluster is set up to watch identity-devops on a number of branches.  When changes happen
there, we kick off a task to deploy those changes to the environment that it is set up to watch.

## How to monitor

XXX
