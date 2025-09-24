import Flutter
import ThingSmartDeviceKit
import ThingSmartHomeKit
import TuyaHomeSdkKit
import UIKit

@available(iOS 13.0, *)
public class TuyaHomeSdkFlutterPlugin: NSObject, FlutterPlugin {
    /// MARK: private helper properties
    private var eventSink: FlutterEventSink?
    private var device: ThingSmartDevice?
    private let deviceDiscoveryHandler = DeviceDiscoveryStreamHandler()
    var callback: FlutterResult?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "tuya_home_sdk_flutter",
            binaryMessenger: registrar.messenger()
        )
        let event = FlutterEventChannel(
            name: "tuya_home_sdk_flutter_device_dps_event",
            binaryMessenger: registrar.messenger()
        )
        let deviceEvent = FlutterEventChannel(
            name: "tuya_home_sdk_flutter_device_discovery_event",
            binaryMessenger: registrar.messenger()
        )

        let instance = TuyaHomeSdkFlutterPlugin()
        event.setStreamHandler(instance)
        deviceEvent.setStreamHandler(instance.deviceDiscoveryHandler)
        registrar.addMethodCallDelegate(instance, channel: channel)

    }

    public func handle(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        switch call.method {

        case "initSDK":
            initSdk(call, result: result)

        case "sendVerifyCodeWithUserName":
            sendVerifyCodeWithUserName(call, result: result)

        case "checkCodeWithUserName":
            checkCodeWithUserName(call, result: result)

        case "registerByUserName":
            registerByUserName(call, result: result)

        case "registerByPhone":
            registerByPhone(call, result: result)

        case "loginWithUserName":
            loginWithUserName(call, result: result)

        case "loginWithPhonePassword":
            loginWithPhonePassword(call, result: result)
        case "loginWithPhoneCode":
            loginWithPhoneCode(call, result: result)

        case "loginByAuth2":
            loginByAuth2(call, result: result)

        case "resetPasswordByEmail":
            resetPasswordByEmail(call, result: result)

        case "addHomeWithName":
            addHomeWithName(call, result: result)

        case "updateHome":
            updateHome(call, result: result)

        case "removeHome":
            removeHome(call, result: result)

        case "getHomeList":
            getHomeList(result: result)

        case "getHomeRooms":
            getHomeRooms(call, result: result)
        case "addRoom": addRoom(call, result: result)
        case "removeRoom": removeRoom(call, result: result)
        case "updateRoom": updateRoom(call, result: result)

        case "getHomeDevices":
            getHomeDevices(call, result: result)

        case "discoverDevices":
            discoverDevices(result: result)
        case "getWifiSsid": getWifiSsid(result: result)

        case "startConfigBLEWifiDevice":
            startConfigBLEWifiDevice(call, result: result)

        case "getToken": requestHomeToken(call, result: result)

        case "startConfigWiFiDevice":
            startConfigWiFiDevice(call, result: result)

        case "startConfigWiredDevice":
            startConfigWiredDevice(call, result: result)

        case "startConfigSubDevice": startConfigSubDevice(call, result: result)

        case "publishDps": publishDps(call, result: result)

        case "removeDevice": removeDevice(call, result: result)
        case "renameDevice": updateDeviceName(call, result: result)
        case "getUserInfo": getUserInfo(result: result)

        case "assignDeviceToRoom": assignDeviceToRoom(call, result: result)

        case "listenForDevice": listenForDevice(call, result: result)

        case "updateUserNickName": updateUserNickName(call, result: result)

        case "updateUserIcon": updateUserIcon(call, result: result)

        case "logout": logout(result: result)
        case "getSceneList": getSceneList(call, result: result)

        case "fetchSceneDetail": fetchSceneDetail(call, result: result)
        case "addScene": addScene(call, result: result)
        case "removeScene": removeScene(call, result: result)
        case "runScene": runScene(call, result: result)
        case "changeAutomation": changeAutomation(call, result: result)
        case "editScene": editScene(call, result: result)
        case "addMember": addMember(call, result: result)
        case "queryMemberList": queryMemberList(call, result: result)
        case "removeMember": removeMember(call, result: result)
        case "modifyMember": modifyMember(call, result: result)
        case "joinHome": joinHome(call, result: result)
        case "cancelInvitation": cancelInvitation(call, result: result)
        case "acceptOrRejectInvitation":
            acceptOrRejectInvitation(call, result: result)
        case "queryInvitations": queryInvitation(call, result: result)
        case "modifyInvitation": modifyInvitation(call, result: result)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func initSdk(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        let args = call.arguments as? [String: Any] ?? [String: Any]()
        let appKey = args["appKey"] as! String
        let secretKey = args["appSecret"] as! String
        let debug = args["isDebug"] as! Bool
        let key = args["key"] as! String
        TuyaHomeSdk.startTuyaSdk(
            appKey: appKey,
            secretKey: secretKey,
            isDebug: debug,
            key: key
        )

        result(true)

    }

    private func sendVerifyCodeWithUserName(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        let args = call.arguments as? [String: Any] ?? [String: Any]()
        let username = args["username"] as! String
        let countryCode = args["country_code"] as! String
        let type = args["type"] as! Int
        let region = ThingSmartUser.sharedInstance().getDefaultRegion(
            withCountryCode: countryCode
        )

        ThingSmartUser.sharedInstance().sendVerifyCode(
            withUserName: username,
            region: region,
            countryCode: countryCode,
            type: type
        ) {
            print("sendVerifyCode success")
            result(true)
        } failure: { error in
            if let error = error as? NSError {
                print("sendVerifyCode failure: \(error)")
                result(
                    FlutterError(
                        code: error.code.description,
                        message: error.description,
                        details: error.debugDescription
                    )
                )
            }
        }

    }

    private func checkCodeWithUserName(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        let args = call.arguments as? [String: Any] ?? [String: Any]()
        let username = args["username"] as! String
        let countryCode = args["country_code"] as! String
        let type = args["type"] as! Int
        let code = args["code"] as! String
        let region = ThingSmartUser.sharedInstance().getDefaultRegion(
            withCountryCode: countryCode
        )
        ThingSmartUser.sharedInstance().checkCode(
            withUserName: username,
            region: region,
            countryCode: countryCode,
            code: code,
            type: type,
            success: {
                isSuccess in
                if isSuccess {
                    result(true)
                } else {
                    result(false)
                }
            },
            failure: {
                error in
                if let error = error as? NSError {
                    print("sendVerifyCode failure: \(error)")
                    result(
                        FlutterError(
                            code: error.code.description,
                            message: error.description,
                            details: error.debugDescription
                        )
                    )
                }
            }
        )

    }

    private func registerByUserName(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        let args = call.arguments as? [String: Any] ?? [String: Any]()
        let username = args["username"] as! String
        let countryCode = args["country_code"] as! String
        let password = args["password"] as! String
        let code = args["code"] as! String
        let region = ThingSmartUser.sharedInstance().getDefaultRegion(
            withCountryCode: countryCode
        )
        ThingSmartUser.sharedInstance().register(
            withUserName: username,
            region: region,
            countryCode: countryCode,
            code: code,
            password: password,
            success: {
                result(true)
            },
            failure: {
                error in
                if let error = error as? NSError {
                    print("sendVerifyCode failure: \(error)")
                    result(
                        FlutterError(
                            code: error.code.description,
                            message: error.description,
                            details: error.debugDescription
                        )
                    )
                }
            }
        )

    }

    private func registerByPhone(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        let args = call.arguments as? [String: Any] ?? [String: Any]()
        let username = args["username"] as! String
        let countryCode = args["country_code"] as! String
        let password = args["password"] as! String
        let code = args["code"] as! String
        let region = ThingSmartUser.sharedInstance().getDefaultRegion(
            withCountryCode: countryCode
        )

        ThingSmartUser.sharedInstance().register(
            byPhone: countryCode,
            phoneNumber: username,
            password: password,
            code: code
        ) {
            result(true)
        } failure: {
            error in
            if let error = error as? NSError {
                print("sendVerifyCode failure: \(error)")
                result(
                    FlutterError(
                        code: error.code.description,
                        message: error.description,
                        details: error.debugDescription
                    )
                )
            }
        }

    }

    private func loginWithUserName(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        let args = call.arguments as? [String: Any] ?? [String: Any]()
        let username = args["username"] as! String
        let countryCode = args["country_code"] as! String
        let password = args["password"] as! String

        ThingSmartUser.sharedInstance().login(
            byEmail: countryCode,
            email: username,
            password: password,
            success: {
                result(true)
            },
            failure: {
                error in
                if let error = error as? NSError {
                    print("sendVerifyCode failure: \(error)")
                    result(
                        FlutterError(
                            code: error.code.description,
                            message: error.description,
                            details: error.debugDescription
                        )
                    )
                }
            }
        )

    }

    private func loginWithPhonePassword(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        let args = call.arguments as? [String: Any] ?? [String: Any]()
        let username = args["username"] as! String
        let countryCode = args["country_code"] as! String
        let password = args["password"] as! String

        ThingSmartUser.sharedInstance().login(
            byPhone: countryCode,
            phoneNumber: username,
            password: password,
            success: {
                result(true)
            },
            failure: {
                error in
                if let error = error as? NSError {
                    print("sendVerifyCode failure: \(error)")
                    result(
                        FlutterError(
                            code: error.code.description,
                            message: error.description,
                            details: error.debugDescription
                        )
                    )
                }
            }
        )

    }

    private func loginWithPhoneCode(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        let args = call.arguments as? [String: Any] ?? [String: Any]()
        let username = args["username"] as! String
        let countryCode = args["country_code"] as! String
        let code = args["code"] as! String
        ThingSmartUser.sharedInstance().login(
            withMobile: username,
            countryCode: countryCode,
            code: code
        ) {
            result(true)
        } failure: {
            error in
            if let error = error as? NSError {
                print("sendVerifyCode failure: \(error)")
                result(
                    FlutterError(
                        code: error.code.description,
                        message: error.description,
                        details: error.debugDescription
                    )
                )
            }
        }
    }

    private func loginByAuth2(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        let args = call.arguments as? [String: Any] ?? [String: Any]()
        let type = args["type"] as! String
        let countryCode = args["country_code"] as! String
        let accessToken = args["access_token"] as! String

        ThingSmartUser.sharedInstance().loginByAuth2(
            withType: type,
            countryCode: countryCode,
            accessToken: accessToken,
            extraInfo: [:]
        ) {
            result(true)
        } failure: { error in
            if let error = error as? NSError {
                print("loginByAuth2WithType failure: \(error)")
                result(
                    FlutterError(
                        code: error.code.description,
                        message: error.description,
                        details: error.debugDescription
                    )
                )
            }
        }

    }

    private func resetPasswordByEmail(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        let args = call.arguments as? [String: Any] ?? [String: Any]()
        let username = args["username"] as! String
        let countryCode = args["country_code"] as! String
        let password = args["password"] as! String
        let code = args["code"] as! String

        ThingSmartUser.sharedInstance().resetPassword(
            byEmail: countryCode,
            email: username,
            newPassword: password,
            code: code
        ) {
            result(true)
        } failure: {
            error in
            if let error = error as? NSError {
                print("sendVerifyCode failure: \(error)")
                result(
                    FlutterError(
                        code: error.code.description,
                        message: error.description,
                        details: error.debugDescription
                    )
                )
            }
        }

    }

    private func getUserInfo(result: @escaping FlutterResult) {
        let instance = ThingSmartUser.sharedInstance()

        if instance.isLogin {
            var info = [String: Any]()
            info["username"] = instance.userName
            info["country_code"] = instance.countryCode
            info["email"] = instance.email
            info["ecode"] = instance.ecode
            info["phone_number"] = instance.phoneNumber
            info["partner_identity"] = instance.partnerIdentity
            info["nickname"] = instance.nickname
            info["head_icon_url"] = instance.headIconUrl

            info["sid"] = instance.sid
            info["is_login"] = instance.isLogin
            result(info)
        } else {
            result(nil)
        }

    }

    private func logout(result: @escaping FlutterResult) {
        ThingSmartUser.sharedInstance().loginOut {
            result(true)
        } failure: { err in
            result(false)
        }

    }

    private func updateUserNickName(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        let args = call.arguments as? [String: Any] ?? [String: Any]()
        let nickname = args["nickname"] as! String
        ThingSmartUser.sharedInstance().updateNickname(
            nickname,
            success: {
                result(true)
            },
            failure: {
                error in
                result(false)
            }
        )
    }

    private func updateUserIcon(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        let args = call.arguments as? [String: Any] ?? [String: Any]()
        let iconData = args["iconData"] as! String
        let dataDecoded: Data = Data(
            base64Encoded: iconData,
            options: .ignoreUnknownCharacters
        )!
        let image = UIImage(data: dataDecoded)

        ThingSmartUser.sharedInstance().updateHeadIcon(
            image!,
            success: {
                result(true)
            },
            failure: {
                error in
                result(false)
            }
        )
    }

    /// add home
    private func addHomeWithName(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        let args = call.arguments as? [String: Any] ?? [String: Any]()
        let name = args["name"] as! String
        let latitude = args["latitude"] as! Double
        let longitude = args["longitude"] as! Double
        let geoName = args["geoName"] as! String
        let rooms = args["rooms"] as! [String]
        let homeManager = ThingSmartHomeManager()

        homeManager.addHome(
            withName: name,
            geoName: geoName,
            rooms: rooms,
            latitude: latitude,
            longitude: longitude,
            success: {
                (homeId) in
                result(homeId)
            },
            failure: {
                (error) in
                if let error = error as? NSError {
                    print("addHomeWithName failure: \(error)")
                    result(
                        FlutterError(
                            code: error.code.description,
                            message: error.description,
                            details: error.debugDescription
                        )
                    )
                }

            }
        )

    }

    private func updateHome(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        let args = call.arguments as? [String: Any] ?? [String: Any]()
        let homeId = args["homeId"] as! Int64
        let name = args["name"] as! String
        let latitude = args["latitude"] as! Double
        let longitude = args["longitude"] as! Double

        let rooms = args["rooms"] as! [String]

        let home = ThingSmartHome(homeId: homeId)

        home?.updateInfo(
            withName: name,
            geoName: name,
            latitude: latitude,
            longitude: longitude,
            rooms: rooms,
            overWriteRoom: true,
            success: {
                result(true)
            },
            failure: { error in

                if let error = error as? NSError {
                    print("addHomeWithName failure: \(error)")
                    result(
                        FlutterError(
                            code: error.code.description,
                            message: error.description,
                            details: error.debugDescription
                        )
                    )
                }
            }
        )
    }

    private func removeHome(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        let args = call.arguments as? [String: Any] ?? [String: Any]()
        let homeId = args["homeId"] as! Int64
        let home = ThingSmartHome(homeId: homeId)
        home?.dismiss(
            success: {
                result(true)
            },
            failure: { error in
                result(false)
            }

        )
    }

    /// Get Home List

    private func getHomeList(result: @escaping FlutterResult) {
        let homeManager = ThingSmartHomeManager()
        homeManager.getHomeList(
            success: { (list) in
                var homes = [[String: Any]]()

                guard let list else {
                    return
                }
                list.forEach { (model) in

                    var home = [String: Any]()
                    home["homeId"] = model.homeId
                    home["name"] = model.name
                    home["geoName"] = model.geoName
                    home["latitude"] = model.latitude
                    home["longitude"] = model.longitude
                    home["backgroundUrl"] = model.backgroundUrl
                    home["role"] = model.role.rawValue
                    home["dealStatus"] = model.dealStatus.rawValue
                    home["managementStatus"] = model.managementStatus
                    home["nickName"] = model.nickName

                    homes.append(home)
                }
                result(homes)
            },
            failure: { (error) in
                if let error = error as? NSError {
                    print("getHomeList failure: \(error)")
                    result(
                        FlutterError(
                            code: error.code.description,
                            message: error.description,
                            details: error.debugDescription
                        )
                    )
                }

            }
        )
    }

    private func startConfigBLEWifiDevice(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        let args = call.arguments as? [String: Any] ?? [String: Any]()
        let ssid = args["ssid"] as! String
        let password = args["password"] as! String
        let timeout = args["timeout"] as! Int
        let homeId = args["homeId"] as! Int64
        let uuid = args["uuid"] as! String
        let productId = args["productId"] as! String
        self.callback = result

        ThingSmartBLEWifiActivator.sharedInstance().bleWifiDelegate = self
        ThingSmartBLEWifiActivator.sharedInstance()

            .startConfigBLEWifiDevice(
                withUUID: uuid,
                homeId: homeId,
                productId: productId,
                ssid: ssid,
                password: password,
                timeout: TimeInterval(timeout)
            ) {

            } failure: {
                self.callback?(
                    FlutterError(
                        code: "Config",
                        message: "Cannot config WiFi",
                        details: nil
                    )
                )
            }

    }

    private func startConfigWiFiDevice(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        let args = call.arguments as? [String: Any] ?? [String: Any]()
        let ssid = args["ssid"] as! String
        let password = args["password"] as! String

        let timeout = args["timeout"] as! Int
        let token = args["token"] as! String
        self.callback = result

        ThingSmartActivator.sharedInstance()?.delegate = self
        ThingSmartActivator.sharedInstance()?.startConfigWiFi(
            .AP,
            ssid: ssid,
            password: password,
            token: token,
            timeout: TimeInterval(timeout)
        )

    }

    private func startConfigWiredDevice(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        let args = call.arguments as? [String: Any] ?? [String: Any]()

        let timeout = args["timeout"] as! Int
        let token = args["token"] as! String
        self.callback = result

        ThingSmartActivator.sharedInstance()?.delegate = self

        ThingSmartActivator.sharedInstance()?.startConfigWiFi(
            withToken: token,
            timeout: TimeInterval(timeout)
        )

    }

    private func startConfigSubDevice(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        let args = call.arguments as? [String: Any] ?? [String: Any]()

        let timeout = args["timeout"] as! Int
        let devId = args["devId"] as! String
        self.callback = result

        ThingSmartActivator.sharedInstance()?.delegate = self
        ThingSmartActivator.sharedInstance()?.activeSubDevice(
            withGwId: devId,
            timeout: TimeInterval(timeout)
        )

    }

    private func requestHomeToken(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        let args = call.arguments as? [String: Any] ?? [String: Any]()
        let homeId = args["homeId"] as! Int64

        ThingSmartActivator.sharedInstance()?.getTokenWithHomeId(
            homeId,
            success: { [weak self] (token) in
                guard self != nil else { return }

                result(token)

            },
            failure: { (error) in
                _ = error?.localizedDescription ?? ""
                result(
                    FlutterError(
                        code: "Config",
                        message: "Cannot Get token",
                        details: nil
                    )
                )

            }
        )
    }

    private func discoverDevices(result: @escaping FlutterResult) {
        _stopConfiguring()
        self.callback = result
        ThingSmartBLEManager.sharedInstance().delegate = self

        ThingSmartBLEManager.sharedInstance().startListening(true)

    }

    private func getWifiSsid(result: @escaping FlutterResult) {
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        ThingSmartActivator.getSSID(
            {
                wifiSsid in
                result(wifiSsid)
            },
            failure: {
                (error) in
                if let error = error as? NSError {
                    print("getWifiSsid failure: \(error)")
                    result(
                        FlutterError(
                            code: error.code.description,
                            message: error.description,
                            details: error.debugDescription
                        )
                    )
                }
            }
        )

    }

    private func getHomeRooms(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        let args = call.arguments as? [String: Any] ?? [String: Any]()
        let homeId = args["homeId"] as! Int64
        let home = ThingSmartHome(homeId: homeId)
        home?.getDataWithSuccess(
            {
                local in
                var rooms = [[String: Any]]()
                home?.roomList.forEach({
                    roomModel in
                    var room = [String: Any]()
                    room["id"] = roomModel.roomId
                    room["name"] = roomModel.name
                    rooms.append(room)
                })
                result(rooms)
            },
            failure: {
                error in

                if let error = error as? NSError {
                    print("getHomeRooms failure: \(error)")
                    result(
                        FlutterError(
                            code: error.code.description,
                            message: error.description,
                            details: error.debugDescription
                        )
                    )
                }
            }
        )
    }

    private func addRoom(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        let args = call.arguments as? [String: Any] ?? [String: Any]()
        let homeId = args["homeId"] as! Int64
        let roomName = args["roomName"] as! String

        ThingSmartHome(homeId: homeId).addRoom(withName: roomName) {
            roomModel in
            var room = [String: Any]()
            room["id"] = roomModel.roomId
            room["name"] = roomModel.name

            result(room)
        } failure: { error in
            if let error = error as? NSError {
                print("getHomeList failure: \(error)")
                result(
                    FlutterError(
                        code: error.code.description,
                        message: error.description,
                        details: error.debugDescription
                    )
                )
            }
        }

    }

    private func removeRoom(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        let args = call.arguments as? [String: Any] ?? [String: Any]()
        let homeId = args["homeId"] as! Int64
        let roomId = args["roomId"] as! Int64

        ThingSmartHome(homeId: homeId).removeRoom(withRoomId: roomId) {
            result(true)
        } failure: { error in
            if let error = error as? NSError {
                print("getHomeList failure: \(error)")
                result(
                    FlutterError(
                        code: error.code.description,
                        message: error.description,
                        details: error.debugDescription
                    )
                )
            }
        }

    }

    private func updateRoom(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        let args = call.arguments as? [String: Any] ?? [String: Any]()
        let homeId = args["homeId"] as! Int64
        let roomName = args["roomName"] as! String
        let roomId = args["roomId"] as! Int64
        ThingSmartRoom(roomId: roomId, homeId: homeId).updateName(roomName) {
            result(true)
        } failure: { error in
            if let error = error as? NSError {
                print("getHomeList failure: \(error)")
                result(
                    FlutterError(
                        code: error.code.description,
                        message: error.description,
                        details: error.debugDescription
                    )
                )
            }
        }

    }

    private func getHomeDevices(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        let args = call.arguments as? [String: Any] ?? [String: Any]()
        let homeId = args["homeId"] as! Int64
        let home = ThingSmartHome(homeId: homeId)
        home?.getDataWithSuccess(
            {
                local in
                var devices = [[String: Any]]()
                home?.deviceList.forEach({
                    deviceModel in
                    let dict = self._modelToDict(deviceModel: deviceModel)
                    devices.append(dict)
                })
                result(devices)
            },
            failure: {
                error in

                if let error = error as? NSError {
                    print("getWifiSsid failure: \(error)")
                    result(
                        FlutterError(
                            code: error.code.description,
                            message: error.description,
                            details: error.debugDescription
                        )
                    )
                }

            }
        )
    }

    private func listenForDevice(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        let args = call.arguments as? [String: Any] ?? [String: Any]()
        let deviceId = args["deviceId"] as! String
        self.device = ThingSmartDevice(deviceId: deviceId)
        if self.device == nil {
            print("device is nil")
            result(
                FlutterError(
                    code: "Thing Smart device ",
                    message: "device is nil",
                    details: nil
                )
            )
            return
        }

        device!.delegate = self
        result(true)
    }

    private func publishDps(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        let args = call.arguments as? [String: Any] ?? [String: Any]()
        let deviceId = args["deviceId"] as! String
        let dps = args["dps"] as! [String: Any]

        //        let home = ThingSmartHome(homeId: 98744020)
        //        home?.getDetailWithSuccess({
        //            local in
        //
        //        }, failure: {
        //            error in
        //        })

        self.device = ThingSmartDevice(deviceId: deviceId)
        if self.device == nil {
            print("device is nil")
            result(
                FlutterError(
                    code: "Thing Smart device ",
                    message: "device is nil",
                    details: nil
                )
            )
            return
        }

        device!.delegate = self
        device!.publishDps(
            dps,
            success: {

                result(true)

            },
            failure: {
                (error) in
                if let error = error as? NSError {
                    print("publishDps failure: \(error)")
                    result(
                        FlutterError(
                            code: error.code.description,
                            message: error.description,
                            details: error.debugDescription
                        )
                    )
                }
            }
        )

    }

    private func removeDevice(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        let args = call.arguments as? [String: Any] ?? [String: Any]()
        let deviceId = args["deviceId"] as! String
        self.device = ThingSmartDevice(deviceId: deviceId)

        self.device?.remove(
            {
                result(true)
            },
            failure: {
                (error) in
                if let error = error as? NSError {
                    print("removeDevice failure: \(error)")
                    result(
                        FlutterError(
                            code: error.code.description,
                            message: error.description,
                            details: error.debugDescription
                        )
                    )
                }
            }
        )
    }

    private func updateDeviceName(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        let args = call.arguments as? [String: Any] ?? [String: Any]()
        let deviceId = args["deviceId"] as! String
        let name = args["name"] as! String

        self.device = ThingSmartDevice(deviceId: deviceId)
        self.device?.updateName(name) {
            result(true)
        } failure: { error in
            if let error = error as? NSError {
                print("updateDeviceName failure: \(error)")
                result(
                    FlutterError(
                        code: error.code.description,
                        message: error.description,
                        details: error.debugDescription
                    )
                )
            }
        }

    }

    /// assign device to room
    private func assignDeviceToRoom(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        let args = call.arguments as? [String: Any] ?? [String: Any]()
        let roomId = args["roomId"] as! Int64
        let deviceId = args["deviceId"] as! String
        let homeId = args["homeId"] as! Int64

        let room = ThingSmartRoom(roomId: roomId, homeId: homeId)

        room!.addDevice(
            withDeviceId: deviceId,
            success: {
                result(true)
                print("  assignDeviceToRoom success")
            },
            failure: {
                (error) in
                if let error = error as? NSError {
                    print("assignDeviceToRoom failure: \(error)")
                    result(
                        FlutterError(
                            code: error.code.description,
                            message: error.description,
                            details: error.debugDescription
                        )
                    )
                }
            }
        )

    }

    // MARK: private helper methods
    private func _stopConfiguring() {
        ThingSmartBLEManager.sharedInstance().delegate = nil
        ThingSmartBLEManager.sharedInstance().stopListening(true)
        ThingSmartBLEWifiActivator.sharedInstance().bleWifiDelegate = nil
        ThingSmartBLEWifiActivator.sharedInstance().stopDiscover()

        ThingSmartActivator.sharedInstance()?.delegate = nil
        ThingSmartActivator.sharedInstance()?.stopConfigWiFi()
    }

    private func _modelToDict(deviceModel: ThingSmartDeviceModel) -> [String:
        Any]
    {
        var dict = [String: Any]()
        dict["uiName"] = deviceModel.uiName
        dict["devId"] = deviceModel.devId
        dict["name"] = deviceModel.name
        dict["iconUrl"] = deviceModel.iconUrl
        dict["isOnline"] = deviceModel.isOnline
        dict["isCloudOnline"] = deviceModel.isCloudOnline
        dict["isLocalOnline"] = deviceModel.isLocalOnline
        dict["isShare"] = deviceModel.isShare
        dict["dps"] = deviceModel.dps
        dict["dpCodes"] = deviceModel.dpCodes
        dict["productId"] = deviceModel.productId
        dict["capability"] = deviceModel.capability
        dict["supportGroup"] = deviceModel.supportGroup
        dict["gwType"] = deviceModel.gwType
        dict["pv"] = deviceModel.pv
        dict["lpv"] = deviceModel.lpv
        dict["latitude"] = deviceModel.latitude
        dict["longitude"] = deviceModel.longitude
        dict["localKey"] = deviceModel.localKey
        dict["uuid"] = deviceModel.uuid
        dict["homeId"] = deviceModel.homeId
        dict["roomId"] = deviceModel.roomId
        dict["timezoneId"] = deviceModel.timezoneId
        dict["nodeId"] = deviceModel.nodeId
        dict["parentId"] = deviceModel.parentId
        dict["isMeshBleOnline"] = deviceModel.isMeshBleOnline
        dict["devKey"] = deviceModel.devKey
        dict["standard"] = deviceModel.standard
        dict["activeTime"] = deviceModel.activeTime
        dict["homeDisplayOrder"] = deviceModel.homeDisplayOrder
        dict["sharedTime"] = deviceModel.sharedTime
        dict["accessType"] = deviceModel.accessType
        dict["schema"] = deviceModel.schema
        dict["category"] = deviceModel.category
        dict["categoryCode"] = deviceModel.categoryCode
        dict["cadv"] = deviceModel.cadv
        dict["dpName"] = deviceModel.dpName
        dict["productVer"] = deviceModel.productVer
        dict["uiId"] = deviceModel.uiId
        dict["vendorInfo"] = deviceModel.vendorInfo

        return dict
    }

    // MARK: Scene managment

    public func getSceneList(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        let args = call.arguments as? [String: Any] ?? [String: Any]()

        let homeId = args["homeId"] as! Int64
        ThingSmartSceneManager.sharedInstance()?.getSimpleSceneList(
            withHomeId: homeId
        ) { list in

            var scenes = [[String: Any?]]()

            list.forEach({
                item in

                scenes.append(item.toDictionary())
            })
            result(scenes)

        } failure: { error in
            if let error = error as? NSError {
                print("getSceneList failure: \(error)")
                result(
                    FlutterError(
                        code: error.code.description,
                        message: error.description,
                        details: error.debugDescription
                    )
                )
            }
        }

    }

    public func fetchSceneDetail(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        let args: [String: Any] = call.arguments as! [String: Any]
        let sceneId = args["sceneId"] as! String
        let homeId = args["homeId"] as! Int64
        let ruleGenre = args["ruleGenre"] as! Int
        let supportHome = args["supportHome"] as! Bool
        let details = TSceneDetailParams()
        details.sceneId = sceneId
        details.gid = homeId
        details.ruleGenre = ThingSmartSceneRuleGenre.init(
            rawValue: UInt(ruleGenre)
        )!
        details.supportHome = supportHome

        ThingSmartSceneManager.sharedInstance().fetchSceneDetail(with: details)
        { model in

            result(model.toDictionary())
        } failure: { error in
            if let error = error as? NSError {
                print("fetchSceneDetail failure: \(error)")
                result(
                    FlutterError(
                        code: error.code.description,
                        message: error.description,
                        details: error.debugDescription
                    )
                )
            }
        }

    }

    @available(iOS 13.0, *)
    func getThingSmartSceneDPModel(_ devId: String) async
        -> [ThingSmartSceneDPModel]?
    {
        await withCheckedContinuation { cont in
            ThingSmartSceneManager.sharedInstance()?.getCondicationDeviceDPList(
                withDevId: devId
            ) { list in
                cont.resume(returning: list)
            } failure: { _ in
                cont.resume(returning: nil)
            }
        }
    }

    private func addScene(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        let args: [String: Any] = call.arguments as! [String: Any]
        let jsonData = try! JSONSerialization.data(
            withJSONObject: args,

        )

        do {
            let factory = try JSONDecoder().decode(
                ThingSmartSceneFactory.self,
                from: jsonData
            )

            Task {
                // ❷ collect needed DP models first
                var dpCache: [String: [ThingSmartSceneDPModel]?] = [:]  // key = devId
                for cond in factory.conditions! {
                    if dpCache[cond.deviceId!] == nil {  // fetch once per device
                        dpCache[cond.deviceId!] =
                            await getThingSmartSceneDPModel(cond.deviceId!)
                    }
                }

                // ❸ build lists now that the data is ready
                let preConditions = factory.preConditions!.map {
                    $0.toThingModel()!
                }
                let conditions = factory.conditions!.map { sceneCondition in
                    sceneCondition.toThingModel { devId, dpId in
                        (dpCache[devId]!!).first { $0.dpId == dpId }
                    }!
                }

                let actions = factory.actions!.map { $0.toTuyaModel() }

                ThingSmartScene.addNewScene(
                    withName: factory.name,
                    homeId: Int64(factory.homeId!),
                    background: "",
                    showFirstPage: factory.showFirstPage!,
                    preConditionList: preConditions,
                    conditionList: conditions,
                    actionList: actions,
                    matchType: ThingSmartConditionMatchType(
                        rawValue: UInt(factory.matchType!)
                    )!
                ) { model in
                    result(model?.toDictionary())
                } failure: { error in
                    if let error = error as? NSError {
                        print("addScene failure: \(error)")
                        result(
                            FlutterError(
                                code: error.code.description,
                                message: error.description,
                                details: error.debugDescription
                            )
                        )
                    }
                }

            }

        } catch {
            result(
                FlutterError(
                    code: "DECODE_ERROR",
                    message: error.localizedDescription,
                    details: nil
                )
            )
        }

    }

    private func editScene(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        let args: [String: Any] = call.arguments as! [String: Any]
        let jsonData = try! JSONSerialization.data(
            withJSONObject: args,

        )

        do {
            let factory = try JSONDecoder().decode(
                ThingSmartSceneFactory.self,
                from: jsonData
            )

            Task {
                // ❷ collect needed DP models first
                var dpCache: [String: [ThingSmartSceneDPModel]?] = [:]  // key = devId
                let sceneModel = ThingSmartSceneModel()
                sceneModel.sceneId = factory.id!
                if factory.name != nil {
                    sceneModel.name = factory.name!
                }

                if factory.conditions != nil {
                    for cond in factory.conditions! {
                        if dpCache[cond.deviceId!] == nil {  // fetch once per device
                            dpCache[cond.deviceId!] =
                                await getThingSmartSceneDPModel(cond.deviceId!)
                        }
                    }
                    let conditions = factory.conditions!.map { sceneCondition in
                        sceneCondition.toThingModel { devId, dpId in
                            (dpCache[devId]!!).first { $0.dpId == dpId }
                        }!
                    }
                    sceneModel.conditions = conditions
                }

                if factory.preConditions != nil {
                    // ❸ build lists now that the data is ready
                    let preConditions = factory.preConditions!.map {
                        $0.toThingModel()!
                    }
                    sceneModel.preConditions = preConditions
                }

                if factory.actions != nil {
                    let actions = factory.actions!.map { $0.toTuyaModel() }
                    sceneModel.actions = actions
                }

                if factory.showFirstPage != nil {
                    sceneModel.stickyOnTop = factory.showFirstPage!
                }

                if factory.matchType != nil {
                    sceneModel.matchType = ThingSmartConditionMatchType(
                        rawValue: UInt(factory.matchType!)
                    )!
                }

                let scene = ThingSmartScene(sceneModel: sceneModel)

                scene?.modifyScene(with: sceneModel) {
                    result(true)
                } failure: { error in
                    if let error = error as? NSError {
                        print("editScene failure: \(error)")
                        result(
                            FlutterError(
                                code: error.code.description,
                                message: error.description,
                                details: error.debugDescription
                            )
                        )
                    }
                }

            }

        } catch {
            result(
                FlutterError(
                    code: "DECODE_ERROR",
                    message: error.localizedDescription,
                    details: nil
                )
            )
        }
    }

    private func removeScene(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        let args = call.arguments as? [String: Any] ?? [String: Any]()

        let sceneId = args["sceneId"] as! String
        let homeId = args["homeId"] as! Int64

        let sceneModel = ThingSmartSceneModel()
        sceneModel.sceneId = sceneId
        let scene = ThingSmartScene(sceneModel: sceneModel)
        scene?.delete(withHomeId: homeId) { value in
            result(value)
        } failure: { error in
            if let error = error as? NSError {
                print("addScene failure: \(error)")
                result(
                    FlutterError(
                        code: error.code.description,
                        message: error.description,
                        details: error.debugDescription
                    )
                )
            }
        }

    }

    private func runScene(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        let args = call.arguments as? [String: Any] ?? [String: Any]()
        let sceneId = args["sceneId"] as! String
        let sceneModel = ThingSmartSceneModel()
        sceneModel.sceneId = sceneId
        let scene = ThingSmartScene(sceneModel: sceneModel)
        scene?.execute {
            result(true)
        } failure: { error in
            if let error = error as? NSError {
                print("addScene failure: \(error)")
                result(
                    FlutterError(
                        code: error.code.description,
                        message: error.description,
                        details: error.debugDescription
                    )
                )
            }
        }

    }

    private func changeAutomation(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        let args = call.arguments as? [String: Any] ?? [String: Any]()
        let sceneId = args["sceneId"] as! String
        let status = args["status"] as! Bool
        let sceneModel = ThingSmartSceneModel()
        sceneModel.sceneId = sceneId
        let scene = ThingSmartScene(sceneModel: sceneModel)

        if status {
            scene?.enable {
                result(true)
            } failure: { error in
                if let error = error as? NSError {
                    print("addScene failure: \(error)")
                    result(
                        FlutterError(
                            code: error.code.description,
                            message: error.description,
                            details: error.debugDescription
                        )
                    )
                }
            }

        } else {
            scene?.disableScene {
                result(true)
            } failure: { error in
                if let error = error as? NSError {
                    print("addScene failure: \(error)")
                    result(
                        FlutterError(
                            code: error.code.description,
                            message: error.description,
                            details: error.debugDescription
                        )
                    )
                }
            }

        }

    }

    // Member Management

    private func addMember(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        let args = call.arguments as? [String: Any] ?? [String: Any]()
        let homeId = args["homeId"] as! Int64
        let name = args["name"] as! String
        let autoAccept = args["autoAccept"] as! Bool
        let countryCode = args["countryCode"] as? String
        let account = args["account"] as? String
        let role: Int = args["role"] as! Int
        let request = ThingSmartHomeAddMemberRequestModel()
        request.name = name
        request.autoAccept = autoAccept
        if countryCode != nil {
            request.countryCode = countryCode!
        }

        request.role = ThingHomeRoleType(rawValue: role)!

        if account != nil {
            request.account = account!
        }

        ThingSmartHome(homeId: homeId).addMember(
            withAddMemeberRequestModel: request
        ) { data in
            if let data = data {
                print("addMember success: \(data)")
                result(data["memberId"])
            }
            result(nil)
        } failure: { error in
            if let error = error as? NSError {
                print("addMember failure: \(error)")
                result(
                    FlutterError(
                        code: error.code.description,
                        message: error.description,
                        details: error.debugDescription
                    )
                )
            }
        }

    }

    private func queryMemberList(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        let args = call.arguments as? [String: Any] ?? [String: Any]()
        let homeId = args["homeId"] as! Int64
        ThingSmartHome(homeId: homeId).getMemberList { list in
            let data: [[AnyHashable: Any]] =
                (list?.map { (member) -> [AnyHashable: Any] in
                    var dict: [AnyHashable: Any] = [:]
                    dict["memberId"] = member.memberId
                    dict["name"] = member.name
                    dict["homeId"] = member.homeId
                    dict["role"] = member.role.rawValue
                    dict["mobile"] = member.mobile
                    dict["userName"] = member.userName
                    dict["uid"] = member.uid
                    dict["memberStatus"] = member.dealStatus.rawValue

                    return dict
                })!
            result(data)
        } failure: { error in
            if let error = error as? NSError {
                print("queryMemberList failure: \(error)")
                result(
                    FlutterError(
                        code: error.code.description,
                        message: error.description,
                        details: error.debugDescription
                    )
                )
            }
        }

    }

    private func removeMember(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        let args = call.arguments as? [String: Any] ?? [String: Any]()
        let memberId = args["memberId"] as! Int64
        ThingSmartHomeMember().removeHomeMember(withMemberId: memberId) {
            result(true)
        } failure: { error in
            if let error = error as? NSError {
                print("removeMember failure: \(error)")
                result(
                    FlutterError(
                        code: error.code.description,
                        message: error.description,
                        details: error.debugDescription
                    )
                )
            }
        }

    }

    private func modifyMember(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        let args = call.arguments as? [String: Any] ?? [String: Any]()

        let name = args["name"] as? String
        let role = args["role"] as? Int
        let memberId = args["memberId"] as! Int64
        let request = ThingSmartHomeMemberRequestModel()
        request.memberId = memberId

        if let name = name {
            request.name = name
        }

        if let role = role {
            request.role = .init(rawValue: role)!
        }

        ThingSmartHomeMember().updateHomeMemberInfo(with: request) {
            result(true)
        } failure: { error in
            if let error = error as? NSError {
                print("modifyMember failure: \(error)")
                result(
                    FlutterError(
                        code: error.code.description,
                        message: error.description,
                        details: error.debugDescription
                    )
                )
            }
        }

    }

    private func joinHome(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        let args = call.arguments as? [String: Any] ?? [String: Any]()
        let code = args["code"] as! String
        ThingSmartHomeInvitation().joinHome(withInvitationCode: code) { res in
            result(res)
        } failure: { error in
            if let error = error as? NSError {
                print("joinHome failure: \(error)")
                result(
                    FlutterError(
                        code: error.code.description,
                        message: error.description,
                        details: error.debugDescription
                    )
                )
            }
        }

    }

    private func cancelInvitation(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        let args = call.arguments as? [String: Any] ?? [String: Any]()
        let invitationID = args["invitationID"] as! Int
        ThingSmartHomeInvitation().cancelInvitation(
            withInvitationID: NSNumber(value: invitationID)
        ) { res in
            result(res)
        } failure: { error in
            if let error = error as? NSError {
                print("cancelInvitation failure: \(error)")
                result(
                    FlutterError(
                        code: error.code.description,
                        message: error.description,
                        details: error.debugDescription
                    )
                )
            }
        }

    }

    private func acceptOrRejectInvitation(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        let args = call.arguments as? [String: Any] ?? [String: Any]()
        let homeId = args["homeId"] as! Int64
        let accept = args["accept"] as! Bool
        ThingSmartHome(homeId: homeId).joinFamily(withAccept: accept) { res in
            result(res)
        } failure: { error in
            if let error = error as? NSError {
                print("acceptOrRejectInvitation failure: \(error)")
                result(
                    FlutterError(
                        code: error.code.description,
                        message: error.description,
                        details: error.debugDescription
                    )
                )
            }
        }

    }

    private func queryInvitation(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        let args = call.arguments as? [String: Any] ?? [String: Any]()
        let homeId = args["homeId"] as! Int64
        ThingSmartHomeInvitation().fetchRecordList(withHomeID: homeId) { list in
            let data: [[String: Any]] = list.map { (item) -> [String: Any] in
                var dict: [String: Any] = [:]
                dict["invitationID"] = item.invitationID
                dict["invitationCode"] = item.invitationCode
                dict["name"] = item.name
                dict["dealStatus"] = item.dealStatus.rawValue
                dict["validTime"] = item.validTime
                dict["role"] = item.role.rawValue

                return dict
            }
            result(data)
        } failure: { error in
            if let error = error as? NSError {
                print("acceptOrRejectInvitation failure: \(error)")
                result(
                    FlutterError(
                        code: error.code.description,
                        message: error.description,
                        details: error.debugDescription
                    )
                )
            }
        }

    }

    private func modifyInvitation(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        let args = call.arguments as? [String: Any] ?? [String: Any]()
        let invitationId = args["invitationId"] as! Int64
        let name = args["name"] as! String
        let role = args["role"] as! Int
        let request = ThingSmartHomeInvitationInfoRequestModel()
        request.invitationID = NSNumber(value: invitationId)
        request.name = name
        request.role = .init(rawValue: role)!
        ThingSmartHomeInvitation().updateInvitationInfo(with: request) { res in
            result(res)
        } failure: { error in
            if let error = error as? NSError {
                print("modifyInvitation failure: \(error)")
                result(
                    FlutterError(
                        code: error.code.description,
                        message: error.description,
                        details: error.debugDescription
                    )
                )
            }
        }

    }

}

@available(iOS 13.0, *)
extension TuyaHomeSdkFlutterPlugin: FlutterStreamHandler {
    public func onListen(
        withArguments arguments: Any?,
        eventSink events: @escaping FlutterEventSink
    ) -> FlutterError? {
        self.eventSink = events

        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        self.device?.delegate = nil
        return nil
    }
}

@available(iOS 13.0, *)
extension TuyaHomeSdkFlutterPlugin: ThingSmartDeviceDelegate {
    open func device(
        _ device: ThingSmartDevice,
        dpsUpdate dps: [AnyHashable: Any]
    ) {
        print(" DPS Update \(dps)")
        self.eventSink?(device.deviceModel.dps)

    }

    open func deviceRemoved(_ device: ThingSmartDevice) {
        print(" Device Removed")
    }

    open func deviceInfoUpdate(_ device: ThingSmartDevice) {
        print(" Device Info Update")
        self.eventSink?(device.deviceModel.dps)
    }
}

@available(iOS 13.0, *)
extension TuyaHomeSdkFlutterPlugin: ThingSmartBLEManagerDelegate,
    ThingSmartBLEWifiActivatorDelegate, ThingSmartActivatorDelegate
{

    public func activator(
        _ activator: ThingSmartActivator,
        didReceiveDevice deviceModel: ThingSmartDeviceModel?,
        error: (any Error)?
    ) {

        guard error == nil,
            let deviceModel = deviceModel
        else {
            return
        }
        let dict = self._modelToDict(deviceModel: deviceModel)
        self.callback?(dict)

        self._stopConfiguring()

    }

    /// Discover devices

    public func didDiscoveryDevice(withDeviceInfo deviceInfo: ThingBLEAdvModel)
    {
        print(" uuid \(String(describing: deviceInfo.uuid))")

        ThingSmartBLEManager.sharedInstance().queryDeviceInfo(
            withUUID: deviceInfo.uuid,
            productId: deviceInfo.productId,
            success: {
                (info) in

                guard let info else {
                    return
                }
                var device = [String: Any]()
                device["productId"] = deviceInfo.productId
                device["uuid"] = deviceInfo.uuid
                device["name"] = info["name"]
                device["iconUrl"] = info["icon"]
                device["mac"] = deviceInfo.mac
                self.deviceDiscoveryHandler.discoverySink?(device)
//                self.callback?(device)
                //            self._stopConfiguring()
            },
            failure: {
                (error) in
                if let error = error as? NSError {
                    print("getToken failure: \(error)")
                    self.callback?(
                        FlutterError(
                            code: error.code.description,
                            message: error.description,
                            details: error.debugDescription
                        )
                    )
                    self._stopConfiguring()
                }
            }
        )
    }

    // When the device connected to the router and activate itself successfully to the cloud, this delegate method will be called.
    open func bleWifiActivator(
        _ activator: ThingSmartBLEWifiActivator,
        didReceiveBLEWifiConfigDevice deviceModel: ThingSmartDeviceModel?,
        error: Error?
    ) {
        guard error == nil,
            let deviceModel = deviceModel
        else {
            return
        }
        let dict = self._modelToDict(deviceModel: deviceModel)
        self.callback?(dict)

        self._stopConfiguring()
    }

}
