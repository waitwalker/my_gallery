#!/bin/sh

set -e

# flutter 渠道打包，渠道仍旧使用gradle方式，而不是flutter --flavor
# 打包完成发送到nexus仓库
# 同时复制到打包服务器的Apache webapp目录，并以url形式发送到钉钉群，以供内部快速预览
# 发布和存档，仍以nexus为准

echo $BUILD_URL
echo $JOB_URL
echo $WORKSPACE

# temp gradle
#export gradle=/Users/etiantian/.gradle/wrapper/dists/gradle-5.6.1-all/805usxkvhgx6e1wbo8o64g0tx/gradle-5.6.1/bin/gradle

/Users/waitwalker/flutter/bin/flutter packages get
/Users/waitwalker/flutter/bin/flutter clean
/Users/waitwalker/flutter/bin/flutter build apk --release -v --flavor develop
# cd android


gradle -v
# gradle -pandroid -Pchannel -Pverbose=true -Ptarget=lib/main.dart -Ptrack-widget-creation=false -Pcompilation-trace-file=compilation.txt -Ptarget-platform=android-arm assembleRelease -xlint
gradle clean apkDevelopRelease -pandroid -xlint


VERSION_NAME=$(cat ./android/local.properties | grep versionName | cut -d'=' -f2)
echo $VERSION_NAME


#IP=$(ipconfig getifaddr en0)

APK_PATH=app/$VERSION_NAME

WEBAPP_DIR=/Users/waitwalker/Library/apache-tomcat-9.0.17/webapps

SHARE_HOST=http://localhost:8081/$APK_PATH

WEB_DIR=$WEBAPP_DIR/$APK_PATH

ETT_APP_NAME=wangxiao

NEXUS_HOST=http://int.etiantian.com:39806
NEXUS_DIR=$NEXUS_HOST/nexus/service/local/repositories/EttAppReleases/content/com/online/$ETT_APP_NAME/android/$VERSION_NAME

NEXUS_JENKINS_NAME=jenkins
NEXUS_JENKINS_PASSWD=jenkins20100328

ETT_PACKAGE_PATH=$WORKSPACE/build/apks

DING_TOKEN=6b5f8bcd4a884b18f32b988af6ccee073dbdd68ecdf4c0809c2045c1dd21a28a

MEN_TO_NOTIFY='["18501378653","18612167007","18612696105","13691583024"]'

content="${VERSION_NAME}\nApp\n"
function getdir() {
    echo $1
    for file in $1/*; do
        if test -f $file; then
            # echo $file
            arr=(${arr[*]} $file)

            if [ "${file##*.}"x = "apk"x ]; then
                echo "found" $file
                name=$(basename $file)
                echo name
                curl -v -u $NEXUS_JENKINS_NAME:$NEXUS_JENKINS_PASSWD --upload-file $file $NEXUS_DIR/$name

				if [ ! -d "$WEB_DIR" ]; then
  					mkdir "$WEB_DIR"
				fi
                cp $file $WEB_DIR/
                content=$content$SHARE_HOST/$(basename $file)'\n'
                echo ---
                echo $content
                echo ---
            fi
        else
            getdir $file
        fi
    done

}
getdir $ETT_PACKAGE_PATH
# echo  ${arr[@]}

# 钉钉机器人，手机号为钉钉群里你要@的人的手机号
pre='{"msgtype":"text","text":{"content":"'
post='"},"at":{"atMobiles":'$MEN_TO_NOTIFY',"isAtAll":false}}'
json=$pre$content$post
echo $json

curl "https://oapi.dingtalk.com/robot/send?access_token=$DING_TOKEN" -H 'Content-Type: application/json' -d $json
