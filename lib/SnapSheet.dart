// import 'package:snapping_sheet/snapping_sheet.dart';
// import 'package:flutter/material.dart';
// import 'package:hello_me/user_repository.dart';
//
// class SnapSheet extends StatelessWidget {
//   final UserRepository user;
//   SnapSheet(UserRepository user) : user = user;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Placeholder example'),
//       ),
//       body: SnappingSheet(
//           // child: Placeholder(
//           //   color: Colors.red,
//           // ),
//           sheetBelow: SnappingSheetContent(
//               child: Placeholder(
//                 color: Colors.blue,
//               ),
//               heightBehavior: SnappingSheetHeight.fit()),
//           grabbing: Container(
//             color: Colors.white.withOpacity(0.0),
//             child: Placeholder(
//               color: Colors.green,
//             ),
//           ),
//           // sheetAbove: SnappingSheetContent(
//           //   child: Placeholder(
//           //     color: Colors.purple,
//           //   ),
//           //   heightBehavior: SnappingSheetHeight.fit(),
//           // )
//         ),
//     );
//   }
// }