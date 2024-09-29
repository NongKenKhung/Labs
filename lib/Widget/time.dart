
import 'package:flutter/material.dart';

  Widget time(BuildContext context,String time) {
    return GestureDetector(
      onTap: (){},
      child: Container(
        width: 250,
        height: 250,
        decoration: const BoxDecoration(
          color: Colors.grey,
          shape: BoxShape.circle,
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("data"),
              ],
            )
          ],
        )
      ),
    );
  }
