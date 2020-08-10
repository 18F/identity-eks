# Linkerd

https://linkerd.io/2/overview/

## Pros

Linkerd is a super cool service mesh that lets you wrap everything with mTLS
so all services automatically are encrypted.  It uses iptables to redirect
traffic into it's proxy, as opposed to DNS, which consul uses, so you
do not need to adjust anything in your app to make it work.

## Cons

Unfortunately, we cannot deploy this in the normal declarative way, because
the helm template stuff actually requires you to supply a trust anchor
cert/key that gets used to create issuer certs which are rotated periodically.
So we can't store that key in git.  
There is some discussion about using certmanager for everything
that may fix this up here:  https://github.com/linkerd/linkerd2/issues/3745

Thus, we are installing linkerd in the deploy script using helm and not storing
the output.  This is not great, but it is what it is right now.

Another con is the fact that services that are not http are not automatically
encrypted.  Thus, port 9300 for elasticsearch, which is a binary protocol
for transport of data, is not proxied.  https://github.com/linkerd/rfc/pull/26/files
and https://github.com/linkerd/linkerd2/issues/3207 should fix this, but
until then, we need to be mindful of this.

