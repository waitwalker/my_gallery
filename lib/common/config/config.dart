class Config {

  /// 生产和测试环境切换 static const DEBUG = bool.fromEnvironment("dart.vm.product"); //生产环境
  ///static const DEBUG = !bool.fromEnvironment("dart.vm.product"); ///上线时候状态
  static const DEBUG = bool.fromEnvironment("dart.vm.product");
  /// --flavor develop

  /// ////////////////////////////////////// 只读变量 ////////////////////////////////////// ///
  /// 区别设备
  static const _device1 = "iPhone 11 Pro";
  static const _device2 = "13691583024";
  static const DEVICE_NAME = _device2;

}
