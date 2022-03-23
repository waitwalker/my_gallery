import 'dart:io';

import 'package:my_gallery/common/locale/string_base.dart';

class MTTStringZh extends MTTStringBase {

  @override
  String? bottomTabbarItemHomeTitle = "我的课程";


  // ******************** 通用 begin ********************
  // 语文
  @override
  String? commonChinese = "语文";

  // 数学
  @override
  String? commonMathematics = "数学";

  // 英语
  @override
  String? commonEnglish = "英语";

  // 物理
  @override
  String? commonPhysical = "物理";

  // 化学
  @override
  String? commonChemistry = "化学";

  // 历史
  @override
  String? commonHistory = "历史";

  // 生物
  @override
  String? commonBiology = "生物";

  // 地理
  @override
  String? commonGeography = "地理";

  // 政治
  @override
  String? commonPolitics = "政治";
  
  // 没有数据
  @override
  String? commonNoData = "没有数据";
  // ******************** 通用 end ********************


  // ******************** 1.2 个人中心 begin ********************
  // 标题
  @override
  String? personalPageNavigatorTitle = "";

  // 用户名label
  @override
  String? personalPageUserNameLabel = "用户名: ";

  // 我的下载
  @override
  String? personalPageMyDownload = "我的下载";

  // 学习报告
  @override
  String? personalPageStudyReport = "学习报告";

  // 报告详情
  @override
  String? personalPageReportDetail = "报告详情";

  // 错题本
  @override
  String? personaPageErrorBook = "错题本";

  // 申请课程卡
  @override
  String? personalPageApplyForCourseCard = "申请课程卡";

  // 激活课程
  @override
  String? personalPageActivateCourse = "激活课程";

  // 我的卡记录
  @override
  String? personalPageMyCardRecord = "我的卡记录";

  // 护眼提醒
  @override
  String? personalPageEyeProtectionReminder = "护眼提醒";

  // 意见反馈
  @override
  String? personalPageFeedback = "意见反馈";

  // 帮助
  @override
  String? personalPageHelp = "帮助";

  // 设置
  @override
  String? personalPageSetting = "设置";

  // 湖北爱心助学公益课 免费申请
  @override
  String? personalPageHubeiPublicWelfareClass = "湖北爱心助学公益课 免费申请";
  // ******************** 个人中心 end ********************


  // ******************** 1.2.1 我的下载页面 begin ********************
  // 标题
  @override
  String? myDownloadPageNavigatorTitle = "我的下载";
  // ******************** 我的下载页面 end ********************


  // ******************** 1.2.3 错题本页面 begin ********************
  // 标题
  @override
  String? errorBookPageNavigatorTitle = "错题本";

  // 系统错题
  @override
  String? errorBookPageSystemErrorItem = "系统错题";

  // 上传错题
  @override
  String? errorBookPageUploadErrorItem = "上传错题";

  @override
  String? errorBookPageUnitTestErrorItem = "质检消错错题";

  // 数字化校园错题
  @override
  String? errorBookPageDigitalCampusErrorItem = "数字化校园错题";

  // 管理选择
  @override
  String? errorBookPageChoose = "管理";

  // 取消
  @override
  String? errorBookPageCancel = "取消";

  // 拍照上传
  @override
  String? errorBookPageTakePhoto = "拍照上传";
  // ******************** 1.2.3 错题本页面 end ********************


  // ******************** 1.2.4 申请课程卡页面 begin ********************
  // 标题
  @override
  String? applyForCourseCardPageNavigatorTitle = "课程申请";

  // 内容
  @override
  String? applyForCourseCardPageContent = Platform.isIOS ? "如果您有智领卡, 可以在这里申请。" : "如果您有智领卡, 可以在这里激活。";

  // 卡号
  @override
  String? applyForCourseCardPageCardNum = "卡号";

  // 密码
  @override
  String? applyForCourseCardPageCamille = "密码";

  // 提交
  @override
  String? applyForCourseCardPageCommit = Platform.isIOS ? "提交" : "激活";
  // ******************** 1.2.4 申请课程卡页面 end ********************


  // ******************** 1.2.5 我的卡记录页面 begin ********************
  // 标题
  @override
  String? myCardPageNavigatorTitle = "我的卡记录";
  // ******************** 1.2.5 我的卡记录页面 end ********************


  // ******************** 1.2.6 护眼提醒页面 begin ********************
  // 标题
  @override
  String? eyeProtectionReminderPageNavigatorTitle = "护眼提醒";

  // 内容
  @override
  String? eyeProtectionReminderPageContent = "为了预防学生用眼过度，四中网校为同学们提供了护眼提醒功能。使用四中网校每达到20分钟，就会收到APP的护眼提醒，同学们可以站起身放松一下，避免长时间盯住屏幕对视力造成伤害。保护同学们在舒适、健康的环境下学习，天天向上！";
  // ******************** 1.2.6 护眼提醒页面 end ********************


  // ******************** 1.2.7 意见反馈页面 begin ********************
  // 标题
  @override
  String? feedbackPageNavigatorTitle = "发表评论";

  // 内容
  @override
  String? feedbackPageContent = "少年，给应用打个分吧";

  // 输入框提示
  @override
  String? feedbackPageInputHint = "欢迎吐槽（5-500个字）";

  // 发布
  @override
  String? feedbackPageSend = "发布";
  // ******************** 1.2.7 意见反馈页面 end ********************


  // ******************** 1.2.8 帮助页面 begin ********************
  // 标题
  @override
  String? helpPageNavigatorTitle = "帮助";
  // ******************** 1.2.8 帮助页面 end ********************


  // ******************** 1.2.9 设置页面 begin ********************
  // 标题
  @override
  String? settingPageNavigatorTitle = "设置";

  // 个人信息
  @override
  String? settingPagePersonalInfo = "个人信息";

  // 修改密码
  @override
  String? settingPageChangePassword = "修改密码";

  // 修改手机号
  @override
  String? settingPageChangeMobileNum = "修改手机号";

  // 关于我们
  @override
  String? settingPageAbout = "关于我们";

  // 故障排查
  @override
  String? settingPageTroubleShoot = "故障排查";

  // 仅WiFi下载
  @override
  String? settingPageWifiDownloadOnly = "仅WiFi下载";

  // 检查新版本
  @override
  String? settingPageCheckVersion = "检查新版本";

  // 切换语言
  @override
  String? settingPageChangeLanguage = "切换语言";

  // 切换主题
  @override
  String? settingPageChangeTheme = "切换主题";

  // 退出登录
  @override
  String? settingPageSignOut = "退出登录";
  // ******************** 1.2.9 设置页面 end ********************


  // ******************** 1.2.9.1 个人信息页面 begin ********************

  // 标题
  @override
  String? personalInfoPageNavigatorTitle = "个人信息";

  // 用户ID
  @override
  String? personalInfoPageUserId = "用户ID";

  // 用户名
  @override
  String? personaInfoPageUserName = "用户名";

  // 真实姓名
  @override
  String? personalInfoPageRealName = "真实姓名";

  // 性别
  @override
  String? personalInfoPageGender = "性别";

  // 生日
  @override
  String? personalInfoPageBirthday = "生日";

  // 家庭住址
  @override
  String? personalInfoPageAddress = "家庭住址";

  // 邮箱
  @override
  String? personalInfoPageEmail = "邮箱";

  // 点击修改头像
  @override
  String? personalInfoPageEditAvatar = "点击修改头像";

  // 编辑
  @override
  String? personalInfoPageEdit = "编辑";

  // 保存
  @override
  String? personalInfoPageSave = "保存";

  // 男
  @override
  String? personalInfoPageMale = "男";

  // 女
  @override
  String? personalInfoPageFemale = "女";
  // ******************** 1.2.9.1 个人信息页面 end ********************


  // ******************** 切换语言页面 begin ********************
  // 标题
  @override
  String? changeLanguageNavigatorTitle = "切换语言";

  // 切换语言中文标题
  @override
  String? changeLanguageChineseTitle = "中文简体";

  // 切换语言英文标题
  @override
  String? changeLanguageEnglishTitle = "English";
// ******************** 切换语言页面 end ********************


}
