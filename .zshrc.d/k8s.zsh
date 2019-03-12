kapply() {envsubst < "$@" | kubectl apply -f -}

kseal() {
    name=$(basename -s .txt "$@")
    if [[ -z "$NS" ]]; then
      NS=default
    fi
    envsubst < "$@" > values.yaml | kubectl -n "$NS" create secret generic "$name" --from-file=values.yaml --dry-run -o json | kubeseal --format=yaml --cert=../pub-cert.pem && rm values.yaml
}

alias k='kubectl'
# alias get_k8s_token="kubectl -n kube-system describe secret \$\(kubectl -n kube-system get secret | grep admin-user | cut -f1 -d ' '\) | grep -E '^token' | cut -f2 -d':' | tr -d '\t'"

if [ $commands[kubectl] ]; then
  source <(kubectl completion zsh)
fi

