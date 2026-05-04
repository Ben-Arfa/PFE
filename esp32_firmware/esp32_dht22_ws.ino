#include <WiFi.h>
#include <AsyncTCP.h>
#include <ESPAsyncWebServer.h>
#include <DHT.h>

#define DHTPIN 4
#define DHTTYPE DHT22

DHT dht(DHTPIN, DHTTYPE);
AsyncWebServer server(80);
AsyncWebSocket ws("/ws");

// <-- Set your Wi-Fi credentials here -->
const char* WIFI_SSID = "YOUR_SSID";
const char* WIFI_PASS = "YOUR_PASS";

const int LED_PIN = 2; // Built-in LED on many ESP32 boards

unsigned long lastSend = 0;
const unsigned long SEND_INTERVAL = 5000; // ms

void handleWebSocketMessage(void *arg, uint8_t *data, size_t len) {
  // simple string payload
  String msg = "";
  for (size_t i = 0; i < len; i++) msg += (char) data[i];

  // look for a command field in incoming JSON like {"cmd":"SET_LED_ON"}
  if (msg.indexOf("SET_LED_ON") >= 0) {
    digitalWrite(LED_PIN, HIGH);
    ws.textAll("{\"ack\":\"SET_LED_ON\"}");
  } else if (msg.indexOf("SET_LED_OFF") >= 0) {
    digitalWrite(LED_PIN, LOW);
    ws.textAll("{\"ack\":\"SET_LED_OFF\"}");
  } else {
    // echo unknown commands
    ws.textAll(String("{\"echo\":") + msg + String("}"));
  }
}

void onEvent(AsyncWebSocket * server, AsyncWebSocketClient * client, AwsEventType type,
             void * arg, uint8_t * data, size_t len) {
  if (type == WS_EVT_CONNECT) {
    Serial.printf("WebSocket client connected: %u\n", client->id());
    // send a small device info
    ws.text(client->id(), "{\"device\":\"ESP32\",\"status\":\"connected\"}");
  } else if (type == WS_EVT_DISCONNECT) {
    Serial.printf("WebSocket client disconnected: %u\n", client->id());
  } else if (type == WS_EVT_DATA) {
    handleWebSocketMessage(arg, data, len);
  }
}

void setup() {
  Serial.begin(115200);
  pinMode(LED_PIN, OUTPUT);
  dht.begin();

  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASS);
  Serial.print("Connecting to WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println();
  Serial.print("Connected. IP: ");
  Serial.println(WiFi.localIP());

  ws.onEvent(onEvent);
  server.addHandler(&ws);
  server.begin();

  Serial.println("WebSocket server started at /ws");
}

void sendSensorReadings() {
  float t = dht.readTemperature();
  float h = dht.readHumidity();

  if (isnan(t) || isnan(h)) {
    Serial.println("Failed to read from DHT sensor");
    return;
  }

  String jsonT = String("{\"sensor\":\"temperature\",\"value\":") + String(t, 1) + ",\"unit\":\"C\",\"id\":\"temperature_sensor\"}";
  String jsonH = String("{\"sensor\":\"humidity\",\"value\":") + String(h, 1) + ",\"unit\":\"%\",\"id\":\"humidity_sensor\"}";

  ws.textAll(jsonT);
  ws.textAll(jsonH);

  Serial.println(jsonT);
  Serial.println(jsonH);
}

void loop() {
  unsigned long now = millis();
  if (now - lastSend >= SEND_INTERVAL) {
    lastSend = now;
    sendSensorReadings();
  }
  // let AsyncWebServer/AsyncWebSocket handle background tasks
  delay(10);
}
