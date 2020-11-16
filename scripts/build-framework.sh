#!/usr/bin/env bash

set -e

BASE_PWD="$PWD"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
OUTPUT_DIR=$( mktemp -d )
COMMON_SETUP="-project ${SCRIPT_DIR}/../ASCollectionView.xcodeproj -scheme ASCollectionViewFramework -configuration Release -quiet SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES"

# iOS
DERIVED_DATA_PATH=$( mktemp -d )
xcrun xcodebuild build \
	$COMMON_SETUP \
	-derivedDataPath "${DERIVED_DATA_PATH}" \
	-destination 'generic/platform=iOS'

mkdir -p "${OUTPUT_DIR}/iphoneos"
cp -r "${DERIVED_DATA_PATH}/Build/Products/Release-iphoneos/ASCollectionViewFramework.framework" "${OUTPUT_DIR}/iphoneos"
rm -rf "${DERIVED_DATA_PATH}"

# iOS Simulator
DERIVED_DATA_PATH=$( mktemp -d )
xcrun xcodebuild build \
	$COMMON_SETUP \
	-derivedDataPath "${DERIVED_DATA_PATH}" \
	-destination 'generic/platform=iOS Simulator'

mkdir -p "${OUTPUT_DIR}/iphonesimulator"
cp -r "${DERIVED_DATA_PATH}/Build/Products/Release-iphonesimulator/ASCollectionViewFramework.framework" "${OUTPUT_DIR}/iphonesimulator"
rm -rf "${DERIVED_DATA_PATH}"

# XCFRAMEWORK
xcrun xcodebuild -create-xcframework \
	-framework "${OUTPUT_DIR}/iphoneos/ASCollectionViewFramework.framework" \
	-framework "${OUTPUT_DIR}/iphonesimulator/ASCollectionViewFramework.framework" \
	-output ${OUTPUT_DIR}/ASCollectionView.xcframework

ditto -c -k --keepParent ${OUTPUT_DIR}/ASCollectionView.xcframework ASCollectionView.xcframework.zip

echo "✔️ ASCollectionView.xcframework"

rm -rf ${OUTPUT_DIR}

cd ${BASE_PWD}
