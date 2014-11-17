PROJECT=MBLocationManager.xcodeproj
SCHEME=MBLocationManager
SDK='iphoneos'
CONFIGURATION='AdHoc'
CONFIGURATION_BUILD_DIR='./out'
TEST_SDK='iphonesimulator'
CONFIGURATION_DEBUG='Debug'
DESTINATION='platform=iOS Simulator,name=iPhone Retina (4-inch),OS=7.0'
CONFIGURATION_TEMP_DIR=$(CONFIGURATION_BUILD_DIR)/tmp
PROVISIONING_PROFILE=MBLocationManager_AdHoc.mobileprovision
APP_NAME=$(PWD)/$(SCHEME)/out/$(SCHEME).app
IPA_NAME=$(PWD)/$(SCHEME)/out/$(SCHEME).ipa
DSYM=$(PWD)/$(SCHEME)/out/$(SCHEME).app.dSYM
DSYM_ZIP=$(PWD)/$(SCHEME)/out/$(SCHEME).dSYM.zip

default: clean build test

test: clean
	xctool -project ${PROJECT} -scheme ${SCHEME} test -test-sdk iphonesimulator -parallelize ONLY_ACTIVE_ARCH=NO

build:
	xctool -project ${PROJECT} -scheme ${SCHEME} build -sdk iphonesimulator

