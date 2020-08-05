# Falco!

This is where we can render the falco config.
```
cd falco
./render-falco.sh
cd ..
./deploy.sh <clustername>
```

Sometimes, falco doesn't work because the image that it needs isn't there yet.
Like:  https://github.com/falcosecurity/falco/issues/1335 for example.
We need to get testing going here or something.

Once deployed, Falco alerts will appear in the log stream for your review.

Nifty!

