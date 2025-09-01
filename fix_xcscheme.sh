#!/bin/bash
find ios/Pods -name "*.xcscheme" -exec sed -i '' 's/LastUpgradeVersion = "1600"/LastUpgradeVersion = "1500"/g' {} \;
echo "All xcscheme files have been updated from version 1600 to 1500."