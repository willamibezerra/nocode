// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_tflite/flutter_tflite.dart';

// void main() async {
//   runApp(MaterialApp(
//     home: RectangleDetectionApp(),
//   ));
// }

// class RectangleDetector {
//   static const String MODEL_PATH = 'assets/ssd_mobilenet.tflite';
//   static const String LABELS_PATH = 'assets/ssd_mobilenet.txt';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:simplytranslate/simplytranslate.dart' as translator;
import 'package:translator/translator.dart';

void main() async {
  runApp(MaterialApp(
    home: RectangleDetectionApp(),
  ));
}

class RectangleDetector {
  static const String MODEL_PATH = 'assets/ssd_mobilenet.tflite';
  static const String LABELS_PATH = 'assets/ssd_mobilenet.txt';

  Future<void> loadModel() async {
    Tflite.close();
    try {
      await Tflite.loadModel(
        model: MODEL_PATH,
        labels: LABELS_PATH,
      );
    } catch (e) {
      print('Erro ao carregar o modelo: $e');
    }
  }

  Future<List<dynamic>> detectRectangles(CameraImage image) async {
    //  if (Tflite.isModelLoaded()) {
    var recognitions = await Tflite.detectObjectOnFrame(
      bytesList: image.planes.map((plane) {
        return plane.bytes;
      }).toList(),
      //  modelIndex: 0,
      imageHeight: image.height,
      imageWidth: image.width,
      imageMean: 127.5,
      imageStd: 127.5,
      numResultsPerClass: 1,
      threshold: 0.4,
    );

    return recognitions!;
    // // }

    // return [];
  }

  void dispose() {
    Tflite.close();
  }
}

class RectangleDetectionApp extends StatefulWidget {
  @override
  _RectangleDetectionAppState createState() => _RectangleDetectionAppState();
}

class _RectangleDetectionAppState extends State<RectangleDetectionApp> {
  CameraController? controller;
  // late CameraController _cameraController;
  late RectangleDetector _rectangleDetector;
  // loadCamera() async {
  //   cameras = await availableCameras();
  //   if (cameras != null) {
  //     controller = CameraController(cameras![0], ResolutionPreset.max);
  //     //cameras[0] = first camera, change to 1 to another camera

  //     controller!.initialize().then((_) {
  //       if (!mounted) {
  //         return;
  //       }
  //       setState(() {});
  //     });
  //   } else {
  //     print("NO any camera found");
  //   }
  // }
  Future<Widget> translat(String content) async {
    final translator = GoogleTranslator();

    Translation translation =
        await translator.translate(content, from: 'en', to: 'pt');

    String data = translation.text;
    traducao = translation.text;
    setState(() {});
    return Column(
      children: [
        SizedBox(
          height: 600,
        ),
        Center(child: Text(data)),
      ],
    );
  }

  List<CameraDescription>? cameras;
  bool _isDetecting = false;
  String traducao = '';
  List<dynamic> itens = [];
  @override
  void initState() {
    super.initState();

    _initDetector();
  }

  // Future<void> _initCamera() async {
  //   WidgetsFlutterBinding.ensureInitialized();
  //   final firstCamera = <CameraDescription>[];

  //   _cameraController =
  //       CameraController(firstCamera.first, ResolutionPreset.medium);
  //   await _cameraController.initialize();

  //   _cameraController.startImageStream((CameraImage image) {
  //     if (_isDetecting) return;

  //     _isDetecting = true;

  //     _rectangleDetector
  //         .detectRectangles(image)
  //         .then((List<dynamic> recognitions) {
  //       // Processar as detecções dos retângulos aqui

  //       _isDetecting = false;
  //     }).catchError((e) {
  //       print('Erro ao detectar retângulos: $e');
  //       _isDetecting = false;
  //     });
  //   });
  // }

  Future<void> _initDetector() async {
    _rectangleDetector = RectangleDetector();
    await _rectangleDetector.loadModel();
  }

  @override
  void dispose() {
    //   _cameraController.dispose();
    _rectangleDetector.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // if (!_cameraController.value.isInitialized) {
    //   return Container();
    // }

    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;

    return OverflowBox(
      alignment: Alignment.center,
      child: AspectRatio(
        aspectRatio: deviceRatio,
        child: controller != null
            ? SafeArea(
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        children: [
                          CameraPreview(controller!),
                        ],
                      ),
                    ),
                    if (itens.isNotEmpty)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (itens.isNotEmpty)
                            FutureBuilder<Widget>(
                                future: translat(
                                    itens[0]['detectedClass'].toString()),
                                builder: (BuildContext context,
                                    AsyncSnapshot<Widget> snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    // Enquanto o Future está carregando, exiba um indicador de progresso
                                    return Center(
                                        child: CircularProgressIndicator());
                                  } else if (snapshot.hasError) {
                                    // Se ocorrer um erro ao carregar o Future, exiba uma mensagem de erro
                                    return Center(
                                        child:
                                            Text('Erro ao carregar o widget.'));
                                  } else {
                                    // Se o Future for concluído com sucesso, exiba o Widget retornado
                                    return Center(child: snapshot.data);
                                  }
                                }),
                          Center(
                              child:
                                  Text(itens[0]['detectedClass'].toString())),
                        ],
                      ),

                    // ListView.builder(
                    //   itemCount: itens.length,
                    //   itemBuilder: (context, index) {
                    //     return ListTile(
                    //       title: Text(itens[index].toString()),
                    //     );
                    //   },
                    // )
                    Text(traducao)
                  ],
                ),
              )
            : ElevatedButton(
                onPressed: () {
                  setState(() {
                    cameraInit();
                  });
                },
                child: Text('data')),
      ),
    );
  }

  cameraInit() async {
    cameras = await availableCameras();
    if (cameras != null) {
      controller = CameraController(cameras![0], ResolutionPreset.max);
      //cameras[0] = first camera, change to 1 to another camera

      await controller!.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      });
      ;
      controller!.startImageStream((CameraImage image) {
        if (_isDetecting) return;

        _isDetecting = true;

        _rectangleDetector
            .detectRectangles(image)
            .then((List<dynamic> recognitions) {
          setState(() {
            itens = recognitions;
          });
          // Processar as detecções dos retângulos aqui

          _isDetecting = false;
        }).catchError((e) {
          print('Erro ao detectar retângulos: $e');
          _isDetecting = false;
        });
      });
    } else {
      print("NO any camera found");
    }
  }
}
