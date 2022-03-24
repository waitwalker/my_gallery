import 'package:my_gallery/model/user_info_model.dart';
import 'package:my_gallery/modules/personal/error_book/unit_test/unit_test_authority_model.dart';

///
/// @Class: 单例管理类
/// @Description: 
/// @author: lca
/// @Date: 2019-08-30
///
class SingletonManager {

  /// 是否已经登录过 判断跳转过来后,之前是否已经有其他用户登录了,登录了就先退出
  /// 1.登录过,也就是现在已经进入主页, 主页处理跳转,主页然后跳转到登录页面->爱学用户登录
  /// 2.没有登录过,登录页处理跳转->爱学用户登录
  /// 要判断是冷启动 热启动
  bool isHaveLogin = false;

  /// 是否从爱学跳转过来
  bool isJumpFromAixue = false;

  /// 是否显示活动课
  /// 如果跳转过来正好处于加载活动课的过程 则不显示
  bool shouldShowActivityCourse = true;

  /// 是否跳转过来触发的冷启动
  bool isJumpColdStart = false;

  /// 爱学传过来的参数
  String? aixueAccount;
  String? aixuePassword;
  String isVip = "";
  String gradeId = "";

  String currentValue = "1";

  /// 错题本是否需要刷新 & 弹出相机
  /// 0 不刷新 不处理
  /// 1 只刷新
  /// 2 刷新 & 弹出相机
  int errorBookCameraState = 0;

  /// 是否刷新质检消错学科列表
  bool shouldRefreshUnitTestSubjectList = false;

  /// 是否是新用户
  bool isNewUser = true;

  /// 是否加载过弹框 默认没有加载过
  bool isHaveLoadedAlert = false;

  /// 是否显示降级
  bool shouldShowDegradeEntrance = false;

  // 是否需要降级
  bool shouldDegrade = false;

  // 是否显示修改密码
  bool shouldShowChangePassword = false;

  /// 是否pad的设备
  bool isPadDevice = false;

  /// 是佛是管控设备 默认不是
  bool? isGuanKong = false;

  /// 屏幕宽高
  double screenWidth = 0.0;
  double screenHeight = 0.0;

  /// 是否有专题讲解权限
  bool isHaveLiveAuthority = false;

  /// 用户名
  String? userName = "";
  DataEntity? userData;

  String? mobile = "";

  // 当前语言索引
  int? currentLocaleIndex = 0;

  // 设备名称
  String deviceName = "";
  // 设备类型 iPad/iPhone/Tab 等等
  String deviceType = "";
  // 系统名称
  String systemName = "";
  // 系统版本
  String systemVersion = "";

  // 质检消错权限
  bool unitTestAuthority = false;
  UnitTestAuthorityModel? authorityModel;

  // 计划权限
  bool planAuthority = false;

  // 是否有智领权限,用于首页判断显示智领卡形式还是公益活动免费页面
  bool zhiLingAuthority = false;

  /// 是否出现过401
  bool hasOccur = false;

  /// 诊学练测是否刷新
  bool shouldRefresh = false;

  /// 是否是诊学练测当前页面
  bool isCurrentPage = false;

  /// 是否第一次安装APP
  bool isFirstInstallApp = false;

  /// app 当前版本号
  String appCurrentVersionString = "";

  /// 激活课程卡入口处理 默认:不是正在审核
  int? reviewStatus = 0;

  /// 诊学练测当前滚动距离
  double currentOffset = 0.0;

  /// 类调用实例
  static SingletonManager? get sharedInstance => _getInstance();

  /// 构造方法
  factory SingletonManager() => _getInstance()!;
  static SingletonManager? _sharedInstance;

  SingletonManager._internal() {
    print("初始化相关");
  }
  static SingletonManager? _getInstance() {
    if (_sharedInstance == null) {
      _sharedInstance = SingletonManager._internal();
    }
    return _sharedInstance;
  }
}
