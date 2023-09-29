KUBECONFIG=${KUBECONFIG:-$HOME/.kube/config}
KUBECONFIG_SESSION_DIR="${XDG_STATE_HOME:-$HOME/.kube}/kubech"
KUBE_SESSION_CONFIG="$KUBECONFIG_SESSION_DIR/$$-config"

KUBE_SESSION_ORIGINAL_KUBECONFIG="${KUBECONFIG}"

_init_kubech () {
  if [[ ! -d $KUBECONFIG_SESSION_DIR ]]; then
    mkdir -p "$KUBECONFIG_SESSION_DIR"
    chmod 744 "$KUBECONFIG_SESSION_DIR"
    setfacl -d -m u::rwx,g::---,o::--- "$KUBECONFIG_SESSION_DIR"
  fi
  unset -f _init_kubech
} && _init_kubech

if [[ -f $KUBECONFIG ]]; then
  cp "$KUBECONFIG" "$KUBE_SESSION_CONFIG"
  trap 'rm '"$KUBE_SESSION_CONFIG"'' EXIT
  export KUBECONFIG="$KUBE_SESSION_CONFIG"
else
  cat <<EOF > /dev/stderr
error: \`$KUBECONFIG\` does not exists
  - Make sure that \$KUBECONFIG is exported before sourcing this snippet
  - Make sure that \`$KUBECONFIG\` exists
EOF
fi

kube-session-use-global () {
  export KUBECONFIG=$KUBE_SESSION_ORIGINAL_KUBECONFIG
}
