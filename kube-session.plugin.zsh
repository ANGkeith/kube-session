KUBECONFIG=${KUBECONFIG:-$HOME/.kube/config}
KUBECONFIG_SESSION_DIR="${XDG_STATE_HOME:-$HOME/.kube}/kubech"
KUBE_SESSION_CONFIG="$KUBECONFIG_SESSION_DIR/$$-config"

KUBE_SESSION_ORIGINAL_KUBECONFIG="$KUBECONFIG"

_init_kubech() {
  if [[ ! -d $KUBECONFIG_SESSION_DIR ]]; then
    mkdir -p "$KUBECONFIG_SESSION_DIR"
    chmod 744 "$KUBECONFIG_SESSION_DIR"
    setfacl -d -m u::rwx,g::---,o::--- "$KUBECONFIG_SESSION_DIR"
  else
    # Delete files modified more than 7 days ago
    find "$KUBECONFIG_SESSION_DIR" -type f -mtime +7 -exec rm {} \;
  fi
  unset -f _init_kubech
} && _init_kubech

_kube-session_activate() {
  if [[ -f $KUBECONFIG ]]; then
    cp -n "$KUBECONFIG" "$KUBE_SESSION_CONFIG" 2>/dev/null

    # https://stackoverflow.com/a/22794374/11054476
    zshexit() {
      # shellcheck disable=SC2317
      rm "$KUBE_SESSION_CONFIG"
    }

    export KUBECONFIG="$KUBE_SESSION_CONFIG"
  else
    cat <<EOF >/dev/stderr
error: \`$KUBECONFIG\` does not exists
  - Make sure that \$KUBECONFIG is exported before sourcing this snippet
  - Make sure that \`$KUBECONFIG\` exists
EOF
  fi
}

_kube-session_deactivate() {
  export KUBECONFIG=$KUBE_SESSION_ORIGINAL_KUBECONFIG
}

alias ks="_kube-session_activate"
alias ks!="_kube-session_deactivate"
