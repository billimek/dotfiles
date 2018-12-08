kapply() {envsubst < "$@" | kubectl apply -f -}

alias k='kubectl'
# alias get_k8s_token="kubectl -n kube-system describe secret \$\(kubectl -n kube-system get secret | grep admin-user | cut -f1 -d ' '\) | grep -E '^token' | cut -f2 -d':' | tr -d '\t'"

