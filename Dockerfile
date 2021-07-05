# SPDX-License-Identifier: BSD-3-Clause
#
# Authors: Alexander Jung <a.jung@lancs.ac.uk>
#
# Copyright (c) 2021, Lancaster University.  All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. Neither the name of the copyright holder nor the names of its
#    contributors may be used to endorse or promote products derived from
#    this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

FROM unikraft/kraft:staging AS build

LABEL MAINTAINER "Alexander Jung <a.jung@lancs.ac.uk>"

ARG HUGO_VER=0.83.0
ARG BUILD_REF=latest

RUN mkdir /src
WORKDIR /src
COPY . /src

RUN set -xe; \
    apt-get update; \
    apt-get install -y \
      curl \
      g++ \
      lsb-release \
      gnupg; \
    curl -sLf -o /dev/null 'https://deb.nodesource.com/node_12.x/dists/buster/Release'; \
    curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -; \
    curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -; \
    echo 'deb https://deb.nodesource.com/node_12.x buster main' > /etc/apt/sources.list.d/nodesource.list; \
    echo 'deb-src https://deb.nodesource.com/node_12.x buster main' >> /etc/apt/sources.list.d/nodesource.list; \
    echo 'deb https://dl.yarnpkg.com/debian/ stable main' >> /etc/apt/sources.list.d/yarn.list; \
    apt-get update; \
    apt-get install -y \
      nodejs; \
    npm install -g esbuild-linux-64; \
    npm install; \
    cd /tmp; \
    curl -LO https://github.com/gohugoio/hugo/releases/download/v${HUGO_VER}/hugo_extended_${HUGO_VER}_Linux-64bit.tar.gz; \
    tar -xzf hugo_extended_${HUGO_VER}_Linux-64bit.tar.gz; \
    mv ./hugo /usr/local/bin/hugo

ENTRYPOINT [ "" ]

EXPOSE 1313
CMD hugo server --bind=0.0.0.0 --minify --themesDir=/src/themes --baseURL=http://0.0.0.0:1313/

FROM scratch AS production

COPY --from=build /etc/passwd /etc/group /etc/
COPY --from=build /usr/local/nginx /usr/local/nginx
COPY --from=local /src/public /usr/local/ngiwnx/html
COPY etc/nginx/nginx.conf /usr/local/nginx/conf/nginx.conf
COPY etc/nginx/mime.types /usr/local/nginx/conf/mime.types

STOPSIGNAL SIGQUIT
EXPOSE 1313
ENTRYPOINT ["/usr/local/nginx/sbin/nginx"]
CMD ["-g", "daemon off;"]
