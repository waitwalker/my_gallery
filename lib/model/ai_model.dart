import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ai_model.g.dart';

@JsonSerializable()
class AiModel {
  num? code;
  String? msg;
  List<Data>? data;

  AiModel({this.code, this.msg, this.data});

  factory AiModel.fromJson(Map<String, dynamic> json) =>
      _$AiModelFromJson(json);

  Map<String, dynamic> toJson() => _$AiModelToJson(this);
}

@JsonSerializable()
// ignore: must_be_immutable
class Data extends Equatable {
  num? materialId;
  bool? newChapter;
  String? chapterName;
  num? chapterId;
  num? level;
  num? orderId;
  bool? publishable;
  num? starNum;
  num? score;
  num? parentId;
  List<Data>? chapterList;

  Data(
      {this.materialId,
      this.newChapter,
      this.chapterName,
      this.chapterId,
      this.level,
      this.orderId,
      this.publishable,
      this.starNum,
      this.score,
      this.parentId,
      this.chapterList});

  factory Data.fromJson(Map<String, dynamic> json) =>
      _$DataEntityFromJson(json);

  Map<String, dynamic> toJson() => _$DataEntityToJson(this);

  @override
  // TODO: implement props
  List<Object> get props => throw UnimplementedError();
}
