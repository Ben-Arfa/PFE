import 'package:flutter_test/flutter_test.dart';
import 'package:kiwo/features/gestion_des_iot_devices/data/services/esp32_dht22_service.dart';

void main() {
  group('Esp32DataResponse.fromJson', () {
    test('normalise les modes textes renvoyes par l ESP32', () {
      expect(_response({'mode': 'automatique'}).mode, 'auto');
      expect(_response({'mode': 'automatic'}).mode, 'auto');
      expect(_response({'mode': 'manuel'}).mode, 'manuel');
      expect(_response({'mode': 'manual'}).mode, 'manuel');
    });

    test('deduit le mode depuis les champs booleens', () {
      expect(_response({'isAuto': true}).mode, 'auto');
      expect(_response({'isAuto': false}).mode, 'manuel');
      expect(_response({'auto': 'false'}).mode, 'manuel');
      expect(_response({'manual': true}).mode, 'manuel');
    });

    test('accepte plusieurs formats pour les leds', () {
      expect(
        _response({
          'leds': [1, 0, 'on', 'false'],
        }).leds,
        [true, false, true, false],
      );
    });
  });
}

Esp32DataResponse _response(Map<String, dynamic> values) {
  return Esp32DataResponse.fromJson({
    'temperature': 25,
    'humidity': 60,
    'readingOk': true,
    ...values,
  });
}
