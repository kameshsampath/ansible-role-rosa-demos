ARG ANSIBLE_RUNNER_IMAGE=quay.io/ansible/ansible-runner:stable-2.11-devel
ARG PYTHON_BUILDER_IMAGE=quay.io/ansible/python-builder:latest

FROM $ANSIBLE_RUNNER_IMAGE as galaxy

ARG ANSIBLE_GALAXY_CLI_COLLECTION_OPTS=
ADD _build /build

WORKDIR /build
RUN ansible-galaxy role install -r requirements.yml --roles-path /usr/share/ansible/roles
RUN ansible-galaxy collection install $ANSIBLE_GALAXY_CLI_COLLECTION_OPTS -r requirements.yml --collections-path /usr/share/ansible/collections

FROM $PYTHON_BUILDER_IMAGE as builder
ADD _build/requirements_combined.txt /tmp/src/requirements.txt
ADD _build/bindep_combined.txt /tmp/src/bindep.txt
RUN assemble

FROM $ANSIBLE_RUNNER_IMAGE
RUN dnf -y --nodocs install wget curl tar unzip openssl jq
RUN cd /tmp
RUN wget -Oopenshift-client-linux.tar.gz https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable-4.7/openshift-client-linux.tar.gz
RUN tar --exclude='README.md' -C /usr/local/bin  -zxf openshift-client-linux.tar.gz
RUN wget -Oawscliv2.zip "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
RUN unzip awscliv2.zip
RUN ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update
RUN wget -O/usr/local/bin/rosa https://github.com/openshift/rosa/releases/download/v1.0.2/rosa-linux-amd64
RUN chmod +x /usr/local/bin/oc /usr/local/bin/kubectl /usr/local/bin/rosa
RUN dnf -y clean all

COPY --from=galaxy /usr/share/ansible /usr/share/ansible

COPY --from=builder /output/ /output/
RUN /output/install-from-bindep && rm -rf /output/wheels
RUN oc version
RUN kubectl version
RUN rosa version
RUN aws --version
