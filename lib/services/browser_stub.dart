final _values = <String, String>{};
String? readValue(String key) => _values[key];
bool writeValue(String key, String value) {
  _values[key] = value;
  return true;
}

void playSound(String kind) {}
