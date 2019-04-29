import 'dart:isolate';
import 'package:image/image.dart';

main() async {
  print(await resolveUri(Uri.parse('package:image/src/browser.dart')));

  //var image = decodePng(null);
  //drawImage(image, src);
}

Future<Uri> resolveUri(Uri uri) {
  if (uri.scheme == "package") {
    return Isolate.resolvePackageUri(uri).then((resolvedUri) {
      if (resolvedUri == null) {
        throw ArgumentError.value(uri, "uri", "Unknown package");
      }
      return resolvedUri;
    });
  }
  return Future<Uri>.value(Uri.base.resolveUri(uri));
}

// API draw frame:
// - devices.iPhone6.frameFile (Future<File>)
// - devices.iPhone6.frameImage (Future<Image>)
// - devices.iPhone6.screenshot(screenshot) => Future<Image>, passer le screenshot et il retourne le screenshot dans la frame
// - page.screenshot(withDeviceFrame: devices.iPhone6) => bof
// - addDeviceFrame(screenshot, devices.iPhone6)
// - drawDeviceFrame(screenshot, devices.iPhone6)
// - mergeDeviceFrame(screenshot, devices.iPhone6)

// La frame est constitutée du fichier + offset du cadre où dessiner.
// On rajoute une class DeviceWithOutline = Device with Outline; et seule les Devices
// avec une frame l'utilise. Ca permet d'éviter un nullpointerexception
// L'accès à la frame est une Future car il faut le temps de résoudre les packagesUri! :-((((
// => faire l'accès la frame sync mais exposer l'uri package:, et faire une méthode async pour exposer le File

// => Il peut y avoir plusieurs Frames: normal, navigation, keyboard en portrait et paysage
// + exposer l'api pour choisir le DPI (idéalement lié à la taille du screenshot passé)?
