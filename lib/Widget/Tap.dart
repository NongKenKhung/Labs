// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:m5/Screen/HomeState.dart';

// ignore: non_constant_identifier_names
Widget Tap(BuildContext context){
  return GestureDetector(
    onTap: (){
      Navigator.push(context, MaterialPageRoute(builder: (context){
        return  const HomeState();
      }));
    },
    child: Container(
      width: 300,
      height: 65,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(255, 234, 199, 1),
        borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Text("Home 1",
                  style: GoogleFonts.prompt(
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.black,
                )
              ],
            )
          ],
        ),
      ),
    ),
  );
}