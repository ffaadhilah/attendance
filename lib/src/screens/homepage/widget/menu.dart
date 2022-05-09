import 'package:flutter/material.dart';

class MenuContainer extends StatelessWidget {
  MenuContainer(
      {this.icon, this.onpressed, this.title, this.index, this.absencetext});
  final Image icon;
  final Function onpressed;
  final String title;
  final int index;
  final String absencetext;
  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 170.0,
      // width: 120.0,
      height: 120.0,
      width: 240.0,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 10.0,
            offset: Offset(0.0, 12.0),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          IconButton(icon: icon, iconSize: 100, onPressed: onpressed),
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          index == 1
              ? Text(
                  absencetext,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrangeAccent),
                )
              : Container(),
        ],
      ),
    );
  }
}
