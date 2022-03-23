#!/bin/sh

### 打包过程 ###
### 1.获取依赖
### 2.先执行一遍flutter iOS 打包命令
### 3.定义相关使用的变量
### 4.执行xcodebuild 相关打包命令并导出ipa
### 5.将ipa传到nexus
### 6.将ipa传到App Connect
### 7.发送钉钉通知 打包完成

# 输出已经存在的环境变量
env

# 1.获取依赖
/Users/waitwalker/flutter/bin/flutter packages get
/Users/waitwalker/flutter/bin/flutter clean


# 2.先执行一遍flutter iOS 打包命令
/Users/waitwalker/flutter/bin/flutter build ios --release



# 3.定义相关使用的变量
JOB_NAME=${JOB_NAME-online-wangxiao-ios}
echo "---++++++===   JOB_NAME   ===++++++---"$JOB_NAME

WORKSPACE=${WORKSPACE-.}
echo "---++++++===   工作区WORKSPACE   ===++++++---"$WORKSPACE

## 编译版本号
BUILD_NUMBER=$(/usr/libexec/PlistBuddy -c 'Print CFBundleVersion' ios/Runner/Info.plist)
echo "---++++++===   BUILD_NUMBER   ===++++++---"$BUILD_NUMBER

SERVER_IP="localhost"
LOCAL_IP=$(ipconfig getifaddr en0)
API_KEY="9GN8NKT4XY"
API_ISSUER_ID="69a6de85-fae4-47e3-e053-5b8c7c11a4d1"

#APP BASIC INFO
APP_NAME=wangxiao
APP_SCHEME=Runner
WORKSPACE_NAME=Runner
BUILD_IPA_NAME=北京四中网校
BUILD_TYPE="appStore"

## 版本号
APP_VERSION=$(cat ios/Runner.xcodeproj/project.pbxproj | grep MARKETING_VERSION | cut -d' ' -f3 | cut -d';' -f 1 | uniq)
echo "版本号"
echo $APP_VERSION

# 当前时间
export JENKINS_TIME=$(date +%y%m%d%H%M)

# 打包时间
JENKINS_TIME=$(date +%y%m%d%H%M)
echo "当前时间:"$JENKINS_TIME

# 提交记录等
GIT_COMMIT_HASH=${GIT_COMMIT:0:7}
GIT_REV=$(git rev-list HEAD | wc -l | awk '{print $1}')

# 重命名后ipa名称 wangxiao-1.5.2-2104141454
IPA_NAME=$APP_NAME-$APP_VERSION-$BUILD_TYPE-$JENKINS_TIME-$BUILD_NUMBER.ipa
echo "IPA_NAME:"$IPA_NAME

# xcworkspace 路径
XCWORKSPACE_PATH=$WORKSPACE/ios/$WORKSPACE_NAME.xcworkspace

# archive导出路径 如果不存在 则创建一个路径
ARCHIVE_EXPORT_PATH=./build/ios/$JOB_NAME/$BUILD_NUMBER
mkdir -p $ARCHIVE_EXPORT_PATH

# archive全路径名称 xx/xx.xcarchive
ARCHIVE_FULL_NAME_PATH=$ARCHIVE_EXPORT_PATH/$APP_NAME.xcarchive

echo $BUILD_TYPE
ExportOptionsPlistPath=/Users/waitwalker/Desktop/工作/证书/ExportOptions.plist
echo "App Store 签名文件路径:"$ExportOptionsPlistPath



# 4.执行xcpdebuild 相关打包命令并导出ipa
echo "============== 开始编译 准备导出 archive =================="
xcodebuild archive -workspace $XCWORKSPACE_PATH \
    -scheme $APP_SCHEME \
    -configuration Release \
    -archivePath $ARCHIVE_FULL_NAME_PATH \
    -allowProvisioningUpdates
echo "============== 导出 archive 成功 =================="

# ipa
echo "============== 开始编译 准备导出 ipa =================="
xcodebuild -exportArchive -archivePath $ARCHIVE_FULL_NAME_PATH \
    -exportPath $ARCHIVE_EXPORT_PATH \
    -exportOptionsPlist $ExportOptionsPlistPath \
    -allowProvisioningUpdates
echo "============== 导出 ipa成功 =================="
echo "ipa的存储路径是:"$ARCHIVE_EXPORT_PATH



# 5.将ipa传到nexus
# 上传到nexus
NEXUS_JENKINS_NAME=jenkins
NEXUS_JENKINS_PASSWORD=jenkins20100328
NEXUS_HOST=http://int.etiantian.com:39806
NEXUS_DIR=$NEXUS_HOST/nexus/service/local/repositories/EttAppReleases/content/com/online/$APP_NAME/ios/$APP_VERSION
curl -v -u $NEXUS_JENKINS_NAME:$NEXUS_JENKINS_PASSWORD --upload-file $ARCHIVE_EXPORT_PATH/$BUILD_IPA_NAME.ipa $NEXUS_DIR/$IPA_NAME
echo "iOS 打包成功, 已经上传到Nexus"



# 6.将ipa传到App Connect
export WEB_DIR=/Users/waitwalker/Library/apache-tomcat-9.0.17/webapps/app/$APP_VERSION
mkdir -p $WEB_DIR
host=http://$SERVER_IP:8081/app/$APP_VERSION
cp $ARCHIVE_EXPORT_PATH/$BUILD_IPA_NAME.ipa $WEB_DIR/$IPA_NAME

echo "准备签名验证"
xcrun altool --validate-app -f $WEB_DIR/$IPA_NAME -t ios --apiKey F9856W3538 --apiIssuer 69a6de85-fae4-47e3-e053-5b8c7c11a4d1 --verbose
echo "签名验证结束"

echo "准备上传到App Connect"
xcrun altool --upload-app -f $WEB_DIR/$IPA_NAME -t ios --apiKey F9856W3538 --apiIssuer 69a6de85-fae4-47e3-e053-5b8c7c11a4d1 --verbose
echo "上传到App Connect成功"



# 7.发送钉钉通知 打包完成
# 钉钉机器人，手机号为钉钉群里你要@的人的手机号
#DING DING
DING_TOKEN=6b5f8bcd4a884b18f32b988af6ccee073dbdd68ecdf4c0809c2045c1dd21a28a
# 测试token
#DING_TOKEN=1bb944e071c4aab8dff9caba09464521bfa9895aaaa622c7cba7b990273edf73
# 推送人员
MAN_TO_NOTIFY='["18612167007","18612696105","13691583024"]'
#MAN_TO_NOTIFY='["13691583024"]'
echo "准备发送钉钉推送"
title="App 上传成功(通过Testflight安装)\n"
content=$title$host/$IPA_NAME
echo "钉钉发送内容为:"$content
pre='{"msgtype":"text","text":{"content":"'
post='"},"at":{"atMobiles":'$MAN_TO_NOTIFY',"isAtAll":false}}'
json=$pre$content$post
echo $json
curl "https://oapi.dingtalk.com/robot/send?access_token=$DING_TOKEN" -H 'Content-Type: application/json' -d "$json"
echo "钉钉推送发送成功"
