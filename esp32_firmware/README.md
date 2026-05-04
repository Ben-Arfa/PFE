# ESP32 DHT22 WebSocket Example

This folder contains a minimal ESP32 firmware example that reads a DHT22 sensor
and exposes sensor data over a WebSocket endpoint at `/ws`.

Requirements
- ESP32 board support (Arduino core or PlatformIO)
- Libraries: `AsyncTCP`, `ESPAsyncWebServer`, `DHT sensor library` (Arduino)

Usage
1. Edit `esp32_dht22_ws.ino` and set your `WIFI_SSID` and `WIFI_PASS`.
2. Install required libraries in the Arduino IDE or PlatformIO.
3. Upload to the ESP32.
4. The sketch hosts a WebSocket server on port `80` at path `/ws`.
   - Example client URL: `ws://<ESP32_IP>/ws`
5. Sensor messages are JSON objects, e.g.:
   ```json
   {"sensor":"temperature","value":23.4,"unit":"C","id":"temperature_sensor"}
   {"sensor":"humidity","value":58.2,"unit":"%","id":"humidity_sensor"}
   ```
6. Incoming commands from the client should be JSON: `{"cmd":"SET_LED_ON"}`.

Notes
- The sketch broadcasts sensor readings to all connected WebSocket clients every 5s.
- Adjust pins and timings to your setup.
