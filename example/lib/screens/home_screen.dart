import 'package:flutter/material.dart';
import 'package:tuya_home_sdk_flutter/tuya_home_sdk_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ThingSmartHomeModel? home;
  String? token;
  ThingSmartDeviceModel? device;
  ThingSmartDeviceModel? subDevice;
  ThingSmartSceneModel? scene;
  ThingSmartHomeMemberModel? member;

  bool isLoading = false;
  @override
  void initState() {
    super.initState();
  }

  void _getHome() {
    TuyaHomeSdkFlutter.instance.getHomeList().then((value) {
      setState(() {
        home = value.first;
      });
    });
  }

  void _getToken() {
    TuyaHomeSdkFlutter.instance.getToken(homeId: home!.homeId).then((value) {
      setState(() {
        token = value;
      });
    });
  }

  void _discover() {
    TuyaHomeSdkFlutter.instance.discoverDevices().listen(
      (device) {
        debugPrint("Discovered Device: ${device.name}");
      },
      onError: (error) {
        debugPrint("Error discovering devices: $error");
      },
    );
  }

  void _getDevices() {
    TuyaHomeSdkFlutter.instance.getHomeDevices(homeId: home!.homeId).then((
      value,
    ) {
      setState(() {
        device = value.first;
        debugPrint(device?.devId);
      });
    });
  }

  void _scan() {
    setState(() {
      isLoading = true;
    });
    TuyaHomeSdkFlutter.instance.startConfigWiredDevice(token: token!).then((
      value,
    ) {
      if (value != null) {
        setState(() {
          device = value;
          isLoading = false;
        });
      }
    });
  }

  void _addHomeMemeber() async {
    final res = await home?.addMember(name: "member");
    debugPrint(res.toString());
  }

  void _queryMemberList() async {
    final res = await home?.queryMemberList();
    member = res?.last;
    res?.forEach((element) {
      debugPrint(
        "${element.name}, ${element.memberId}, ${element.status}, ${element.role}, ${element.uid}, ${element.homeId}",
      );
    });
  }

  void _removeMember() async {
    final res = await member?.remove();
    debugPrint(res.toString());
  }

  void _getSubDevice() {
    setState(() {
      isLoading = true;
    });
    TuyaHomeSdkFlutter.instance
        .startConfigSubDevice(devId: device!.devId!)
        .then((value) {
          if (value != null) {
            setState(() {
              subDevice = value;
              isLoading = false;
            });
          }
        });
  }

  Future<void> _getScenes() async {
    final scens = await TuyaHomeSdkFlutter.instance.getSceneList(
      homeId: home!.homeId,
    );
    scene = scens.first;
    for (var e in scens) {
      debugPrint(e.name);
    }
  }

  Future<void> _fetchDetails() async {
    final scens = await TuyaHomeSdkFlutter.instance.fetchSceneDetail(
      homeId: home!.homeId,
      sceneId: scene!.id,
      supportHome: false,
      ruleGenre: scene!.ruleGenre,
    );
    scene = scens;

    debugPrint(scens?.name);
  }

  Future<void> _addNewScene() async {
    final created = await TuyaHomeSdkFlutter.instance.addScene(
      sceneFactory: ThingSmartSceneFactory(
        homeId: home!.homeId,
        name: "Test flutter",
        matchType: ThingSmartConditionMatchType.ThingSmartConditionMatchAny,
        showFirstPage: false,
        actions: [ThingSmartSceneActionFactory.createSendNotificationAction()],
        preConditionions: [
          ThingSmartScenePreConditionFactory.allDay(
            loops: "1111111",
            timeZoneId: "Asia/Shanghai",
          ),
        ],
        conditions: [
          ThingSmartSceneConditionFactory.device(
            deviceId: 'eb13b17e6a127b0552oa3e',
            dpModelId: 10,
            expr: ThingSmartSceneExprFactory.createValueExpr(
              type: "8",
              compareOperator: '==',
              chooseValue: 99,
              exprType: ExprEntityType.kExprTypeDevice,
            ),
          ),
        ],
      ),
    );

    debugPrint(created.toString());
  }

  Future<void> _removeScene() async {
    final res = await scene?.removeScene(homeId: home!.homeId);

    debugPrint(res.toString());
  }

  void _modifyMember() async {
    final res = await member?.modify(name: "modifie name");
    debugPrint(res.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 4,
          children: [
            Text("${home?.name ?? ''} - ${home?.homeId ?? ''}"),
            Text(token ?? ''),
            ElevatedButton(onPressed: _discover, child: const Text('Discover')),
            ElevatedButton(onPressed: _getHome, child: const Text('getHome')),
            ElevatedButton(onPressed: _getToken, child: const Text('getToken')),
            ElevatedButton(onPressed: _scan, child: const Text('scan')),
            if (isLoading) const Center(child: CircularProgressIndicator()),
            if (device != null) ...[
              const Text('Device Info'),
              const SizedBox(height: 20),
              Text(device!.name),
              Text(device!.devId ?? ''),
              Text(device!.productId),
              Text(device!.productVer ?? ''),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _getSubDevice,
                child: const Text('Sub Device'),
              ),
              if (subDevice != null) ...[
                const Text('Device Info'),
                const SizedBox(height: 20),
                Text(subDevice!.name),
                Text(subDevice!.devId ?? ''),
                Text(subDevice!.productId),
                Text(subDevice!.productVer ?? ''),
              ],
            ],
            ElevatedButton(
              onPressed: _getScenes,
              child: const Text('Get Scenes'),
            ),
            ElevatedButton(
              onPressed: _getDevices,
              child: const Text('Get Devices'),
            ),
            ElevatedButton(
              onPressed: _fetchDetails,
              child: const Text('Fetch Scene details'),
            ),
            ElevatedButton(
              onPressed: _addNewScene,
              child: const Text('Add new Scene'),
            ),
            ElevatedButton(
              onPressed: _removeScene,
              child: const Text('Remove Scene'),
            ),
            ElevatedButton(
              onPressed: _addHomeMemeber,
              child: const Text('Add memeber '),
            ),
            ElevatedButton(
              onPressed: _queryMemberList,
              child: const Text('Get memebers '),
            ),
            ElevatedButton(
              onPressed: _removeMember,
              child: const Text('Remove memeber '),
            ),
            ElevatedButton(
              onPressed: _modifyMember,
              child: const Text('Modify memeber '),
            ),
          ],
        ),
      ),
    );
  }
}
