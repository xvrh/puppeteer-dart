set -e

if [[ -z "$DART_SDK_VERSION" ]]; then
  DART_SDK_VERSION='2.9.3'
fi

case "$OSTYPE" in
  darwin*)  DART_ZIP_NAME="dartsdk-macos-x64-release.zip" ;;
  linux*)   DART_ZIP_NAME="dartsdk-linux-x64-release.zip" ;;
  *)        DART_ZIP_NAME="dartsdk-windows-x64-release.zip" ;;
esac

DART_CHANNEL="stable"
if [[ $DART_SDK_VERSION == *"-dev."* ]]; then
  DART_CHANNEL="dev"
fi

DART_SDK_URL="https://storage.googleapis.com/dart-archive/channels/$DART_CHANNEL/raw/$DART_SDK_VERSION/sdk/$DART_ZIP_NAME"

curl --connect-timeout 15 --retry 5 $DART_SDK_URL > dartsdk.zip
unzip dartsdk.zip
rm dartsdk.zip

DART_SDK_PATH=$(pwd)/dart-sdk
echo "::add-path::$DART_SDK_PATH/bin"
echo "::add-path::$HOME/.pub-cache/bin"
echo "::set-env name=DART_SDK::$DART_SDK_PATH"

(cd "$DART_SDK_PATH/bin"; ls -l)