export PUPPETEER_UPDATE_GOLDEN=true && xvfb-run --auto-servernum dart test --tags golden --concurrency=1
cp -pR test/golden/* /dest/test/golden
