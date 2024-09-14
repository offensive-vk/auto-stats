FROM ubuntu:24.04

RUN apt-get update && apt-get install -y git

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

LABEL \
    "name"="Auto Repo Stats Action" \
    "homepage"="https://github.com/marketplace/actions/auto-stats" \
    "repository"="https://github.com/offensive-vk/auto-stats" \
    "maintainer"="TheHamsterBot <TheHamsterBot@users.noreply.github.com>"