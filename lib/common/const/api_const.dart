import 'dart:convert';
import 'dart:io';
import 'package:my_gallery/common/config/config.dart';

///
/// @name 接口常量
/// @description 
/// @author waitwalker
/// @date 2020-01-11
///
class APIConst {

  /// token
  static const TOKEN_KEY = "access_token";

  /// 登录json
  static const LOGIN_JSON = "login_json";

  /// 用户信息json
  static const USER_INFO_JSON = "user_info_json";

  /// 用户隐私
  static const UserPrivacy = "1、您的权利和义务\n1.1、注册\n为完成创建账号，您需提供并填写个人信息，在填写个人信息时，应保证：\n1）提供真实、详尽、准确的个人信息；\n2）如个人信息有任何变动，应及时进行更新。\n如您提供的个人信息不准确、不真实、不合法有效，我司将保留结束您使用各项服务的权利。\n1.2、您有权访问、更正您的个人信息，但在以下情形中，按照法律法规要求，我司将无法响应您的请求：\n1）与国家安全、国防安全有关的；\n2）与公共安全、公共卫生、重大公共利益有关的；\n3）与犯罪侦查、起诉和审判等有关的；\n4）有充分证据表明您存在主观恶意或滥用权利的；\n5）响应您的请求将导致您或其他个人、组织的合法权益受到严重损害的。\n1.3、您随时可注销此前注册的账户\n在注销账户之后，我司将停止为您提供产品或服务，并删除您的个人信息，法律法规另有规定的除外。\n2、龙之门教育的经营者的权利和义务\n2.1、为实现向您提供我们产品及/或服务的功能，您可选择授权我们收集/使用的信息。如您拒绝提供，您将无法正常使用相关功能或无法达到我们拟达到的功能效果。\n1）获取粗略位置\n2）读取手机状态和身份\n3）录音\n4）获取精确位置\n5）读取外置存储卡\n6）摄像头\n7）写入外部存储卡\n8）查看WLAN连接\n9）开机启动\n10）使用蓝牙\n11）检索正在运行的应用\n12）震动权限\n13）保持屏幕常亮权限\n14）录制屏幕权限\n2.2、我司对于您在龙之门教育的软件产品中的任何行为进行定期或不定期的监控、检查、提示与评价，并根据您的使用情况，保留对您解约、封号等，或情节严重情况下对您提起诉讼的权利。\n2.3、我司已使用符合业界标准的安全防护措施保护您提供的个人信息，防止数据遭到未经授权访问、公开披露、使用、修改、损坏或丢失。我司会采取一切合理可行的措施，保护您的个人信息。\n2.4、在以下情形中，按照法律法规要求，我司将无法响应您的请求：\n1）与国家安全、国防安全有关的；\n2）与公共安全、公共卫生、重大公共利益有关的；\n3）与犯罪侦查、起诉和审判等有关的；\n4）有充分证据表明您存在主观恶意或滥用权利的；\n5）响应您的请求将导致您或其他个人、组织的合法权益受到严重损害的。\n3、隐私信息的披露和保护\n我司深知个人信息对您的重要性，并会尽全力保护您的个人信息安全可靠。我司致力于维持您对我司的信任，恪守以下原则，保护您的个人信息：权责一致原则、目的明确原则、选择同意原则、最少够用原则、确保安全原则、主体参与原则、公开透明原则等。同时，我司承诺，我司将按业界成熟的安全标准，采取相应的安全保护措施来保护您的个人信息。\n3.1、我司仅会在以下情况下，公开披露您的个人信息：\n1）获得您明确同意后；\n2）基于法律的披露：在法律、法律程序、诉讼或政府主管部门强制性要求的情况下。\n3.2、我司不会向其他任何公司、组织和个人分享您的个人信息，但以下情况除外：\n1）在获取明确同意的情况下共享：获得您的明确同意后；\n2）根据法律法规规定，或按政府主管部门的强制性要求，对外共享您的个人信息；\n3）与关联公司共享：您的个人信息可能会与我司的关联公司共享。但只会共享必要的个人信息，且受本隐私政策中所声明目的的约束。关联公司如要改变个人信息的处理目的，将再次征求您的授权同意。我司的关联公司包括:【北京四中龙门网络教育技术有限公司】、【北京育英才教育科技有限责任公司】。\n4）与授权合作伙伴共享：仅为实现本隐私权政策中声明的目的，我司的某些服务将由授权合作伙伴提供。我司可能会与合作伙伴共享您的某些个人信息，以提供更好的客户服务和用户体验。例如，我司聘请来提供第三方数据统计和分析服务的公司可能需要采集和访问个人数据以进行数据统计和分析。在这种情况下，这些公司 必须遵守我司的数据隐私和安全要求。我司仅会出于合法、正当、必要、特定、明确的目的共享您的个人信息，并且只会共享提供服务所必要的个人信息。对我司与之共享个人信息的公司、组织和个人，我司会与其签署严格的保密协定，要求他们按照我司的说明、本隐私政策以及其他任何相关的保密和安全措施来处理个人信息。\n4、Cookie和同类技术\n为确保本APP正常运转，我们会在您的移动设备上存储名为 Cookie的小数据文件。Cookie通常包含标识符、站点名称以及一些号码和字符。借助于Cookie能够存储您的偏好或购物篮内的商品等数据。\n我们不会将Cookie用于本政策所述目的之外的任何用途。您可根据自己的偏好管理或删除Cookie。有关详情，请参见AboutCookies.org。您可以清除本设备上保存的所有Cookie，大部分网络浏览器都设有阻止Cookie的功能。但如果您这么做，则需要在每一次使用本APP时更改用户设置。\n5、第三方SDK友盟统计及其他等\n我们的产品集成友盟+SDK，友盟+SDK需要收集您的设备Mac地址、唯一设备识别码（IMEI/android ID/IDFA/OPENUDID/GUID、SIM 卡 IMSI 信息）以提供统计分析服务，并通过地理位置校准报表数据准确性，提供基础反作弊能力。\n\n6、免责问题\n有下列情形之一的，龙之门教育经营者免责：\n1） 由于您将用户密码告知他人或与他人共享注册帐户，由此导致的任何个人资料泄露、丢失、被盗用或篡改；\n2）您在使用软件过程中违法国家法律法规及政策规定或本协议的规定，造成任何第三方主张索赔或承担法律责任的，与家长圈经营者无关；\n3） 任何由于计算机系统、黑客攻击、计算机病毒侵入或发作、因政府管制而造成的暂时性关闭等影响网络正常经营之不可抗力而造成的个人资料泄露、丢失、被盗用或被篡改等；\n4）当政府机关依照法定程序要求本软件披露个人资料时，我司将根据执法单位的要求或为公共安全之目的提供个人资料。在此情况下之任何披露。\n6、其他\n6.1、本协议中各款标题仅为方便查阅而设，对本协议条款的理解或解释并无影响。\n6.2、我司有权修改、变更或以其他形式进行对本协议的调整，除法律法规或监管规定另有强制性规定外，经调整或变更的内容一经通知或公布后的7日后生效。一旦本协议内容发生变动，我司将以适当形式向您告知。如您不同意修改后的内容，有权选择停止使用我司的软件服务平台服务；如您继续使用，则视为接受我司对本协议相关条款的修改并受其约束。\n6.3、如双方就本协议内容发生争议，应先友好协商；协商不成的，任何一方可向北京市西城区人民法院起诉。\n6.4、本协议适用中华人民共和国法律。";

  /// mock 测试服务器地址
  static final String kLocalServer = "http://192.168.8.66:7300/";

  /// Android版本：正式
  /// appId
  static String appIdAnd = Config.DEBUG
      ? '61205659F875DE5F8116A616E7489DB7'
      : 'C2ABCA7EBE1A93D1F0A1C3D9E8D6B79E';
  /// appSecret
  static String appSecretAnd = Config.DEBUG
      ? '3F56D81773FEE0D0A104B3D32FB880D3'
      : '2765F72C83B05066CB7B65F3650E3440';

  // iOS版本：正式
  /// appId
  static String appIdIos = Config.DEBUG
      ? '071DC04BB4053F236AD7DF478A8E4A17'
      : '2F5EE5930505950FA5D0F215171C15F9';
  /// appSecret
  static String appSecretIos = Config.DEBUG
      ? 'BA451F0E9F31B3A270C08F3BB38E33BE'
      : '832E7959E349487D043D1561894AFD74';

  /// 获取当前平台对应环境的AppId
  static String get appId => Platform.isAndroid ? appIdAnd : appIdIos;

  /// 获取当前平台对应环境的AppSecret
  static String get appSecret => Platform.isAndroid ? appSecretAnd : appSecretIos;

  /// 获取baseToken 一般用于注册/登录接口等
  static String get basicToken => base64Encode('$appId:$appSecret'.codeUnits);


  /// 服务器主URL
  static String kBaseServerURL = Config.DEBUG
      ? 'http://gw5.bj.etiantian.net:42393/'
      : 'https://school.etiantian.com/';

  static String liveHost = Config.DEBUG
      ? 'http://school.etiantian.com/cc-webt/mobile2.html'
      : 'https://school.etiantian.com/cc-web/mobile2.html';
  static String backHost = Config.DEBUG
      ? 'http://school.etiantian.com/cc-webt/back.html'
      : 'https://school.etiantian.com/cc-web/back.html';

  // 练习题，ai，自我学习
  static String practiceHost = Config.DEBUG
      ? 'http://gw1.bj.etiantian.net:15283/nwx-app'
      : 'https://item.etiantian.com/nwx-app';

  // 通用服务
  static String commonHost = Config.DEBUG
      ? 'http://i2.m.etiantian.com:48083/app-common-service'
      : 'https://i.im.etiantian.com/app-common-service';

  // app store 应用详情页
  static String appStoreURL = 'https://apps.apple.com/cn/app/%E5%8C%97%E4%BA%AC%E5%9B%9B%E4%B8%AD%E7%BD%91%E6%A0%A1/id1456594477';

  //学习报告url
  static String studyReport = Config.DEBUG
      ? 'http://gw1.bj.etiantian.net:15283/nwx-app/learningreporta.html'
      : 'https://item.etiantian.com/nwx-app/learningreporta.html';
  static String studyReportAll = Config.DEBUG
      ? 'http://gw1.bj.etiantian.net:15283/nwx-app/learningreportall.html'
      : 'https://item.etiantian.com/nwx-app/learningreportall.html';

  //错题本url
  static String errorBook = Config.DEBUG
      ? 'http://gw1.bj.etiantian.net:15283/nwx-app/errorbooklist.html'
      : 'https://item.etiantian.com/nwx-app/errorbooklist.html';

  //智能题库中章节练习 URL
  static String chapter = Config.DEBUG
      ? 'http://gw1.bj.etiantian.net:15283/nwx-app/questionbankai.html'
      : 'https://item.etiantian.com/nwx-app/questionbankai.html';

  //智能题库中历年真题作答 URL
  static String realQuestionPractice = Config.DEBUG
      ? 'http://gw1.bj.etiantian.net:15283/nwx-app/questionbankpractice.html'
      : 'https://item.etiantian.com/nwx-app/questionbankpractice.html';

  //智能题库中历年真题结果 URL
  static String realQuestionReport = Config.DEBUG
      ? 'http://gw1.bj.etiantian.net:15283/nwx-app/questionbankreport.html'
      : 'https://item.etiantian.com/nwx-app/questionbankreport.html';

  //质检消错错题本url
  static String errorBookUnitTest = Config.DEBUG
      ? 'http://gw1.bj.etiantian.net:15283/nwx-app/errorbookunitlist.html'
      : 'https://item.etiantian.com/nwx-app/errorbookunitlist.html';

  //质检消错名师解读本url
  static String unitTestDetail = Config.DEBUG
      ? 'http://gw1.bj.etiantian.net:15283/nwx-app/errorbookunitpractice.html'
      : 'https://item.etiantian.com/nwx-app/errorbookunitpractice.html';

  //数校错题本url
  static String errorBookShuXiao = Config.DEBUG
      ? 'http://gw1.bj.etiantian.net:15283/nwx-app/errorbookschoollist.html'
      : 'https://item.etiantian.com/nwx-app/errorbookschoollist.html';

  //图片上传url
  static String uploadImage = Config.DEBUG
      ? 'http://gw1.bj.etiantian.net:18480/ett20/totalmanage/service/testonline/paper/uploadFileXWXBackstage.jsp'
      : 'https://resource.etiantian.com/ett20/totalmanage/service/testonline/paper/uploadFileXWXBackstage.jsp';

  /// 获取pdf url
  static String pdfURL = Config.DEBUG
      ? 'http://chinaudo.com/qiyi_school_filet125/'
      : 'https://chinaudo.com/qiyi_school_file/';

}