import 'dart:async';
import 'package:flutter/material.dart';
import 'package:galaxy/screen/menu_screen.dart';
import 'dart:ui';
import 'dart:math';
import 'line.dart';
import 'package:audioplayers/audioplayers.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int noOfVerticalLines = 8;
  int noOfHorizontalLines = 10;
  List<Line> verticalLines = [];
  List<Line> horizontalLines = [];
  double verticalSpacing = 0.25;
  double horizontalSpacing = 0.1;
  var screenWidth = 2 * (window.physicalSize.shortestSide / window.devicePixelRatio);
  var screenHeight = (window.physicalSize.longestSide / window.devicePixelRatio)/2;
  var offsetY = 0.0;
  var offsetX = 0.0;
  double currentSpeedX = 0;
  double  speedY = 0.8;
  double  speedX = 4;
  int endLoop = 0;
  bool isGameOver = false;
  bool isGameStart = false;
  bool isPause = false;


  int noOfTile = 16;
  List indexOfTileCoordinate = [];
  List listOfTileCoordinates = [];
  int score = 0;

  double shipWidthFactor = .1;
  double shipBaseFactor = 0.035;
  double shipHeightFactor = 0.04;
  List shipCoordinates = [];
  late AudioPlayer beginMusic;
  late AudioPlayer galaxyMusic;
  late  AudioPlayer gameOverImpactMusic ;
  late  AudioPlayer  gameOverVoiceMusic ;
  late AudioPlayer  music1Music ;
  late AudioPlayer restartMusic ;

  @override
  void initState() {
    // TODO: implement initState
    setVerticalCoordinates();
    setHorizontalCoordinates();
    getPreFillTiles();
    updateTileCoordinates();
    initShip();
    initAudio();
    galaxyMusic.play(AssetSource('galaxy.wav'), volume: 0.25);
    super.initState();
  }
@override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    music1Music.dispose();
    restartMusic.dispose();
    beginMusic.dispose();
    galaxyMusic.dispose();
    gameOverVoiceMusic.dispose();
    gameOverImpactMusic.dispose();
  }

  void resetGame(){
     offsetY = 0.0;
     offsetX = 0.0;
    currentSpeedX = 0;
     endLoop = 0;
     score = 0;
     indexOfTileCoordinate = [];
     getPreFillTiles();
     updateTileCoordinates();
  }

  void initAudio() {
     beginMusic = AudioPlayer();
     galaxyMusic = AudioPlayer();
     gameOverImpactMusic = AudioPlayer();
     gameOverVoiceMusic = AudioPlayer();
     music1Music = AudioPlayer();
     music1Music.setReleaseMode(ReleaseMode.loop);
     restartMusic = AudioPlayer();
  }

  void initShip(){
    double centerX = screenWidth/2;
    double shipBase = shipBaseFactor * screenHeight;
    double shipHeight = shipHeightFactor * screenHeight;
    double shipWidth = shipWidthFactor * screenWidth/2;
    Offset point1 = transformCoordinate(Offset(centerX - shipWidth/2, shipBase));
    Offset point2 = transformCoordinate(Offset(screenWidth/2 , shipBase + shipHeight));
    Offset point3 = transformCoordinate(Offset(centerX + shipWidth/2, shipBase));
    shipCoordinates.addAll([point1, point2, point3]);
  }

  bool checkShipCollision(){
    for(var indexCoordinate in indexOfTileCoordinate){
      if(indexCoordinate[1] > endLoop + 1){
        return false;
      }
      if(checkShipCollisionWithTile(indexCoordinate[0], indexCoordinate[1])){
        return true;  //we  are on a track;
      }
    }
    return false;
  }

  //it checks whether the ship Coordinates is in between tiles coordinate or not!
  bool checkShipCollisionWithTile(int tiX, int tiY){
    Offset minOffset = getTileCoordinate(tiX, tiY);
    Offset maxOffset = getTileCoordinate(tiX+1, tiY+1);

    for(var shipCoordinate in shipCoordinates){
      if(minOffset.dx <= shipCoordinate.dx && maxOffset.dx >= shipCoordinate.dx
          && maxOffset.dy + 20 >= shipCoordinate.dy && minOffset.dy +20 <= shipCoordinate.dy){
        return true;
      }
    }
    return false;

  }

  // it creates vertical lines from centrex by index
   double getLineXFromIndex(int index){
    double offset = index.toDouble();
    double centreX = screenWidth/2 - 100;
    double spacing = screenWidth * verticalSpacing;
    double lineX = centreX + offset * spacing + offsetX;
    return lineX;
  }

  // it creates horizontal lines from centrex by index
  double getLineYFromIndex(int index){
    double lineY = index * screenHeight * horizontalSpacing - offsetY;
    return lineY;
  }

  // it transform horizontal line coordinate and add in list
  void setHorizontalCoordinates(){
    horizontalLines.clear();

    int startIndex = -(noOfVerticalLines/2 -1).toInt() ; //-1
    int endIndex = startIndex + (noOfVerticalLines) -1;  // 2
    double xMin= getLineXFromIndex(startIndex);
    double xMax= getLineXFromIndex(endIndex);

    for(var i= 0; i < noOfHorizontalLines; i++){
      double ptY = getLineYFromIndex(i);
      Offset trInitialPoint = transformCoordinate(Offset(xMin, ptY));
      Offset trEndPoint = transformCoordinate(Offset(xMax, ptY));

      final horizontalLine  = Line(
          initialPoint: trInitialPoint,
          endPoint: trEndPoint);
      horizontalLines.add(horizontalLine);
    }
  }

  //it transform coordinate of grid line to get required perspective for path
  Offset transformCoordinate(Offset offset){
    double perpY = 0.75 * screenHeight;
    double linY = offset.dy * perpY/screenHeight;
    if(linY > perpY){linY = perpY;}

    var diffX = offset.dx - screenWidth/2 ;
    var diffY = perpY - linY;
    var factorY = diffY/perpY;
    factorY = factorY * factorY * factorY * factorY;

    double transformY = (1- factorY) * perpY;
    double transformX = screenWidth/2 + (factorY) * diffX;
    return Offset(transformX, transformY);
  }

  void setVerticalCoordinates(){
    verticalLines.clear();
    int startIndex = -(noOfVerticalLines/2 -1).toInt(); //-3
    int endIndex = startIndex + (noOfVerticalLines ).toInt() ;  // 5
    for(var i = startIndex; i < endIndex; i++) {
      var  lineX =  getLineXFromIndex(i);
      final verticalLine  = Line(
          initialPoint: transformCoordinate(Offset(lineX, 0)),
          endPoint: transformCoordinate(Offset(lineX, screenHeight) ));
      verticalLines.add(verticalLine);
    }
    }


    // generate straight tiles by adding coordinate
    void getPreFillTiles(){
    for(var i = 0; i<11; i++){
      indexOfTileCoordinate.add([0, i]);
      }
    }



    Offset getTileCoordinate(int ptX, int ptY){
      ptY -= endLoop;
      double lineX = getLineXFromIndex(ptX);
      double lineY = getLineYFromIndex(ptY);
      return Offset(lineX, lineY);
    }

    void generateTiles(){
    var lastX = 0;
    var lastY = 0;
    int startIndex = -(noOfVerticalLines/2 -1).toInt() +1 ; //-3
    int endIndex = startIndex + (noOfVerticalLines ).toInt() -3;  // 5

    for(var i = indexOfTileCoordinate.length-1; i > -1; i--){
      if(indexOfTileCoordinate[i][1] < endLoop){
        indexOfTileCoordinate.removeAt(i);
        
        if(indexOfTileCoordinate.isNotEmpty){
          lastX = indexOfTileCoordinate.last[0];
          lastY = indexOfTileCoordinate.last[1] + 1;
        }

      }
    }
    for(var i = indexOfTileCoordinate.length; i < noOfTile; i++){
      int r  = Random().nextInt(3);

      if(lastX < startIndex){
        r = 1;
      }
      if(lastX >= endIndex){
        r = 2;
      }

     // one step Forward
      indexOfTileCoordinate.add([lastX,lastY]);

      if(r == 1){
        lastX += 1;
        indexOfTileCoordinate.add([lastX,lastY]);
        lastY += 1;
        indexOfTileCoordinate.add([lastX,lastY]);
      }
      if(r == 2){
        lastX -= 1;
        indexOfTileCoordinate.add([lastX,lastY]);
        lastY += 1;
        indexOfTileCoordinate.add([lastX,lastY]);
      }
    }
    }



    void updateTileCoordinates(){
    listOfTileCoordinates.clear();
    for(var indexCoordinate in indexOfTileCoordinate) {
      Offset minTileCoordinate = getTileCoordinate(
          indexCoordinate[0], indexCoordinate[1]);
      Offset maxTileCoordinate = getTileCoordinate(
          indexCoordinate[0] + 1, indexCoordinate[1] + 1);

      // xmin ymax         xmax ymax

      // xmin ymin         xmax ymin

      Offset point1 = transformCoordinate(
          Offset(minTileCoordinate.dx, minTileCoordinate.dy));
      Offset point2 = transformCoordinate(
          Offset(minTileCoordinate.dx, maxTileCoordinate.dy));
      Offset point3 = transformCoordinate(
          Offset(maxTileCoordinate.dx, maxTileCoordinate.dy));
      Offset point4 = transformCoordinate(
          Offset(maxTileCoordinate.dx, minTileCoordinate.dy));

      listOfTileCoordinates.add([point1, point2, point3, point4]);
    }
    }

  void update(){
    Timer.periodic(const Duration(milliseconds: 30 ), (timer) {
      if(isGameStart && mounted && !isGameOver){
        setState(() {
          offsetY += speedY * screenHeight/100;
          double changeInSpeedX = currentSpeedX * screenWidth/100;
          offsetX +=  changeInSpeedX;
          while(offsetY >= screenHeight*0.1){
            offsetY -= screenHeight *0.1;
            endLoop += 1;
            score = endLoop;
            generateTiles();
          }
        });
        setVerticalCoordinates();
        setHorizontalCoordinates();
        updateTileCoordinates();
        if(isPause){
          timer.cancel();
        }
      }


      if(!checkShipCollision()){
        music1Music.stop();
        timer.cancel();
        gameOverImpactMusic.play(AssetSource('gameover_impact.wav'), volume: .6);
        setState(() {
          isGameStart = false;
          isGameOver  = true;
        });
        Future.delayed(const Duration(seconds: 2), (){
          gameOverVoiceMusic.play(AssetSource('gameover_voice.wav'), volume: 0.25);
        });
        print('Game Over');
      }


    });
  }

  @override
  Widget build(BuildContext context) {
    double widthOfScreen = MediaQuery.of(context).size.width;
    double heightOfScreen = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // image
          GestureDetector(
            onTapDown: (details ){
              setState(() {
                if(details.globalPosition.dx > widthOfScreen/2){
                  //windows shift -->
                  currentSpeedX = -speedX;
                }else if(details.globalPosition.dx < widthOfScreen/2){  // tapping left side
                  //windows shift <--
                  currentSpeedX = speedX;
                }
              });
            },
            onTapUp:(details){
              setState(() {
                currentSpeedX = 0;
              });
            } ,
            child: RotatedBox(
              quarterTurns: 2,
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child:  Image.asset('images/bg1.jpg', fit: BoxFit.fill,)
              ),
            ),
          ),

          //path
          SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: CustomPaint(
              foregroundPainter: LinePainter(
                  tileCoordinates: listOfTileCoordinates,
                  verticalLine: verticalLines,
                  horizontalLine: horizontalLines,
              ),
            ),
          ),

          //ship
          SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: CustomPaint(
              foregroundPainter: ShipPainter(
                shipCoordinate: shipCoordinates,
              ),
            ),
          ),



          !isGameStart
              ? RotatedBox(
            quarterTurns: 2,
                child: SizedBox(
            height: heightOfScreen,
            width: widthOfScreen,
            child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children:  [
                     Text( isGameOver
                         ? 'G A M E    O V E R'
                         : 'G   A   L   A   X   Y',
                       style: const TextStyle(
                           color: Colors.white,
                          fontFamily: 'Sackers',
                        fontSize: 60,
                           fontWeight: FontWeight.bold),),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 60,
                          width: widthOfScreen/3,
                          child: ElevatedButton(
                              onPressed: (){
                                if(!isGameOver){
                                  beginMusic.play(AssetSource('begin.wav'),volume:0.25 );
                                }
                                setState(() {
                                  if(isGameOver){
                                    gameOverVoiceMusic.stop();
                                    resetGame();
                                    restartMusic.play(AssetSource('restart.wav'), volume: 0.25);
                                  }
                                  isGameOver = false;
                                  isGameStart = true;
                                });
                                music1Music.play(AssetSource('music1.wav'), volume: 1);
                                update();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.pinkAccent.withOpacity(0.8),
                                foregroundColor: Colors.white,
                              ),
                              child:  Text(
                                isGameOver
                                    ? 'RESTART'
                                    : 'START',
                                style: const TextStyle(
                                  fontSize: 25,
                                  fontFamily: 'Eurostile',
                                  letterSpacing: 10,
                                ),)),
                        ),
                        const SizedBox(width: 50,),
                       isGameOver? SizedBox(
                          height: 60,
                          width: widthOfScreen/3,
                          child: ElevatedButton(
                              onPressed: (){
                                Navigator.pushReplacement(context,
                                    MaterialPageRoute(builder: (context)=> MenuScreen()));
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
                        ) : Container(),
                      ],
                    )
                  ],
                ),
            ),
          ),
              )
              : RotatedBox(
              quarterTurns: 2,
              child: Container(
                height: double.infinity,
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text('SCORE: $score',
                    style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Eurostile',
                        fontWeight: FontWeight.bold,
                        fontSize: 20),),
                )
              )),

        ],
      ),
    );
  }
}

class LinePainter extends CustomPainter{
  final List<Line> verticalLine;
  final List<Line> horizontalLine;
  final List tileCoordinates;
  LinePainter({required this.horizontalLine, required this.verticalLine,
    required  this.tileCoordinates});
  @override
  void paint(Canvas canvas, Size size){
    final paint = Paint()..color = Colors.white..strokeWidth = 1;
    var tilePath = Path();

    for ( var line in verticalLine){
      Offset initialOffset  = line.initialPoint;
      Offset endOffset  = line.endPoint;
      canvas.drawLine(initialOffset, endOffset, paint);
    }


    for ( var line in horizontalLine){
      Offset initialOffset1  = line.initialPoint;
      Offset endOffset2  = line.endPoint;
      canvas.drawLine(initialOffset1, endOffset2, paint);
    }

    for(var point in tileCoordinates) {  //[[offset1, offset2, offset3, offset4], ]
      tilePath.moveTo(point[0].dx, point[0].dy);
      tilePath.lineTo(point[1].dx, point[1].dy);
      tilePath.lineTo(point[2].dx, point[2].dy);
      tilePath.lineTo(point[3].dx, point[3].dy);
      tilePath.lineTo(point[0].dx, point[0].dy);
      tilePath.close();
      canvas.drawPath(tilePath, paint);
    }


  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate){
    return true;
  }
}

class ShipPainter extends CustomPainter{
  final List shipCoordinate;
  ShipPainter({required this.shipCoordinate});
  @override
  void paint(Canvas canvas, Size size){
    var shipPath = Path();

    shipPath.moveTo(shipCoordinate[0].dx, shipCoordinate[0].dy);
    shipPath.lineTo(shipCoordinate[1].dx, shipCoordinate[1].dy);
    shipPath.lineTo(shipCoordinate[2].dx, shipCoordinate[2].dy);
    shipPath.lineTo(shipCoordinate[0].dx, shipCoordinate[0].dy);
    shipPath.close();
    canvas.drawPath(shipPath, Paint()..color = Colors.black);

  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate){
    return false;
  }
}

