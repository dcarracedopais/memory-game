import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:merimemory/services/assets.dart';

class FixtureBundle extends CachingAssetBundle {
  final good = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAIAAAACCAIAAAD91JpzAAAAFklEQVR4nGOsTNzDwMDAxMDAwMDAAAAS7wGa7A35YQAAAABJRU5ErkJggg==',
  );
  @override
  Future<ByteData> load(String key) async {
    if (key == 'AssetManifest.bin') {
      return const StandardMessageCodec().encodeMessage({
        'assets/cards/valid.png': [
          {'asset': 'assets/cards/valid.png'},
        ],
        'assets/cards/broken.jpg': [
          {'asset': 'assets/cards/broken.jpg'},
        ],
        'assets/cards/README.md': [
          {'asset': 'assets/cards/README.md'},
        ],
      })!;
    }
    return ByteData.sublistView(
      key.endsWith('valid.png') ? good : Uint8List.fromList([0, 1, 2]),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Only decodable images count towards image mode availability', () async {
    expect(await loadFaces(bundle: FixtureBundle()), [
      'assets/cards/valid.png',
    ]);
  });
}
