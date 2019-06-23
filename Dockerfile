FROM quay.io/coreos/etcd

RUN apk update && apk add --no-cache \
    bash fish curl wget git perl python \
    && git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf \
    && fish -c '~/.fzf/install'
