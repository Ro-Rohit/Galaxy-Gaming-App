import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:galaxy/screen/homescreen.dart';
import 'clipVideo.dart';
import 'package:audioplayers/audioplayers.dart';
class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final TextEditingController controller = TextEditingController();
  String hintText = 'Submit Your Name!';
  bool changePositioned = false;
  late AudioPlayer bgMusic ;
  @override
  void initState() {
    // TODO: implement initState
    bgMusic = AudioPlayer();
    bgMusic.setReleaseMode(ReleaseMode.loop);
    bgMusic.play(AssetSource('strangerthings.mp3'), volume: 1);
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    controller.dispose();
    bgMusic.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    final widthOfScreen  = MediaQuery.of(context).size.width;
    return Scaffold(
      body: RotatedBox(
        quarterTurns: 2,
        child: Stack(
          children:  [
            const SizedBox(
              height: double.infinity,
              width: double.infinity,
              child: ClipVideo(),
            ),
            SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(top: 50, left: 10, right: 10),
                child: Column(
                  children:  [
                    const Text('Welcome To The Parallel Universe',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                      fontFamily: 'Sackers',
                      fontSize: 30,
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),),
                    const SizedBox(height: 40,),
                    Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: widthOfScreen/2,
                        child: TextField(
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'Eurostile'),
                          controller: controller,
                          onChanged: (value){
                            controller.text =  value;
                          },
                          decoration: InputDecoration(
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.pinkAccent)
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.greenAccent, width: 5),
                            ),
                            hintText: hintText,
                            hintStyle: const TextStyle(color: Colors.white, fontSize: 25, fontFamily: 'Eurostile' ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 60,
                          width: widthOfScreen/3,
                          child: ElevatedButton(
                              onPressed: (){
                              if(controller.text.isNotEmpty){
                                bgMusic.stop();
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>const HomeScreen()));
                               }
                              if(controller.text.isEmpty){
                                setState(() {
                                  hintText = 'Enter your name first';
                                });

                              }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.pinkAccent.withOpacity(0.8),
                                foregroundColor: Colors.white,
                              ),
                              child:  const Text('PLAY',
                                style: TextStyle(
                                  fontSize: 25,
                                  fontFamily: 'Eurostile',
                                  letterSpacing: 10,
                                ),)),
                        ),
                        const SizedBox(width: 20,),
                        SizedBox(
                          height: 60,
                          width: widthOfScreen/3,
                          child: ElevatedButton(
                              onPressed: (){
                                bgMusic.stop();
                                SystemNavigator.pop();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.pinkAccent.withOpacity(0.8),
                                foregroundColor: Colors.white,
                              ),
                              child:  const Text('Quit',
                                style: TextStyle(
                                  fontSize: 25,
                                  fontFamily: 'Eurostile',
                                  letterSpacing: 10,
                                ),)),
                        ),

                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
