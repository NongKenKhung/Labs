// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:m5/Widget/Tap.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60), 
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
        ),
      child: AppBar(
        backgroundColor: Colors.red[900],
        title: Text("MeKhaMoiMai",
          style: GoogleFonts.prompt(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold),
        ),
      )
            
        ),
      ),

      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Text("Home",
              style: GoogleFonts.prompt(
                fontSize: 16,
                color: Colors.indigo[900],
                fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.75,
              child: Tap(context),
            )
          ],
        ),
      ),
    );
  }


}