#!/bin/bash
# This shell script builds a new container image for the Gitea Operator
VERSION=1.3.3
PREVIOUS_VERSION=1.3.2
QUAY_ID=atarazana
QUAY_USER=gpte-devops-automation+giteaoperatorbuild

#echo "Logging in as ${QUAY_USER}. Please provide password when prompted."
#podman login -u ${QUAY_USER} quay.io
#if [[ "$?" != "0" ]];
#then
#  echo "Please ensure that QUAY_ID is logged into Quay successfully."
#  exit 1
#fi

# Build Operator Container Image
make docker-build IMG=quay.io/$QUAY_ID/gitea-operator:v${VERSION}

# Push Operator Image to Registry
make docker-push IMG=quay.io/$QUAY_ID/gitea-operator:v${VERSION}

echo "====== BEFORE 'Make Operator Bundle'"
# Make Operator Bundle
make bundle CHANNELS=stable DEFAULT_CHANNEL=stable VERSION=${VERSION} IMG=quay.io/$QUAY_ID/gitea-operator:v${VERSION}
echo "====== BEFORE 'Build Operator Bundle Container Image'"
# Build Operator Bundle Container Image
make bundle-build BUNDLE_CHANNELS=stable BUNDLE_DEFAULT_CHANNEL=stable VERSION=${VERSION} BUNDLE_IMG=quay.io/$QUAY_ID/gitea-operator-bundle:v${VERSION}
echo "====== BEFORE 'Push Operator Bundle Container Image'"
# Push Operator Bundle Container Image
podman push quay.io/$QUAY_ID/gitea-operator-bundle:v${VERSION}
echo "====== BEFORE 'Build Catalog Image'"
# Build Catalog Image
make catalog-build VERSION=${VERSION} BUNDLE_CHANNELS=stable BUNDLE_DEFAULT_CHANNEL=stable VERSION=${VERSION} \
  BUNDLE_IMG=quay.io/$QUAY_ID/gitea-operator-bundle:v${VERSION} \
  CATALOG_IMG=quay.io/$QUAY_ID/gitea-catalog:v${VERSION} \
  CATALOG_BASE_IMG=quay.io/$QUAY_ID/gitea-catalog:v${PREVIOUS_VERSION}
# opm index add \
#     --bundles quay.io/$QUAY_ID/gitea-operator-bundle:v${VERSION} \
#     --tag quay.io/$QUAY_ID/gitea-catalog:v${VERSION}
echo "====== BEFORE 'Push Catalog Image'"
# Push Catalog Image
podman push quay.io/$QUAY_ID/gitea-catalog:v${VERSION}
