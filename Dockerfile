FROM ubuntu:16.04

# ------------------------------------------------------
# --- Install required tools

# Never ask for confirmations
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -qq
RUN apt-get install -y libqt5widgets5 wget curl openjdk-8-jdk qemu-kvm libvirt-bin unzip

# Dependencies to execute Android builds
#RUN cd /tmp/ && wget -q https://services.gradle.org/distributions/gradle-3.3-all.zip && \
#	unzip -d /opt/gradle gradle-3.3-all.zip && \
#	rm /tmp/gradle-3.3-all.zip

#ENV PATH ${PATH}:/opt/gradle/gradle-3.3/bin

# Install android sdk
RUN cd /tmp && curl -o android.zip https://dl.google.com/android/repository/tools_r25.2.3-linux.zip && \
 	unzip android.zip -d /usr/local/android-sdk && \
	chown -R root:root /usr/local/android-sdk/ && \
    rm android.zip

# Add android tools and platform tools to PATH
ENV ANDROID_HOME /usr/local/android-sdk
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools

# Clean Up Apt-get
RUN rm -rf /var/lib/apt/lists/*
RUN apt-get clean && apt-get autoclean && apt-get autoremove


# Install latest android tools and system images
#RUN ( sleep 4 && while [ 1 ]; do sleep 1; echo y; done ) | android update sdk --no-ui --force -a --filter \
#	platform-tool,android-25,android-24,build-tools-25.0.3,sys-img-x86_64-google_apis-25,sys-img-x86_64-google_apis-24,extra-android-m2repository,extra-google-m2repository,extra-google-google_play_services && \
#	echo "y" | android update adb

RUN ( sleep 4 && while [ 1 ]; do sleep 1; echo y; done ) | android update sdk --no-ui --force -a --filter \
	platform-tool,android-25,build-tools-25.0.3,sys-img-x86_64-google_apis-25 && \
	echo "y" | android update adb

# Support Gradle
ENV TERM dumb
ENV JAVA_OPTS "-Xms512m -Xmx1024m"
ENV GRADLE_OPTS "-XX:+UseG1GC -XX:MaxGCPauseMillis=1000"

# Create avd
# echo "no" | android create avd --force --name test --target android-25 --abi google_apis/x86_64
#emulator64-x86 -avd test -no-window -no-audio



# auto accept licenses
RUN mkdir -p "$ANDROID_HOME/licenses"
RUN echo -e "\n8933bad161af4178b1185d1a37fbf41ea5269c55" > "$ANDROID_HOME/licenses/android-sdk-license" && \
	echo -e "\n84831b9409646a918e30573bab4c9c91346d8abd" > "$ANDROID_HOME/licenses/android-sdk-preview-license" && \
	echo -e "\nd975f751698a77b662f1254ddbeed3901e976f5a" > "$ANDROID_HOME/licenses/android-sdk-preview-license"
