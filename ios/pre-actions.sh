# This file is for easier editing.
# All updates to this file should be update to
# the script in Runner.xcworkspace > Edit Runner scheme > Build > Pre-actions.
/bin/cp -Rf ${PROJECT_DIR}/../configs/GoogleService-Info.plist ${PROJECT_DIR}/GoogleService-Info.plist
/bin/cp -Rf ${PROJECT_DIR}/../configs/customized/ ${PROJECT_DIR}/../
echo "#include? \"${PROJECT_DIR}/../configs/env.properties\"" > ${PROJECT_DIR}/Config.xcconfig
