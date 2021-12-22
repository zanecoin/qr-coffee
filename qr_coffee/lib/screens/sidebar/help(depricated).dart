// import 'package:qr_coffee/shared/custom_app_bar.dart';
// import 'package:qr_coffee/shared/strings.dart';
// import 'package:flutter/material.dart';
// import 'package:qr_coffee/models/article.dart';
// import 'package:qr_coffee/service/database.dart';
// import 'package:qr_coffee/shared/loading.dart';

// class Help extends StatefulWidget {
//   @override
//   _HelpState createState() => _HelpState();
// }

// class _HelpState extends State<Help> {
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<List<Article>>(
//       stream: DatabaseService().articleList,
//       builder: (context, snapshot) {
//         if (snapshot.hasData) {
//           List<Article> articles = snapshot.data!;

//           return Scaffold(
//             appBar: customAppBar(context, title: Text(CzechStrings.help)),
//             body: Container(
//               child: ListView.builder(
//                 itemBuilder: (context, index) =>
//                     ArticleTile(article: articles[index]),
//                 itemCount: articles.length,
//                 shrinkWrap: true,
//               ),
//             ),
//           );
//         } else {
//           return Loading();
//         }
//       },
//     );
//   }
// }

// class ArticleTile extends StatelessWidget {
//   final Article? article;
//   ArticleTile({this.article});

//   @override
//   Widget build(BuildContext context) {
//     return ExpansionTile(
//       title: Text(article!.title, style: TextStyle(fontSize: 18)),
//       children: [
//         Container(
//           padding: EdgeInsets.fromLTRB(15, 0, 15, 15),
//           child: Text(article!.body, style: TextStyle(fontSize: 16)),
//         )
//       ],
//     );
//   }
// }
