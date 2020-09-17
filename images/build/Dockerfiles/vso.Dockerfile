FROM oryxdevmcr.azurecr.io/public/oryx/build

# This is a separate instruction because of the limit of Docker where variable expansion fails when used in the
# same instruction. In the below example the variable TEST would be empty instead of having the value "bar"
# Example: ENV FOO="bar" TEST="$FOO"
ENV ORYX_PATHS="$ORYX_PATHS:/opt/java/lts/bin:/opt/maven/lts/bin:/opt/ruby/lts/bin"

ENV ORYX_PREFER_USER_INSTALLED_SDKS=true \
    # VSO requires user installed tools to be preferred over Oryx installed tools
    PATH="$ORIGINAL_PATH:$ORYX_PATHS" \
    CONDA_SCRIPT="/opt/conda/etc/profile.d/conda.sh" \
    RUBY_HOME="/opt/ruby/lts" \
    JAVA_HOME="/opt/java/lts" \
    DYNAMIC_INSTALL_ROOT_DIR="/opt"

COPY --from=support-files-image-for-build /tmp/oryx/ /opt/tmp

RUN buildDir="/opt/tmp/build" \
    && imagesDir="/opt/tmp/images" \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        apt-transport-https \
    && rm -rf /var/lib/apt/lists/* \
    && curl https://repo.anaconda.com/pkgs/misc/gpgkeys/anaconda.asc | gpg --dearmor > conda.gpg \
    && install -o root -g root -m 644 conda.gpg /usr/share/keyrings/conda-archive-keyring.gpg \
    && gpg --keyring /usr/share/keyrings/conda-archive-keyring.gpg --no-default-keyring --fingerprint 34161F5BF5EB1D4BFBBB8F0A8AEB4F8B29D82806 \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/conda-archive-keyring.gpg] https://repo.anaconda.com/pkgs/misc/debrepo/conda stable main" > /etc/apt/sources.list.d/conda.list \
    && . $buildDir/__condaConstants.sh \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        conda=${CONDA_VERSION} \
    && rm -rf /var/lib/apt/lists/* \
    && . $CONDA_SCRIPT \
    && conda config --add channels conda-forge \
    && conda config --set channel_priority strict \
    && conda config --set env_prompt '({name})' \
    && echo "source ${CONDA_SCRIPT}" >> ~/.bashrc \
    && condaDir="/opt/oryx/conda" \
    && mkdir -p "$condaDir" \
    && cd $imagesDir/build/python/conda \
    && cp -rf * "$condaDir" \
    && cd $imagesDir \
    && . $buildDir/__rubyVersions.sh \
    && ./installPlatform.sh ruby $RUBY27_VERSION \
    && cd /opt/ruby \
    && ln -s $RUBY27_VERSION /opt/ruby/lts \
    && cd $imagesDir \
    && . $buildDir/__javaVersions.sh \
    && ./installPlatform.sh java $JAVA_VERSION \
    && ./installPlatform.sh maven $MAVEN_VERSION \
    && cd /opt/java \
    && ln -s $JAVA_VERSION lts \
    && cd /opt/maven \
    && ln -s $MAVEN_VERSION lts \
    && rm -rf /opt/tmp
