// import 'dart:convert';
// import 'dart:typed_data';
//
// import 'package:my_gallery/common/tools/encryption/sign.dart';
// import 'package:encrypt/encrypt.dart';
// import 'dart:convert' as convert;
//
// void main() {
//   //foo();
//
//
// }
//
// aesFunction() {
//   String iv = "22d37480aa90374c";
//   List<int> list = utf8.encode(iv);
//   Uint8List bytes = Uint8List.fromList(list);
//   var encryptText = encryptAes("f2c9675f05739aa83bcac5abf7beb6e5c3e524775787d685948b67c8831d3cc0",iv: IV(bytes), aesKey: "d2efb38516a246de");
//   Base64Codec bc = Base64Codec();
//   String str = bc.encode(encryptText.bytes);
//   print(str);
//
//   String value = decryptAes(str,iv: IV(bytes), aesKey: "d2efb38516a246de");
//   print(value);
// }
//
// String aesDecrypt(String encryptText, {String key: "#YXW#COMMON#2016"}) {
//   // final encrypter = new Encrypter(new AES(key));
//   // final decryptedText = encrypter.decrypt(encryptText);
//   //
//   // return decryptedText;
//
//   final theKey = Key.fromUtf8(key);
//   // 初始化的向量官方代码里是这么注释的{Represents an Initialization Vector}
//   final iv = IV.fromLength(16);
//   //加密容器
//   final encrypter = Encrypter(AES(theKey));
//   //加密部分
//   final encrypted = encrypter.encrypt(encryptText, iv: iv);
//   //解密部分
//   final decrypted = encrypter.decrypt(encrypted, iv: iv);
//   return decrypted;
// }
//
// foo() {
//   var encryptText =
//       'BADF104A9C33AB4941561BE5D44823D515C3CA2997851F9DFC697E47AFC295021E8DA50549E58714001C8F522FD98477F54AFCE4FA1F44AB3E3A049E5DE0945310E9BF07E6B5EB41D40ED43404098F3D51E080E0615C2DA86C162D914CA3BA7F1F643614861B589983E07CFE6FC1FF106D9D99B35AB751F8FFB8150C5D18D039580F5B0C22E6BD04267EF98E10C86A221E5F5D9D84E33B2B8E0B68FFE2102ABFF8CF8E17726EB4883B3AAB4F4105777E85999370D51E46700CE14F7A77DB4B2038230945402ADC49B891F15D2D182737CE8AC80702A5828A6AC8D13D5D86528F5A035B9310388E6105659CE0C592DCB6AFEE92DA424BD55FE85C6CFCC6CCAE0D367C0486FB008D01EEC8B4836F3F7FE4CF8F9E90E5BA197A3BA12745A4A1173112438BA8E8D42C3ABF18487C8052E7256BF4D70ACD8FE43FEBF150B71BEA7E37AC4C4ACC3A4C9B86914C660DE57BA46DE5AB819E19F7163DA7E16B3049B825FEC9C90C81C0EE5DF94A11C954B1579A9960CA7CF6DCA5EC92750493AC4164D35F4968F5C95D683792307F500F41C422F351D6CFC6D655F4FE3D1D93CBD0D4E553193B58187418D641F903B70D7CCC60C34C15EFE2907ADC6ACED5FD332A51552B2A2500E9CFD671A79673BB00D021FACC224B2A85E352E9E9A436A83312DAC634E710C82757AB80529ECF9236B4C72316';
//   var orderInfo = SignUtil.aesDecrypt(encryptText);
//   var split = orderInfo.split('&');
//   var kvList = split.map((kv) => kv.split('='));
//   print(kvList);
// }
//
// Encrypted encryptAes(String content, {AESMode aesMode = AESMode.cfb64, IV? iv, String aesKey: "#YXW#COMMON#2016"}) {
//   final _aesKey = Key.fromUtf8(aesKey);
//   final _encrypter = Encrypter(AES(_aesKey, mode: aesMode));
//   final _encrypted = _encrypter.encrypt(content,iv: iv);
//
//   return _encrypted;
// }
//
// String decryptAes(String content, {AESMode aesMode = AESMode.cfb64,IV? iv, String aesKey: "#YXW#COMMON#2016",}) {
//
//   var _res = convert.base64.decode(content);
//   final _aesKey = Key.fromUtf8(aesKey);
//   final _encrypter =
//   Encrypter(AES(_aesKey, mode: AESMode.cfb64));
//   final _decrypted = _encrypter.decrypt(Encrypted(_res),iv: iv);
//
//   return _decrypted;
// }
