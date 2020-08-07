# EBS storage class driver

This was an attempt to figure out how to upgrade the EBS PV
system.  It isn't quite working, and I don't want to break
anything on my working cluster, but I suspect this would be
a better way to get persistent volumes going.

https://github.com/kubernetes-sigs/aws-ebs-csi-driver

Note:  there are some nice things there on how to choose
a type of storage on that page.  Probably can put it into your
claim or something.

