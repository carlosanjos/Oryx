ARG DEBIAN_FLAVOR
FROM oryx-run-base-${DEBIAN_FLAVOR}
  
# NOTE: This is a list of keys for ALL Node versions and also Yarn package installs.
# Receiving them once speeds up building of individual node versions as they all derive
# from this image.

# Gpg keys listed at https://github.com/nodejs/node
RUN imagesDir="/tmp/oryx/images" \
  && $imagesDir/receiveGpgKeys.sh 6A010C5166006599AA17F08146C2130DFD2497F5 \
  && YARN_VERSION="1.17.3" \
  && curl -fsSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz" \
  && curl -fsSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz.asc" \
  && gpg --batch --verify yarn-v$YARN_VERSION.tar.gz.asc yarn-v$YARN_VERSION.tar.gz \
  && mkdir -p /opt \
  && tar -xzf yarn-v$YARN_VERSION.tar.gz -C /opt/ \
  && ln -s /opt/yarn-v$YARN_VERSION/bin/yarn /usr/local/bin/yarn \
  && ln -s /opt/yarn-v$YARN_VERSION/bin/yarnpkg /usr/local/bin/yarnpkg \
  && rm yarn-v$YARN_VERSION.tar.gz.asc yarn-v$YARN_VERSION.tar.gz
