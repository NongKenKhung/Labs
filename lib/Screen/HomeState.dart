import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class HomeState extends StatefulWidget {
  const HomeState({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeStateState createState() => _HomeStateState();
}

class _HomeStateState extends State<HomeState> {
  late MqttServerClient client;
  String _currentMessage = '0';
  String _currentNotification = '0';
  String hour = '0';
  String minute = '0';
  bool isConnected = false;
  bool isNotificationShown = false;
  late TimeOfDay start;
  late TimeOfDay end;
  late TimeOfDay now;
  int _selectedIndex = 0;
  // ignore: non_constant_identifier_names
  List<String> messages_notification = [];

  @override
  void initState() {
    start = const TimeOfDay(hour: 23, minute: 30);
    end = const TimeOfDay(hour: 05, minute: 00);
    super.initState();
    connectToMqtt();
  }

  Future<void> connectToMqtt() async {
    client = MqttServerClient('broker.hivemq.com', 'credentialSecret');
    client.port = 1883;
    client.keepAlivePeriod = 60;
    client.autoReconnect = true;
    client.setProtocolV311();
    client.resubscribeOnAutoReconnect = true;
    client.logging(on: true);

    final connMessage = MqttConnectMessage()
        .withClientIdentifier('flutter_client')
        .withWillTopic('willtopic')
        .withWillMessage('Connection closed')
        .startClean()
        .withWillQos(MqttQos.atMostOnce);

    client.connectionMessage = connMessage;

    try {
      await client.connect();
    } catch (e) {
      log('Error: $e');
      client.disconnect();
    }

    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      log('MQTT Connected');
      setState(() {
        isConnected = true;
        // Subscribe to all topics
        subscribeToTopic('Ken/M5/State');
        subscribeToTopic('Ken/M5/Notification/State');
        subscribeToTopic('Ken/M5/Start/hour');
        subscribeToTopic('Ken/M5/Start/minute');
        subscribeToTopic('Ken/M5/End/hour');
        subscribeToTopic('Ken/M5/End/minute');
        subscribeToTopic('Ken/M5/Now/hour');
        subscribeToTopic('Ken/M5/Now/minute');

        publishMessage('1', 'Ken/M5/Return');
      });
    } else {
      log('MQTT Connection failed');
      client.disconnect();
    }
  }

  void subscribeToTopic(String topic) {
    client.subscribe(topic, MqttQos.exactlyOnce);

    client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final recMess = c[0].payload as MqttPublishMessage;
      final message = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      var topicReceived = c[0].topic;

      setState(() {

        if (topicReceived == 'Ken/M5/Start/hour') {
          start = start.replacing(hour: int.parse(message));
        } else if (topicReceived == 'Ken/M5/Start/minute') {
          start = start.replacing(minute: int.parse(message));
        } else if (topicReceived == 'Ken/M5/End/hour') {
          end = end.replacing(hour: int.parse(message));
        } else if (topicReceived == 'Ken/M5/End/minute') {
          end = end.replacing(minute: int.parse(message));
        } else if (topicReceived == 'Ken/M5/Now/hour') {
          hour = message;
        } else if (topicReceived == 'Ken/M5/Now/minute') {
          minute = message;
        } else if (topicReceived == 'Ken/M5/State') {
          _currentMessage = message;
        } else if (topicReceived == 'Ken/M5/Notification/State') {
          _currentNotification = message;
        }

        if (topicReceived == 'Ken/M5/Notification/State') {
          if(_currentNotification == '1'&& !isNotificationShown){
            if (messages_notification.isEmpty || messages_notification.last != '$topicReceived: $message') {
              String nowTime = '${hour.padLeft(2, '0')}:${minute.padLeft(2, '0')}';
              messages_notification.add('Notification | Time: $nowTime');
              isNotificationShown = true; 
            }
          }else if (_currentNotification == '0') {
            isNotificationShown = false;
          }
        }
        
      });
    });
  }

  void publishMessage(String message, String topic) {
    if (isConnected) {
      final builder = MqttClientPayloadBuilder();
      builder.addString(message);
      client.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
    } else {
      log('Not connected to MQTT broker');
    }
  }

  Future<TimeOfDay?> _selectTime(BuildContext context, TimeOfDay initialTime) async {
    return await showTimePicker(
      context: context,
      initialTime: initialTime,
      initialEntryMode: TimePickerEntryMode.input,
    );
  }

  // ฟังก์ชันจัดการการเปลี่ยนหน้า
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // เนื้อหาของหน้า
  Widget _buildBody() {
    if (_selectedIndex == 0) {
      return _buildHomeContent();
    } else {
      return _buildSettingsContent();
    }
  }

  // เนื้อหาของหน้าหลัก
  Widget _buildHomeContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          GestureDetector(
            onTap: () {
              String nextMessage = _currentMessage == '0' ? '1' : '0';
              publishMessage(nextMessage, 'Ken/M5/State');
            },
            child: Container(
              width: 225.0,
              height: 225.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentMessage == '1' ? Colors.green : Colors.red,
              ),
              child: Center(
                child: Text(
                  _currentMessage == '1' ? 'ON' : 'OFF',
                  style: const TextStyle(color: Colors.white, fontSize: 50),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10)
                ),
              height: 300,
              child: Scrollbar(
                child: ListView.builder(
                  itemCount: messages_notification.length,
                  itemBuilder: (context, index){
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4,horizontal: 16),
                      child: Text(
                        messages_notification[index],
                        style: GoogleFonts.prompt(
                          fontSize: 16,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              onPressed: (){
                String nextMessage = _currentNotification == '0' ? '0' : '0';
                publishMessage(nextMessage, 'Ken/M5/Notification/State');
              }, 
              child: Center(
                child: Column(
                  children: [
                    Icon(_currentNotification == '1' ? Icons.notifications_on : Icons.notifications_off,)
                  ],
                ),
              )
            ),
          ),
        ],
      ),
    );
  }

  // เนื้อหาของหน้าการตั้งค่า
  Widget _buildSettingsContent() {
    return Scaffold(
      body: Center(
        child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(
            height: 10,
          ),
          GestureDetector(
            onTap: () async{
              TimeOfDay? selectedTime = await _selectTime(context, start);
              if (selectedTime != null){
                setState(() => start = selectedTime);
                publishMessage(start.hour.toString(),'Ken/M5/Start/hour');
                publishMessage(start.minute.toString(),'Ken/M5/Start/minute');
              }
            },
            child: Container(
              height: 120,
              decoration: const BoxDecoration(
                //color: Color.fromRGBO(255, 234, 199, 1)
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("Start",
                      style: GoogleFonts.prompt(
                        fontSize: 30,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const Spacer(),
                    Text("${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')} ",
                      style: GoogleFonts.prompt(
                        fontSize: 30,
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios)
                  ],
                ),
              ),
            ),
          ),
          const Divider(
            color: Colors.black,
            height: 20,
            thickness: 1,
            indent: 20,
            endIndent: 20,
          ),
          GestureDetector(
            onTap: () async{
              TimeOfDay? selectedTime = await _selectTime(context,end);
              if(selectedTime != null){
                setState(() {
                  end = selectedTime;
                });
                publishMessage(end.hour.toString(), 'Ken/M5/End/hour');
                publishMessage(end.minute.toString(), 'Ken/M5/End/minute');
              }
            },
            child: Container(
              height: 120,
              decoration: const BoxDecoration(
                //color: Colors.blue,
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("Stop",
                      style: GoogleFonts.prompt(
                        fontSize: 30,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const Spacer(),
                    Text("${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')} ",
                      style: GoogleFonts.prompt(
                        fontSize: 30,
                        fontWeight: FontWeight.normal
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios),
                  ],
                ),
              ),
            ),
          ),
          const Divider(
            color: Colors.black,
            height: 20,
            thickness: 1,
            indent: 20,
            endIndent: 20,
          )
        ],
      ),
      )
    );
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60), 
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          child: AppBar(
            backgroundColor: Colors.green,
            title: Text("Home 1",
              style: GoogleFonts.prompt(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),),
          ),
        )),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        onTap: _onItemTapped,
      ),
    );
  }

  @override
  void dispose() {
    client.disconnect();
    super.dispose();
  }
}
