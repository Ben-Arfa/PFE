#include <DHT.h>
#include <WiFi.h>
#include <WebServer.h>

#define DHT_PIN 4
#define DHT_TYPE DHT22

const char* WIFI_SSID = "VOTRE_WIFI";
const char* WIFI_PASSWORD = "VOTRE_MOT_DE_PASSE";

DHT dht(DHT_PIN, DHT_TYPE);
WebServer server(80);

void sendCorsHeaders() {
  server.sendHeader("Access-Control-Allow-Origin", "*");
  server.sendHeader("Access-Control-Allow-Methods", "GET, OPTIONS");
  server.sendHeader("Access-Control-Allow-Headers", "Content-Type");
}

void handleRoot() {
  sendCorsHeaders();
  server.send(200, "text/plain", "KIWO ESP32 DHT22 OK. Use /readings");
}

void handleReadings() {
  float humidity = dht.readHumidity();
  float temperature = dht.readTemperature();
  float heatIndex = dht.computeHeatIndex(temperature, humidity, false);

  sendCorsHeaders();

  if (isnan(humidity) || isnan(temperature)) {
    server.send(503, "application/json", "{\"error\":\"DHT22 read failed\"}");
    return;
  }

  String json = "{";
  json += "\"temperature\":" + String(temperature, 1) + ",";
  json += "\"humidity\":" + String(humidity, 1) + ",";
  json += "\"heatIndex\":" + String(heatIndex, 1) + ",";
  json += "\"rssi\":" + String(WiFi.RSSI()) + ",";
  json += "\"uptimeMs\":" + String(millis());
  json += "}";

  server.send(200, "application/json", json);
}

void handleOptions() {
  sendCorsHeaders();
  server.send(204);
}

void setup() {
  Serial.begin(115200);
  dht.begin();

  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

  Serial.print("Connexion WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println();
  Serial.print("Adresse IP ESP32: ");
  Serial.println(WiFi.localIP());

  server.on("/", HTTP_GET, handleRoot);
  server.on("/readings", HTTP_GET, handleReadings);
  server.on("/readings", HTTP_OPTIONS, handleOptions);
  server.begin();
}

void loop() {
  server.handleClient();
}
