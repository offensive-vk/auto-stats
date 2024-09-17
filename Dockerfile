FROM ubuntu:24.04

RUN apt-get update && apt-get install -y git

COPY --chown=1000:1000 --chmod=744 *.sh /

ENTRYPOINT ["/bin/bash","/entrypoint.sh"]

LABEL \
    "name"="Auto Repo Stats Action" \
    "homepage"="https://github.com/marketplace/actions/auto-stats" \
    "repository"="https://github.com/offensive-vk/auto-stats" \
    "maintainer"="TheHamsterBot <TheHamsterBot@users.noreply.github.com>"