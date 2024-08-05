import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';
import 'dart:convert';
import 'utils/token_manager.dart';
import 'package:http/http.dart' as http;
import 'utils/user_details.dart';
import 'package:wireguard_flutter/wireguard_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // final _wireguardFlutterPlugin = WireguardVpn();
  final wireguard = WireGuardFlutter.instance;
  late String name;

  bool isVpnConnected = false;
  bool vpnState = false;
  String lastCall = 'none';
  // Stats stats = Stats(totalDownload: 0, totalUpload: 0);
  String initName = 'sakec-wire4';
  String initAddress = "192.168.69.4/24";
  String initPort = "51820";
  String initDnsServer = "101.53.147.30";
  String initPrivateKey = "CDi9IdHiYJmw9mCzgBb3EIoUR8JNINnbdsMz0gYz1lE=";
  String initAllowedIp = "0.0.0.0/0, ::/0";
  String initPublicKey = "FytzEla1nQkpfGAouJaM1eFKR1e5N9vbt24of2+iIHg=";
  String initEndpoint = "115.113.39.74:51820";
  String presharedKey = "iP4F07mNzTur0nJc71T/rDxaJpIOk+Ntg8xyJafW1AY=";

  static Future<Map<String, dynamic>> getWireGuardConfig() async {
    const apiUrl = 'http://115.113.39.74:65528/api/user/wireguardapi';

    var os = "linux";

    // IP address
    final response = await http.get(Uri.parse('https://api.ipify.org'));
    var ip = "";
    if (response.statusCode == 200) {
      ip = response.body;
    } else {
      throw Exception('Failed to get IP address');
    }

    try {
      // final response = await http.post(Uri.parse(apiUrl));
      final token = await TokenManager.getToken();
      final userDetails = await LocalStorage.getUserDetails();
      final uid = userDetails['uid'];
      final response = await http.post(
        Uri.parse(apiUrl),
        body: jsonEncode({
          "uid1": uid,
          "userip1": ip,
          "token1": token,
          "device1": os,
        }), // Include the IP address in the request body
        headers: {
          'Content-Type': 'application/json'
        }, // Specify the content type as JSON
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print('Success Api ');
        //print(responseData);

        if (responseData['success'] == true) {
          return responseData['config1'];
        } else {
          throw Exception('API response indicates failure');
        }
      } else {
        throw Exception(
            'Failed to fetch data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error: $error');
    }
  }

  late String uid = '';
  late String displayName = '';

  @override
  void initState() {
    super.initState();
    // vpnActivate ? _obtainStats() : null;
    getWireGuardConfig().then((config) {
      updateConfigValues(config);
      print('Inside update');
    });
    // Initialize the user with sample data or load it from storage
    _getUserDetails();

    wireguard.vpnStageSnapshot.listen((event) {
      debugPrint("status changed $event");
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('status changed: $event'),
        ));
      }
    });
    name = 'my_vpn';
  }

  Future<void> _getUserDetails() async {
    try {
      // Call the getUserDetails function from the LocalStorage class
      Map<String, String?> userDetails = await LocalStorage.getUserDetails();
      setState(() {
        // Update the state variables with the retrieved values
        uid = userDetails['uid'] ?? '';
        displayName = userDetails['displayName'] ?? '';
      });
    } catch (error) {
      print('Error retrieving user details: $error');
    }
  }

  void updateConfigValues(Map<String, dynamic> config) {
    setState(() {
      print('Inside set state');
      initName = config['wgInterface']['name'];
      initAddress = config['wgInterface']['address'][0];
      initPort = config['peers'][0]['endpoint'].split(':')[1];
      initDnsServer = config['wgInterface']['dns'][0];
      initPrivateKey = config['wgInterface']['privateKey'];
      initAllowedIp = config['peers'][0]['allowedIps'][0];
      initPublicKey = config['peers'][0]['publicKey'];
      initEndpoint = config['peers'][0]['endpoint'];
      presharedKey = config['preSharedKey'];
      print('175 - config values updated');
    });
  }

  void runSudoCommand() async {
    final result = await Process.run(
      'sudo',
      ['-A', 'wg'],
      environment: {'SUDO_ASKPASS': '/usr/bin/ssh-askpass'},
    );
    // final result = await Process.run(
    //   'bash',
    //   ['-c', 'export SUDO_ASKPASS=/usr/bin/ssh-askpass && sudo -A wg'],
    // );

    if (result.exitCode == 0) {
      print('Command executed successfully:\n${result.stdout}');
    } else {
      print('Command failed with error:\n${result.stderr}');
    }
  }

  Future<void> initialize() async {
    try {
      runSudoCommand();
      await wireguard.initialize(interfaceName: name);
      debugPrint("initialize success $name");
    } catch (error, stack) {
      debugPrint("failed to initialize: $error\n$stack");
    }
  }

  void startVpn() async {
    print('162 - calling startVpn');
    // wireguard.vpnStageSnapshot.listen((event) {
    //   debugPrint("status changed $event");
    //   if (mounted) {
    //     ScaffoldMessenger.of(context).clearSnackBars();
    //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //       content: Text('status changed: $event'),
    //     ));
    //   }
    // });
    // name = 'my_vpn';

    // try {
    //   await wireguard.initialize(interfaceName: name);
    //   debugPrint("initialize success $name");
    // } catch (error, stack) {
    //   debugPrint("failed to initialize: $error\n$stack");
    // }

    await initialize();

    String conf = '''
[Interface]
PrivateKey = $initPrivateKey
Address = $initAddress
DNS = 101.53.147.30

[Peer]
PublicKey = FytzEla1nQkpfGAouJaM1eFKR1e5N9vbt24of2+iIHg=
PresharedKey = $presharedKey
AllowedIPs = $initAllowedIp
PersistentKeepalive = 15
Endpoint = 115.113.39.74:51820
''';
    try {
      print('Conf - 155 => $conf');
      await wireguard.startVpn(
          serverAddress: '115.113.39.74:65528',
          wgQuickConfig: conf,
          providerBundleIdentifier: 'com.example.cygiene_ui');

      vpnState = await wireguard.isConnected();
      print('226 - start - vpnState - $vpnState');
      setState(() {
        isVpnConnected = vpnState;
        lastCall = 'start';
      });
      print('230 -start - isVpnConnected - $isVpnConnected');
    } catch (error, stack) {
      debugPrint("failed to start $error\n$stack");
    }
  }

  void disconnect() async {
    try {
      if (lastCall == 'start') {
        await wireguard.stopVpn();
        vpnState = await wireguard.isConnected();
        print('243 - stop - vpnState - $vpnState');

        setState(() {
          isVpnConnected = vpnState;
          print('247 - stop - isVpnConnected - $isVpnConnected');
        });
      } else {
        startVpn();
      }
    } catch (e, str) {
      debugPrint('Failed to disconnect $e\n$str');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          // Container(
          //   width: 200,
          //   color: const Color(0xFFe0e5ff),
          //   child: Column(
          //     mainAxisAlignment: MainAxisAlignment.start,
          //     children: [
          //       const SizedBox(height: 20),
          //       Padding(
          //         padding: const EdgeInsets.all(0.0),
          //         child: Column(
          //           children: [
          //             Image.asset(
          //               'logo.png',
          //               width: 200,
          //               height: 200,
          //               fit: BoxFit.cover,
          //             ),
          //           ],
          //         ),
          //       ),
          //       const SizedBox(height: 50),
          //       const MenuButton(label: 'Home'),
          //       const MenuButton(label: 'Blog'),
          //       const MenuButton(label: 'Profile'),
          //     ],
          //   ),
          // ),
          // Main content

          Expanded(
            child: Column(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: 600,
                          height: 250,
                          padding: const EdgeInsets.all(15),
                          child: Column(children: [
                            InkWell(
                              onTap: () {
                                isVpnConnected ? disconnect() : startVpn();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                width: 150,
                                height: 150,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFDED1F5),
                                  shape: BoxShape.circle,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF7971ff),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF0500fd),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.only(bottom: 5),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            isVpnConnected
                                                ? 'Disconnect'
                                                : 'Connect',
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                              height: 30,
                            ),
                            SizedBox(
                              width: 300,
                              height: 40,
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.black,
                                  backgroundColor: const Color(0xFFe0e5ff),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                ),
                                child: Text(
                                  isVpnConnected == true
                                      ? "Connected"
                                      : "Disconnected",
                                  style: const TextStyle(
                                    fontSize:
                                        16, // Adjust the font size as per your requirement
                                    fontStyle: FontStyle
                                        .normal, // Adjust the font style as per your requirement
                                  ),
                                ),
                              ),
                            ),
                          ]),
                        ),
                        const VerticalDivider(
                          width: 10,
                          // height: 100,
                          thickness: 5,
                          indent: 30,
                          endIndent: 30,
                          color: Color.fromARGB(255, 3, 3, 3),
                        ),
                        const SizedBox(width: 50),
                        Container(
                          width: 600,
                          height: 250,
                          // color: Colors.blue,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Hello',
                                    style: TextStyle(
                                        fontSize: 40,
                                        fontWeight: FontWeight.w900),
                                  ),
                                  Text(
                                    ' $displayName',
                                    style: const TextStyle(
                                        color:
                                            Color.fromARGB(255, 33, 124, 243),
                                        fontSize: 40,
                                        fontWeight: FontWeight.w900),
                                  )
                                ],
                              ),
                              const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(' Welcome to Secure DNS',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700))
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Text('Active VPN : 0 Download - 0 Upload',
                    style: TextStyle(
                        color: Color(0xFF508AEC), fontWeight: FontWeight.bold)),
                Expanded(
                    child: SvgPicture.asset(
                  'assets/map.svg',
                  semanticsLabel: 'My SVG Image',
                  width: 800,
                  height: 700,
                  fit: BoxFit.cover,
                ))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
