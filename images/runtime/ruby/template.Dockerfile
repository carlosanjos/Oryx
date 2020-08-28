ARG DEBIAN_FLAVOR
# Startup script generator
FROM golang:1.14-${DEBIAN_FLAVOR} as startupCmdGen
# Install dep
RUN go get -u github.com/golang/dep/cmd/dep
# GOPATH is set to "/go" in the base image
WORKDIR /go/src
COPY src/startupscriptgenerator/src .
ARG GIT_COMMIT=unspecified
ARG BUILD_NUMBER=unspecified
ARG RELEASE_TAG_NAME=unspecified
ENV RELEASE_TAG_NAME=${RELEASE_TAG_NAME}
ENV GIT_COMMIT=${GIT_COMMIT}
ENV BUILD_NUMBER=${BUILD_NUMBER}
RUN ./build.sh ruby /opt/startupcmdgen/startupcmdgen

FROM oryx-run-base-${DEBIAN_FLAVOR} As main
ARG IMAGES_DIR=/tmp/oryx/images

# Bake Application Insights key from pipeline variable into final image
ARG AI_KEY
ENV ORYX_AI_INSTRUMENTATION_KEY=${AI_KEY}
RUN ${IMAGES_DIR}/runtime/ruby/install-dependencies.sh

COPY --from=startupCmdGen /opt/startupcmdgen/startupcmdgen /opt/startupcmdgen/startupcmdgen
RUN ln -s /opt/startupcmdgen/startupcmdgen /usr/local/bin/oryx \
    && rm -rf /tmp/oryx
