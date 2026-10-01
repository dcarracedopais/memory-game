import 'dart:js_interop';

@JS('meriRead')
external JSString? _read(JSString key);
@JS('meriWrite')
external JSBoolean _write(JSString key, JSString value);
@JS('meriSound')
external void _sound(JSString kind);
String? readValue(String key) => _read(key.toJS)?.toDart;
bool writeValue(String key, String value) =>
    _write(key.toJS, value.toJS).toDart;
void playSound(String kind) => _sound(kind.toJS);
