import 'dart:io';

import 'package:my_gallery/common/locale/string_base.dart';

class MTTStringEn extends MTTStringBase {

  @override
  String? bottomTabbarItemHomeTitle = "Course";


  // ******************** 通用 begin ********************
  // 语文
  @override
  String? commonChinese = "Chinese";

  // 数学
  @override
  String? commonMathematics = "Mathematics";

  // 英语
  @override
  String? commonEnglish = "English";

  // 物理
  @override
  String? commonPhysical = "Physical";

  // 化学
  @override
  String? commonChemistry = "Chemistry";

  // 历史
  @override
  String? commonHistory = "History";

  // 生物
  @override
  String? commonBiology = "Biology";

  // 地理
  @override
  String? commonGeography = "Geography";

  // 政治
  @override
  String? commonPolitics = "Politics";

  // 没有数据
  @override
  String? commonNoData = "No Data";
  // ******************** 通用 end ********************


  // ******************** 1.2 个人中心 begin ********************
  // 标题
  @override
  String? personalPageNavigatorTitle = "";

  // 用户名label
  @override
  String? personalPageUserNameLabel = "User Name: ";

  // 我的下载
  @override
  String? personalPageMyDownload = "My Download";

  // 学习报告
  @override
  String? personalPageStudyReport = "Study Report";

  // 报告详情
  @override
  String? personalPageReportDetail = "Report Detail";

  // 错题本
  @override
  String? personaPageErrorBook = "Error Book";

  // 申请课程卡
  @override
  String? personalPageApplyForCourseCard = "Apply for Course Card";

  // 激活课程
  @override
  String? personalPageActivateCourse = "Activate Course";

  // 我的卡记录
  @override
  String? personalPageMyCardRecord = "My Card Record";

  // 护眼提醒
  @override
  String? personalPageEyeProtectionReminder = "Eye Protection Reminder";

  // 意见反馈
  @override
  String? personalPageFeedback = "Feedback";

  // 帮助
  @override
  String? personalPageHelp = "Help";

  // 设置
  @override
  String? personalPageSetting = "Setting";

  // 湖北爱心助学公益课 免费申请
  @override
  String? personalPageHubeiPublicWelfareClass = "Hubei Public Welfare Class";
  // ******************** 个人中心 end ********************


  // ******************** 1.2.1 我的下载页面 begin ********************
  // 标题
  @override
  String? myDownloadPageNavigatorTitle = "My Download";
  // ******************** 我的下载页面 end ********************


  // ******************** 1.2.3 错题本页面 begin ********************
  // 标题
  @override
  String? errorBookPageNavigatorTitle = "Error Book";

  // 系统错题
  @override
  String? errorBookPageSystemErrorItem = "System Error Item";

  @override
  String? errorBookPageUnitTestErrorItem = "Unit Test Error Item";

  // 上传错题
  @override
  String? errorBookPageUploadErrorItem = "Upload Error Item";

  // 数字化校园错题
  @override
  String? errorBookPageDigitalCampusErrorItem = "Digital Campus Error Item";

  // 管理选择
  @override
  String? errorBookPageChoose = "Choose";

  // 取消
  @override
  String? errorBookPageCancel = "Cancel";

  // 拍照上传
  @override
  String? errorBookPageTakePhoto = "Take Photo";
  // ******************** 1.2.3 错题本页面 end ********************


  // ******************** 1.2.4 申请课程卡页面 begin ********************
  // 标题
  @override
  String? applyForCourseCardPageNavigatorTitle = "Apply for Course Card";

  // 内容
  @override
  String? applyForCourseCardPageContent = Platform.isIOS ? "如果您有智领卡, 可以在这里申请。" : "如果您有智领卡, 可以在这里激活。";

  // 卡号
  @override
  String? applyForCourseCardPageCardNum = "Card Num";

  // 密码
  @override
  String? applyForCourseCardPageCamille = "Camile";

  // 提交
  @override
  String? applyForCourseCardPageCommit = Platform.isIOS ? "Commit" : "Activate";
  // ******************** 1.2.4 申请课程卡页面 end ********************


  // ******************** 1.2.5 我的卡记录页面 begin ********************
  // 标题
  @override
  String? myCardPageNavigatorTitle = "My Card Record";
  // ******************** 1.2.5 我的卡记录页面 end ********************


  // ******************** 1.2.6 护眼提醒页面 begin ********************
  // 标题
  @override
  String? eyeProtectionReminderPageNavigatorTitle = "Eye Protection Reminder";

  // 内容
  @override
  String? eyeProtectionReminderPageContent = "为了预防学生用眼过度，四中网校为同学们提供了护眼提醒功能。使用四中网校每达到20分钟，就会收到APP的护眼提醒，同学们可以站起身放松一下，避免长时间盯住屏幕对视力造成伤害。保护同学们在舒适、健康的环境下学习，天天向上！";
  // ******************** 1.2.6 护眼提醒页面 end ********************


  // ******************** 1.2.7 意见反馈页面 begin ********************
  // 标题
  @override
  String? feedbackPageNavigatorTitle = "Commit Comment";

  // 内容
  @override
  String? feedbackPageContent = "少年，给应用打个分吧";

  // 输入框提示
  @override
  String? feedbackPageInputHint = "欢迎吐槽（5-500个字）";

  // 发布
  @override
  String? feedbackPageSend = "Send";
  // ******************** 1.2.7 意见反馈页面 end ********************


  // ******************** 1.2.8 帮助页面 begin ********************
  // 标题
  @override
  String? helpPageNavigatorTitle = "Help";
  // ******************** 1.2.8 帮助页面 end ********************


  // ******************** 1.2.9 设置页面 begin ********************
  // 标题
  @override
  String? settingPageNavigatorTitle = "Setting";

  // 个人信息
  @override
  String? settingPagePersonalInfo = "Person Info";

  // 修改密码
  @override
  String? settingPageChangePassword = "Change Password";

  // 修改手机号
  @override
  String? settingPageChangeMobileNum = "Change Mobile Num";

  // 关于我们
  @override
  String? settingPageAbout = "About";

  // 故障排查
  @override
  String? settingPageTroubleShoot = "Trouble Shoot";

  // 仅WiFi下载
  @override
  String? settingPageWifiDownloadOnly = "WiFi Download Only";

  // 检查新版本
  @override
  String? settingPageCheckVersion = "Check Version";

  // 切换语言
  @override
  String? settingPageChangeLanguage = "Change Language";

  // 切换主题
  @override
  String? settingPageChangeTheme = "Change Theme";

  // 退出登录
  @override
  String? settingPageSignOut = "Sign Out";
  // ******************** 1.2.9 设置页面 end ********************


  // ******************** 1.2.9.1 个人信息页面 begin ********************

  // 标题
  @override
  String? personalInfoPageNavigatorTitle = "Personal Info";

  // 用户ID
  @override
  String? personalInfoPageUserId = "User ID";

  // 用户名
  @override
  String? personaInfoPageUserName = "User Name";

  // 真实姓名
  @override
  String? personalInfoPageRealName = "Real Name";

  // 性别
  @override
  String? personalInfoPageGender = "Gender";

  // 生日
  @override
  String? personalInfoPageBirthday = "Birthday";

  // 家庭住址
  @override
  String? personalInfoPageAddress = "Address";

  // 邮箱
  @override
  String? personalInfoPageEmail = "Email";

  // 点击修改头像
  @override
  String? personalInfoPageEditAvatar = "Edit Avatar";

  // 编辑
  @override
  String? personalInfoPageEdit = "Edit";

  // 保存
  @override
  String? personalInfoPageSave = "Save";

  // 男
  @override
  String? personalInfoPageMale = "Male";

  // 女
  @override
  String? personalInfoPageFemale = "Female";
  // ******************** 1.2.9.1 个人信息页面 end ********************


  // ******************** 切换语言页面 begin ********************
  // 切换语言页面导航栏标题
  @override
  String? changeLanguageNavigatorTitle = "Change Language";

  // 切换语言中文标题
  @override
  String? changeLanguageChineseTitle = "Simplified Chinese";

  // 切换语言英文标题
  @override
  String? changeLanguageEnglishTitle = "English";
// ******************** 切换语言页面 end ********************

}
