# Kube Session

![Preview](https://i.imgur.com/xFXqxW7.gif)

This plugin defines helper function to use a temporary kubeconfig for the current
shell session, instead of the default globally shared context.

NOTE: Any write operations to this temporary kubeconfig file will be discarded,
if we want to persist the data, we'll need to write to the globally shared
KUBECONFIG instead.

One example use case is:
- `aws eks update-kubeconfig --name foo` which attempts to inject the required
  information into the KUBECONFIG

## How it works
- Creates a temporary kubeconfig (based of the globally shared KUBECONFIG) for each shell session
  - overwrite the `KUBECONFIG` environment to read from the temporary kubeconfig
  - When shell exits, cleanup the temporary file
