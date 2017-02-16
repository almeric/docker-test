FROM ubuntu:16.10

# ------------------------------------------------------
# --- Install required tools

RUN apt-get update -qq

# Never ask for confirmations
ENV DEBIAN_FRONTEND noninteractive

# Dependencies to execute Android builds
RUN apt-get install -y openjdk-8-jdk wget unzip gradle

# Install android sdk
RUN wget -q https://dl.google.com/android/repository/tools_r25.2.3-linux.zip && \
    unzip tools_r25.2.3-linux.zip -d /usr/local/android-sdk && \
    chown -R root:root /usr/local/android-sdk/ && \
    rm tools_r25.2.3-linux.zip

# Add android tools and platform tools to PATH
ENV ANDROID_HOME /usr/local/android-sdk
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools

# Clean Up Apt-get
RUN rm -rf /var/lib/apt/lists/*
RUN apt-get clean && apt-get autoclean && apt-get autoremove


# Install latest android tools and system images
RUN ( sleep 4 && while [ 1 ]; do sleep 1; echo y; done ) | android update sdk --no-ui --force -a --filter \
	platform-tool,android-25,android-24,android-23,build-tools-25.0.3,sys-img-x86_64-google_apis-25,sys-img-x86_64-google_apis-24,sys-img-x86_64-google_apis-23,extra-android-m2repository,extra-google-m2repository,extra-google-google_play_services && \
	echo "y" | android update adb

# Support Gradle
ENV TERM dumb
ENV JAVA_OPTS "-Xms512m -Xmx1024m"
ENV GRADLE_OPTS "-XX:+UseG1GC -XX:MaxGCPauseMillis=1000"


RUN chown -R 1000:1000 $ANDROID_HOME
VOLUME ["/opt/android-sdk-linux"]