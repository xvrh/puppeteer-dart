import 'dart:convert';
import 'dart:io';
import 'package:image/image.dart' as image;
import 'package:puppeteer/puppeteer.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_static/shelf_static.dart';

main() async {
  // Start a local web server and open the page
  var server =
      await io.serve(createStaticHandler('example/html'), 'localhost', 0);
  var browser = await puppeteer.launch();
  var page = await browser.newPage();
  await page.goto('http://localhost:${server.port}/rubiks_cube/index.html');

  // On each frame, decode the image and use the "image" package to create an
  // animated gif.
  var animation = image.Animation();
  page.devTools.page.onScreencastFrame.listen((event) {
    animation.addFrame(image.decodePng(base64.decode(event.data)));
  });

  // Change the CSS animations speed to accelerate it.
  await page.devTools.animation.setPlaybackRate(240);

  // Start the screencast
  await page.devTools.page.startScreencast(maxWidth: 150, maxHeight: 150);

  // Wait a few seconds and stop the screencast.
  await Future.delayed(Duration(seconds: 3));
  await page.devTools.page.stopScreencast();

  // Encode the frame in Gif and save it to a file.
  File('example/_rubkis_cube.gif')
      .writeAsBytesSync(image.GifEncoder().encodeAnimation(animation));

  // Alternatively, save all the frames on disk and use ffmpeg to convert it to
  // video file. (like: ffmpeg -i frames/%3d.png -r 10 output.mp4)

  await browser.close();
  await server.close(force: true);
}
