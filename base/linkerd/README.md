# Linkerd

Linkerd is a super cool service mesh that lets you wrap everything with mTLS
so all services automatically are encrypted.

Unfortunately, we cannot deploy this in the normal declarative way, because
the helm template stuff actually requires you to supply a trust anchor
cert/key that gets used to create issuer certs which are rotated periodically.
So we can't store that key in git.

Thus, we are installing linkerd in the deploy script using helm.
This is not great, but it is what it is right now.

XXX We need to figure out where to store the crt/key that get generated
here, maybe in s3 or something?

