import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_gallery/common/const/api_const.dart';
import 'package:my_gallery/common/network/network_manager.dart';
import 'package:my_gallery/modules/my_course/intelligence_question_database/chapter_practice_page.dart';
import 'package:my_gallery/modules/my_course/intelligence_question_database/real_question_page.dart';
import 'package:my_gallery/modules/my_course/wisdom_study/scroll_to_index/new_scroll_to_index.dart';
import 'package:my_gallery/modules/widgets/webviews/common_webview_page.dart';

///
/// @description 智能题库入口页面
/// @author waitwalker
/// @time 3/26/21 1:51 PM
///
class IntelligenceEntrancePage extends StatefulWidget {

  /// 年级，学科，课 id
  final int courseId;
  final int? subjectId;
  final int? gradeId;

  /// 预览模式，适用于未激活用户，只能看第一条，默认为用户打开
  final bool? previewMode;

  IntelligenceEntrancePage(this.courseId, this.subjectId, this.gradeId, {this.previewMode});

  @override
  State<StatefulWidget> createState() {
    return _IntelligenceQuestionDatabaseEntranceState();
  }
}

class _IntelligenceQuestionDatabaseEntranceState extends State<IntelligenceEntrancePage> {

  List<Map<String, String>> dataSource = [
    {
      "title" : "章节练习",
      "image" : "static/images/intelligence_chapter_icon.png",
    },
    {
      "title" : "历年真题",
      "image" : "static/images/intelligence_real_icon.png",
    },
    {
      "title" : "错题重练",
      "image" : "static/images/intelligence_error_book.png",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("智能练习"),
      ),
      body: Padding(padding: EdgeInsets.only(
        left: 16, top: 16, right: 16,),
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                itemBuilder: _itemBuilder,
                itemCount: 3,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.91,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///
  /// @description 构建卡片
  /// @author waitwalker
  /// @time 3/26/21 2:12 PM
  ///
  Widget _itemBuilder(BuildContext context, int index) {

    Map map = dataSource[index];
    String? itemTitle = map["title"];
    String itemImage = map["image"];

    return InkWell(
      child: Container(
        child: Column(
          children: [
            Padding(padding: EdgeInsets.only(top: 21)),
            Text("$itemTitle", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500),),
          ],
        ),
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage(itemImage), fit: BoxFit.fill),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Color(0x66B2C1D9),
              offset: Offset(3, 4),
              blurRadius: 10.0,
              spreadRadius: 2.0,
            ),
          ],
        ),
      ),
      onTap: (){
        if (index == 0) {
          /// 章节练习
          Navigator.push(context, MaterialPageRoute(builder: (context){
            return ChapterPracticePage(
              widget.courseId,
              widget.subjectId,
              widget.gradeId,
              scrollController: ChapterAutoScrollController(),
              useRecord: !widget.previewMode!,
              previewMode: widget.previewMode,
            );
          }));
        } else if (index == 1) {
          /// 历年真题
          Navigator.push(context, MaterialPageRoute(builder: (context){
            return RealQuestionPage(
              courseId: widget.courseId,
              subjectId: widget.subjectId,
              gradeId: widget.gradeId,
            );
          }));
        } else if (index == 2) {
          /// 跳转到网页错题本详情 数校和网校
          Navigator.of(context).push(MaterialPageRoute(builder: (_) {
            var url = APIConst.errorBook;
            var token = NetworkManager.getAuthorization();
            return CommonWebviewPage(
              initialUrl: '$url?token=$token&subjectid=${widget.subjectId}',
              subjectId: widget.subjectId,
              fromShuXiao: false,
              pageType: 1,
            );
          }));
        }
      },
    );
  }

}