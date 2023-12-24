KUBECONFIG=${KUBECONFIG:-$HOME/.kube/config}
KUBECONFIG_SESSION_DIR="${XDG_STATE_HOME:-$HOME/.kube}/kubech"
KUBE_SESSION_CONFIG="$KUBECONFIG_SESSION_DIR/$$-config"

KUBE_SESSION_POWERLEVEL9K_FOREGROUND=${KUBE_SESSION_POWERLEVEL9K_FOREGROUND:-13}
KUBE_SESSION_POWERLEVEL9K_CONTENT_EXPANSION=${KUBE_SESSION_POWERLEVEL9K_CONTENT_EXPANSION:-" (session)"}

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

_activate_kube-session_p10k_prompt() {
  typeset -g POWERLEVEL9K_KUBECONTEXT_KUBE_SESSION_FOREGROUND="$KUBE_SESSION_POWERLEVEL9K_FOREGROUND"
  typeset -g POWERLEVEL9K_KUBECONTEXT_CLASSES=('*' KUBE_SESSION)
  POWERLEVEL9K_KUBECONTEXT_KUBE_SESSION_CONTENT_EXPANSION="${POWERLEVEL9K_KUBECONTEXT_DEFAULT_CONTENT_EXPANSION}${KUBE_SESSION_POWERLEVEL9K_CONTENT_EXPANSION}"
  p10k reload
}

_kube-session_activate() {
  if [[ -f $KUBECONFIG ]]; then
    cp -n "$KUBECONFIG" "$KUBE_SESSION_CONFIG" 2>/dev/null

    # https://stackoverflow.com/a/22794374/11054476
    zshexit() {
      # shellcheck disable=SC2317
      rm "$KUBE_SESSION_CONFIG"
    }

    export KUBECONFIG="$KUBE_SESSION_CONFIG"
    if command -v p10k &>/dev/null; then _activate_kube-session_p10k_prompt; fi
  else
    cat <<EOF >/dev/stderr
error: \`$KUBECONFIG\` does not exists
  - Make sure that \$KUBECONFIG is exported before sourcing this snippet
  - Make sure that \`$KUBECONFIG\` exists
EOF
  fi
}

alias ks="_kube-session_activate"
