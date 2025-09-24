package com.innovationcodes.tuya_home_sdk_flutter

import android.Manifest
import android.app.Activity
import android.app.Application
import android.content.Context
import android.content.pm.PackageManager
import android.net.ConnectivityManager
import android.net.wifi.WifiManager
import android.os.Build
import android.util.Base64
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.alibaba.fastjson.JSON
import com.premierank.tuyahomesdkkit.TuyaHomeSdkKit
import com.thingclips.scene.core.tool.mapToDeviceConditionData
import com.thingclips.sdk.home.bean.InviteListResponseBean
import com.thingclips.smart.android.ble.api.BleScanResponse
import com.thingclips.smart.android.ble.api.IThingBleConfigListener
import com.thingclips.smart.android.ble.api.ScanType
import com.thingclips.smart.android.user.api.IBooleanCallback
import com.thingclips.smart.android.user.api.ILoginCallback
import com.thingclips.smart.android.user.api.ILogoutCallback
import com.thingclips.smart.android.user.api.IReNickNameCallback
import com.thingclips.smart.android.user.api.IRegisterCallback
import com.thingclips.smart.android.user.api.IResetPasswordCallback
import com.thingclips.smart.android.user.bean.User
import com.thingclips.smart.home.sdk.ThingHomeSdk
import com.thingclips.smart.home.sdk.bean.ConfigProductInfoBean
import com.thingclips.smart.home.sdk.bean.HomeBean
import com.thingclips.smart.home.sdk.bean.MemberBean
import com.thingclips.smart.home.sdk.bean.MemberWrapperBean
import com.thingclips.smart.home.sdk.bean.RoomBean
import com.thingclips.smart.home.sdk.builder.ActivatorBuilder
import com.thingclips.smart.home.sdk.builder.ThingGwActivatorBuilder
import com.thingclips.smart.home.sdk.builder.ThingGwSubDevActivatorBuilder
import com.thingclips.smart.home.sdk.callback.IThingGetHomeListCallback
import com.thingclips.smart.home.sdk.callback.IThingGetMemberListCallback
import com.thingclips.smart.home.sdk.callback.IThingGetRoomListCallback
import com.thingclips.smart.home.sdk.callback.IThingHomeResultCallback
import com.thingclips.smart.home.sdk.callback.IThingRoomResultCallback
import com.thingclips.smart.scene.model.NormalScene
import com.thingclips.smart.scene.model.condition.ConditionItemDetail
import com.thingclips.smart.scene.model.device.DeviceConditionData
import com.thingclips.smart.sdk.api.IDevListener
import com.thingclips.smart.sdk.api.IResultCallback
import com.thingclips.smart.sdk.api.IThingActivatorGetToken
import com.thingclips.smart.sdk.api.IThingDataCallback
import com.thingclips.smart.sdk.api.IThingDevice
import com.thingclips.smart.sdk.api.IThingSmartActivatorListener
import com.thingclips.smart.sdk.bean.DeviceBean
import com.thingclips.smart.sdk.enums.ActivatorModelEnum
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.EventChannel.StreamHandler
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.RequestPermissionsResultListener
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import java.io.File
import kotlin.coroutines.suspendCoroutine


/** TuyaHomeSdkFlutterPlugin */
class TuyaHomeSdkFlutterPlugin : FlutterPlugin, MethodCallHandler,
    RequestPermissionsResultListener, ActivityAware, StreamHandler {

    private lateinit var channel: MethodChannel
    private lateinit var mContext: Context
    private var mActivity: Activity? = null
    private var eventSink: EventSink? = null
    private var device: IThingDevice? = null
    private var deviceDiscoveryHandler = DeviceDiscoveryStreamHandler()
    private var permissionGranted: Boolean = false


    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "tuya_home_sdk_flutter")
        val event = EventChannel(
            flutterPluginBinding.binaryMessenger,
            "tuya_home_sdk_flutter_device_dps_event"
        )
        val deviceEvent = EventChannel(
            flutterPluginBinding.binaryMessenger,
            "tuya_home_sdk_flutter_device_discovery_event",

            )
        mContext = flutterPluginBinding.applicationContext
        event.setStreamHandler(this)
        deviceEvent.setStreamHandler(deviceDiscoveryHandler)
        channel.setMethodCallHandler(this)

    }


    override fun onMethodCall(call: MethodCall, result: Result) {


        when (call.method) {
            "initSDK" -> initSDK(call, result)
            "sendVerifyCodeWithUserName" -> sendVerifyCodeWithUserName(call, result)
            "checkCodeWithUserName" -> checkCodeWithUserName(call, result)
            "registerByUserName" -> registerByUserName(call, result)
            "registerByPhone" -> registerByPhone(call, result)
            "loginWithUserName" -> loginWithUserName(call, result)
            "loginWithPhonePassword" -> loginWithPhonePassword(call, result)
            "loginWithPhoneCode" -> loginWithPhoneCode(call, result)
            "loginByAuth2" -> loginByAuth2(call, result)
            "resetPasswordByEmail" -> resetPasswordByEmail(call, result)
            "addHomeWithName" -> addHomeWithName(call, result)
            "updateHome" -> updateHome(call, result)
            "removeHome" -> removeHome(call, result)
            "getHomeList" -> getHomeList(result)
            "getHomeRooms" -> getHomeRooms(call, result)
            "addRoom" -> addRoom(call, result)
            "removeRoom" -> removeRoom(call, result)
            "updateRoom" -> updateRoom(call, result)
            "getHomeDevices" -> getHomeDevices(call, result)
            "getUserInfo" -> getUserInfo(result)
            "getToken" -> getToken(call, result)
            "updateUserNickName" -> updateUserNickName(call, result)
            "updateUserIcon" -> updateUserIcon(call, result)
            "assignDeviceToRoom" -> assignDeviceToRoom(call, result)
            "removeDevice" -> removeDevice(call, result)
            "renameDevice" -> renameDevice(call, result)
            "getDeviceRoom" -> getDeviceRoom(call, result)
            "discoverDevices" -> discoverDevices(result)
            "getWifiSsid" -> getWifiSsid(result)
            "startConfigBLEWifiDevice" -> startConfigBLEWifiDevice(call, result)
            "requestHomeToken" -> requestHomeToken(call, result)
            "startConfigWiFiDevice" -> startConfigWiFiDevice(call, result)
            "startConfigWiredDevice" -> startConfigWiredDevice(call, result)
            "startConfigSubDevice" -> startConfigSubDevice(call, result)
            "publishDps" -> publishDps(call, result)
            "listenForDevice" -> listenForDevice(call, result)
            "logout" -> logout(result)
            "getSceneList" -> getSceneList(call, result)
            "fetchSceneDetail" -> fetchSceneDetail(call, result)
            "addScene" -> addScene(call, result)
            "removeScene" -> removeScene(call, result)
            "runScene" -> runScene(call, result)
            "changeAutomation" -> changeAutomation(call, result)
            "editScene" -> editScene(call, result)
            "addMember" -> addMember(call, result)
            "queryMemberList" -> queryMemberList(call, result)
            "removeMember" -> removeMember(call, result)
            "modifyMember" -> modifyMember(call, result)
            "joinHome" -> joinHome(call, result)
            "cancelInvitation" -> cancelInvitation(call, result)
            "acceptOrRejectInvitation" -> acceptOrRejectInvitation(call, result)
            "queryInvitations" -> queryInvitations(call, result)
            "modifyInvitation" -> modifyInvitation(call, result)
            else -> result.notImplemented()
        }


    }


    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)

    }

    ///
    private fun initSDK(call: MethodCall, result: Result) {
        try {
            val appKey = call.argument<String>("appKey")
            val secret = call.argument<String>("appSecret")
            val isDebug = call.argument<Boolean>("isDebug")
            val key = call.argument<String>("key")
            TuyaHomeSdkKit.startSdk(
                mContext as Application,
                appKey!!,
                secret!!,
                key!!,
                isDebug ?: false
            )
            result.success(true)

        } catch (e: Exception) {

            result.error(e.message ?: "", e.localizedMessage, null)
        }
    }


    /// Register with E-mail
    private fun sendVerifyCodeWithUserName(call: MethodCall, result: Result) {
        val username = call.argument<String>("username")
        val countryCode = call.argument<String>("country_code")
        val type = call.argument<Int>("type")

        ThingHomeSdk.getUserInstance().sendVerifyCodeWithUserName(
            username,
            "",
            countryCode,
            type!!,
            object : IResultCallback {
                override fun onError(code: String?, error: String?) {
                    result.error(code!!, error, null)

                }

                override fun onSuccess() {
                    result.success(true)
                }


            }
        )


    }


    private fun checkCodeWithUserName(call: MethodCall, result: Result) {
        val username = call.argument<String>("username")
        val countryCode = call.argument<String>("country_code")
        val type = call.argument<Int>("type")
        val code = call.argument<String>("code")

        ThingHomeSdk.getUserInstance()
            .checkCodeWithUserName(
                username,
                "",
                countryCode,
                code,
                type!!, object : IResultCallback {
                    override fun onError(code: String?, error: String?) {
                        result.error(code!!, error, null)
                    }

                    override fun onSuccess() {
                        result.success(true)
                    }

                }
            )
    }


    private fun registerByUserName(call: MethodCall, result: Result) {
        val username = call.argument<String>("username")
        val countryCode = call.argument<String>("country_code")

        val code = call.argument<String>("code")
        val password = call.argument<String>("password")

        ThingHomeSdk.getUserInstance().registerAccountWithEmail(
            countryCode,
            username,
            password,
            code,
            object : IRegisterCallback {
                override fun onSuccess(p0: User?) {
                    result.success(true)
                }

                override fun onError(code: String?, error: String?) {
                    result.error(code!!, error, null)
                }

            })
    }

    private fun registerByPhone(call: MethodCall, result: Result) {
        val username = call.argument<String>("username")
        val countryCode = call.argument<String>("country_code")

        val code = call.argument<String>("code")
        val password = call.argument<String>("password")

        ThingHomeSdk.getUserInstance().registerAccountWithPhone(
            countryCode,
            username,
            password,
            code,
            object : IRegisterCallback {
                override fun onSuccess(p0: User?) {
                    result.success(true)
                }

                override fun onError(code: String?, error: String?) {
                    result.error(code!!, error, null)
                }

            })
    }


    private fun loginWithUserName(call: MethodCall, result: Result) {
        val username = call.argument<String>("username")
        val countryCode = call.argument<String>("country_code")
        val password = call.argument<String>("password")
        ThingHomeSdk.getUserInstance()
            .loginWithEmail(countryCode, username, password, object : ILoginCallback {
                override fun onSuccess(p0: User?) {
                    result.success(true)
                }

                override fun onError(code: String?, error: String?) {
                    result.error(code!!, error, null)
                }
            })
    }

    private fun loginWithPhonePassword(call: MethodCall, result: Result) {
        val username = call.argument<String>("username")
        val countryCode = call.argument<String>("country_code")
        val password = call.argument<String>("password")
        ThingHomeSdk.getUserInstance()
            .loginWithPhonePassword(countryCode, username, password, object : ILoginCallback {
                override fun onSuccess(p0: User?) {
                    result.success(true)
                }

                override fun onError(code: String?, error: String?) {
                    result.error(code!!, error, null)
                }
            })
    }


    private fun loginWithPhoneCode(call: MethodCall, result: Result) {
        val username = call.argument<String>("username")
        val countryCode = call.argument<String>("country_code")
        val code = call.argument<String>("code")
        ThingHomeSdk.getUserInstance()
            .loginWithPhone(countryCode, username, code, object : ILoginCallback {
                override fun onSuccess(p0: User?) {
                    result.success(true)
                }

                override fun onError(code: String?, error: String?) {
                    result.error(code!!, error, null)
                }
            })
    }


    private fun loginByAuth2(call: MethodCall, result: Result) {
        val type = call.argument<String>("type")
        val countryCode = call.argument<String>("country_code")
        val accessToken = call.argument<String>("access_token")
        ThingHomeSdk.getUserInstance()
            .thirdLogin(countryCode, accessToken, type, object : ILoginCallback {
                override fun onSuccess(p0: User?) {
                    result.success(true)
                }

                override fun onError(code: String?, error: String?) {
                    result.error(code!!, error, null)
                }
            })
    }


    private fun resetPasswordByEmail(call: MethodCall, result: Result) {
        val username = call.argument<String>("username")
        val countryCode = call.argument<String>("country_code")
        val password = call.argument<String>("password")
        val code = call.argument<String>("code")

        ThingHomeSdk.getUserInstance().resetEmailPassword(
            countryCode,
            username,
            code,
            password, object : IResetPasswordCallback {
                override fun onSuccess() {
                    result.success(true)
                }

                override fun onError(code: String?, error: String?) {
                    result.error(code!!, error, null)
                }

            }
        )

    }

    private fun addHomeWithName(call: MethodCall, result: Result) {
        val name = call.argument<String>("name")!!
        val latitude = call.argument<Double>("latitude")!!
        val longitude = call.argument<Double>("longitude")!!
        val geoName = call.argument<String>("geoName")!!
        val rooms = call.argument<List<String>>("rooms")!!

        ThingHomeSdk.getHomeManagerInstance()
            .createHome(name, longitude, latitude, geoName, rooms, object :
                IThingHomeResultCallback {
                override fun onSuccess(bean: HomeBean?) {
                    if (bean != null) {
                        result.success(bean.homeId)
                    } else {
                        result.error("Home Manager", "Home not created", null)
                    }

                }

                override fun onError(code: String?, error: String?) {
                    result.error(code!!, error, null)
                }

            })
    }

    private fun updateHome(call: MethodCall, result: Result) {
        val name = call.argument<String>("name")!!
        val homeId = call.argument<Int>("homeId")!!
        val latitude = call.argument<Double>("latitude")!!
        val longitude = call.argument<Double>("longitude")!!
        val geoName = call.argument<String>("geoName")!!
        val rooms = call.argument<List<String>>("rooms")!!

        val home = ThingHomeSdk.newHomeInstance(homeId.toLong())
        home.updateHome(name, longitude, latitude, geoName, rooms, true, object : IResultCallback {
            override fun onError(code: String?, error: String?) {
                result.error(code!!, error, null)
            }

            override fun onSuccess() {
                result.success(true)
            }

        })
    }


    private fun removeHome(call: MethodCall, result: Result) {
        val homeId = call.argument<Int>("homeId")!!
        val home = ThingHomeSdk.newHomeInstance(homeId.toLong())
        home.dismissHome(object : IResultCallback {
            override fun onError(code: String?, error: String?) {
                result.success(false)
            }

            override fun onSuccess() {
                result.success(true)
            }
        })
    }


    private fun getHomeList(result: Result) {
        ThingHomeSdk.getHomeManagerInstance().queryHomeList(object : IThingGetHomeListCallback {
            override fun onSuccess(homeBeans: MutableList<HomeBean>?) {
                val homes = arrayListOf<Map<String, Any>>()

                homeBeans?.forEach {

                    val item = mapOf<String, Any>(
                        "homeId" to it.homeId,
                        "name" to it.name,
                        "geoName" to it.geoName,
                        "latitude" to it.lat,
                        "longitude" to it.lon,
                        "backgroundUrl" to it.background,
                        "role" to it.role,
                        "dealStatus" to it.homeStatus,
                        "managementStatus" to it.managmentStatus(),
                        "nickName" to it.inviteName
                    )

                    homes.add(item)

                }
                result.success(homes)
            }

            override fun onError(code: String?, error: String?) {
                result.error(code!!, error, null)
            }
        })
    }

    private fun getHomeRooms(call: MethodCall, result: Result) {
        val homeId = call.argument<Int>("homeId")
        val home = ThingHomeSdk.newHomeInstance(homeId!!.toLong())
        home.queryRoomList(object : IThingGetRoomListCallback {
            override fun onSuccess(romeBeans: MutableList<RoomBean>?) {
                val rooms = arrayListOf<Map<String, Any>>()
                romeBeans?.forEach {
                    val room = mapOf(
                        "id" to it.roomId,
                        "name" to it.name
                    )

                    rooms.add(room)
                }
                result.success(rooms)
            }

            override fun onError(errorCode: String?, error: String?) {
                result.error(errorCode!!, error, null)
            }
        })
    }

    private fun addRoom(call: MethodCall, result: Result) {
        val homeId = call.argument<Int>("homeId")
        val roomName = call.argument<String>("roomName")
        ThingHomeSdk.newHomeInstance(homeId!!.toLong())
            .addRoom(roomName, object : IThingRoomResultCallback {
                override fun onSuccess(bean: RoomBean?) {
                    result.success(
                        mapOf(
                            "id" to bean!!.roomId,
                            "name" to bean.name
                        )
                    )
                }

                override fun onError(errorCode: String?, errorMsg: String?) {
                    result.error(errorCode!!, errorMsg, null)
                }
            })
    }

    private fun removeRoom(call: MethodCall, result: Result) {
        val homeId = call.argument<Int>("homeId")
        val roomId = call.argument<Int>("roomId")
        ThingHomeSdk.newHomeInstance(homeId!!.toLong())
            .removeRoom(roomId!!.toLong(), object : IResultCallback {
                override fun onError(code: String?, error: String?) {
                    result.error(code!!, error, null)
                }

                override fun onSuccess() {
                    result.success(true)
                }
            })
    }

    private fun updateRoom(call: MethodCall, result: Result) {

        val roomId = call.argument<Int>("roomId")
        val roomName = call.argument<String>("roomName")

        ThingHomeSdk.newRoomInstance(roomId!!.toLong())
            .updateRoom(roomName!!, object : IResultCallback {
                override fun onError(code: String?, error: String?) {
                    result.error(code!!, error, null)
                }

                override fun onSuccess() {
                    result.success(true)
                }
            })
    }


    private fun getHomeDevices(call: MethodCall, result: Result) {
        val homeId = call.argument<Int>("homeId")

        val home = ThingHomeSdk.newHomeInstance(homeId!!.toLong())

        home.getHomeDetail(object : IThingHomeResultCallback {
            override fun onSuccess(bean: HomeBean?) {
                val devices = arrayListOf<Map<String, Any?>>()

                bean?.deviceList?.forEach {

                    devices.add(modelToDict(it))
                }
                result.success(devices)
            }

            override fun onError(errorCode: String?, errorMsg: String?) {
                result.error(errorCode!!, errorMsg, null)
            }
        })
    }

    private fun modelToDict(deviceModel: DeviceBean): Map<String, Any?> {
        val roomId = ThingHomeSdk.getDataInstance().getDeviceRoomBean(deviceModel.devId)?.roomId

        val device = hashMapOf<String, Any?>()
        device["uiName"] = deviceModel.uiName
        device["devId"] = deviceModel.devId
        device["name"] = deviceModel.getName()
        device["iconUrl"] = deviceModel.getIconUrl()
        device["isOnline"] = deviceModel.isOnline
        device["isCloudOnline"] = deviceModel.isCloudOnline
        device["isLocalOnline"] = deviceModel.isLocalOnline
        device["isShare"] = deviceModel.getIsShare()
        device["dps"] = deviceModel.getDps()
        device["dpCodes"] = deviceModel.getDpCodes()
        device["productId"] = deviceModel.getProductId()
        device["supportGroup"] = deviceModel.isSupportGroup
        device["gwType"] = deviceModel.getGwType()
        device["pv"] = deviceModel.getPv()
        device["latitude"] = deviceModel.getLat()
        device["longitude"] = deviceModel.getLon()
        device["localKey"] = deviceModel.getLocalKey()
        device["uuid"] = deviceModel.getUuid()
//        device["homeId"] = deviceModel.hoem
        device["roomId"] = roomId ?: 0
        device["timezoneId"] = deviceModel.timezoneId
        device["nodeId"] = deviceModel.nodeId
        device["parentId"] = deviceModel.parentId
        device["devKey"] = deviceModel.devKey
        device["homeDisplayOrder"] = deviceModel.homeDisplayOrder
        device["sharedTime"] = deviceModel.sharedTime
        device["accessType"] = deviceModel.accessType
        device["schema"] = deviceModel.getSchema()
        device["category"] = deviceModel.productBean.category
        device["categoryCode"] = deviceModel.categoryCode
        device["cadv"] = deviceModel.cadv
        device["dpName"] = deviceModel.dpName
        device["productVer"] = deviceModel.getProductVer()
        device["uiId"] = deviceModel.getUi()


        return device
    }


    private fun getToken(call: MethodCall, result: Result) {
        val homeId = call.argument<Int>("homeId")
        ThingHomeSdk.getActivatorInstance()
            .getActivatorToken(homeId!!.toLong(), object : IThingActivatorGetToken {
                override fun onSuccess(token: String?) {
                    result.success(token)
                }

                override fun onFailure(code: String?, error: String?) {
                    result.error(code!!, error, null)
                }
            })

    }

    private fun getUserInfo(result: Result) {


        val info = hashMapOf<String, Any>()
        val user = ThingHomeSdk.getUserInstance().user
        if (user != null) {
            info["username"] = user.username
            info["country_code"] = user.phoneCode
            info["email"] = user.email
            info["ecode"] = user.ecode
            info["phone_number"] = user.mobile
            info["partner_identity"] = user.partnerIdentity
            info["nickname"] = user.nickName
            info["head_icon_url"] = user.headPic
            info["sid"] = user.sid
            info["is_login"] = true
            result.success(info)
        } else {
            result.error("User not found", "Usr not found", null)
        }

    }

    private fun logout(result: Result) {
        ThingHomeSdk.getUserInstance().logout(object : ILogoutCallback {
            override fun onSuccess() {
                result.success(true)
            }

            override fun onError(p0: String?, p1: String?) {
                result.success(false)
            }

        })
    }


    private fun updateUserNickName(call: MethodCall, result: Result) {
        val nickname = call.argument<String>("nickname")
        ThingHomeSdk.getUserInstance().updateNickName(nickname!!, object : IReNickNameCallback {
            override fun onSuccess() {
                result.success(true)
            }

            override fun onError(errorCode: String?, error: String?) {
                result.error(errorCode!!, error, null)
            }
        })
    }

    private fun updateUserIcon(call: MethodCall, result: Result) {
        val iconData = call.argument<String>("iconData")
        val imageBytes = Base64.decode(iconData, Base64.DEFAULT)
        val file = File.createTempFile("image", "png")
        file.writeBytes(imageBytes)
        ThingHomeSdk.getUserInstance().uploadUserAvatar(file, object : IBooleanCallback {
            override fun onSuccess() {
                result.success(true)
            }

            override fun onError(errorCode: String?, error: String?) {
                result.error(errorCode!!, error, null)
            }
        })
    }


    private fun assignDeviceToRoom(call: MethodCall, result: Result) {
        val roomId = call.argument<Int>("roomId")
        val deviceId = call.argument<String>("deviceId")

        ThingHomeSdk.newRoomInstance(roomId!!.toLong())
            .addDevice(deviceId!!, object : IResultCallback {
                override fun onError(errorCode: String?, error: String?) {
                    result.error(errorCode!!, error, null)
                }

                override fun onSuccess() {
                    result.success(true)
                }
            })
    }

    private fun removeDevice(call: MethodCall, result: Result) {
        val deviceId = call.argument<String>("deviceId")
        ThingHomeSdk.newDeviceInstance(deviceId!!).removeDevice(object : IResultCallback {
            override fun onError(errorCode: String?, error: String?) {
                result.error(errorCode!!, error, null)
            }

            override fun onSuccess() {
                result.success(true)
            }
        })
    }

    private fun renameDevice(call: MethodCall, result: Result) {
        val deviceId = call.argument<String>("deviceId")
        val name = call.argument<String>("name")
        ThingHomeSdk.newDeviceInstance(deviceId!!).renameDevice(name!!, object : IResultCallback {
            override fun onError(code: String?, error: String?) {
                result.error(code!!, error, null)
            }

            override fun onSuccess() {
                result.success(true)
            }
        })
    }

    private fun getDeviceRoom(call: MethodCall, result: Result) {
        val deviceId = call.argument<String>("deviceId")
        val room = ThingHomeSdk.getDataInstance().getDeviceRoomBean(deviceId)
        if (room != null) {
            result.success(
                mapOf<String, Any>(
                    "id" to room.roomId,
                    "name" to room.name
                )
            )
        } else {
            result.error("None", "Not Found", "")
        }

    }

    private fun discoverDevices(result: Result) {

        println("Tuya start scan")
        Log.i("Tuya", "Tuya start scan log")
        checkPermission()

        println("Tuya check permission $permissionGranted")
        if (permissionGranted) {
            println("Tuya Permission Granted")
            ThingHomeSdk.getBleOperator().stopLeScan()
            ThingHomeSdk.getBleOperator().startLeScan(9000, ScanType.SINGLE) { bean ->
                println("Tuya Ble ${bean.productId}")
                ThingHomeSdk.getActivatorInstance().getActivatorDeviceInfo(
                    bean.productId,
                    bean.uuid,
                    bean.mac,
                    object : IThingDataCallback<ConfigProductInfoBean> {
                        override fun onSuccess(info: ConfigProductInfoBean?) {
                            val device = hashMapOf<String, Any>()
                            device["productId"] = bean.productId
                            device["uuid"] = bean.uuid
                            device["name"] = info!!.name
                            device["iconUrl"] = info.icon
                            device["mac"] = bean.mac

                            deviceDiscoveryHandler.discoverySink?.success(device)

                        }

                        override fun onError(errorCode: String?, errorMessage: String?) {
                            println("Tuya error $errorMessage")
                            ThingHomeSdk.getBleOperator().stopLeScan()
                            result.error(errorCode ?: "", errorMessage, null)
                        }
                    }
                )


            }
            result.success(null)
        } else {
            result.error("Permission Denied", "Permission Denied", null)
        }

    }

    private fun getWifiSsid(result: Result) {
        val connectivityManager =
            mContext.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        val networkInfo = connectivityManager.activeNetworkInfo

        if (networkInfo != null && networkInfo.isConnected && networkInfo.type == ConnectivityManager.TYPE_WIFI) {
            val wifiManager = mContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
            val wifiInfo = wifiManager.connectionInfo
            val ssid = wifiInfo.ssid
            result.success(ssid.replace(Regex("^\"|\"\$"), ""))

        } else {
            result.error("Not connected", "Wifi is not connect", null)
        }

    }


    private fun requestHomeToken(call: MethodCall, result: Result) {
        val homeId = call.argument<Int>("homeId")
        ThingHomeSdk.getActivatorInstance().getActivatorToken(
            homeId!!.toLong(),
            object : IThingActivatorGetToken {
                override fun onSuccess(token: String) {
                    result.success(token)
                }

                override fun onFailure(code: String?, error: String?) {
                    result.error(code ?: "", error, null)
                }
            })
    }

    private fun startConfigBLEWifiDevice(call: MethodCall, result: Result) {
        val ssid = call.argument<String>("ssid")
        val password = call.argument<String>("password")

        val homeId = call.argument<Int>("homeId")
        val uuid = call.argument<String>("uuid")



        ThingHomeSdk.getActivatorInstance().getActivatorToken(
            homeId!!.toLong(),
            object : IThingActivatorGetToken {
                override fun onSuccess(token: String) {


                    // Start configuration -- Dual Ble Device
                    val param = mutableMapOf<String, String>()
                    param["ssid"] = ssid!!
                    param["password"] = password!!
                    param["token"] = token
                    ThingHomeSdk.getBleManager()
                        .startBleConfig(
                            homeId.toLong(), uuid, param as Map<String, String>,
                            object : IThingBleConfigListener {
                                override fun onSuccess(bean: DeviceBean?) {
                                    if (bean != null) {
                                        result.success(
                                            this@TuyaHomeSdkFlutterPlugin.modelToDict(
                                                bean
                                            )
                                        )
                                    } else {
                                        println("Tuya no connected")
                                        result.error("Bean i null", "Device not connected", null)
                                    }
                                }

                                override fun onFail(
                                    code: String?,
                                    msg: String?,
                                    handle: Any?
                                ) {
                                    println("Tuya on fail $code,$msg")
                                    result.error(code ?: "", msg, null)
                                }
                            })
                }

                override fun onFailure(errorCode: String?, errorMsg: String?) {
                    println("Tuya on onFailure $errorCode,$errorMsg")
                    result.error(errorCode ?: "", errorMsg, null)
                }
            })

    }

    private fun startConfigWiredDevice(call: MethodCall, result: Result) {
        val token = call.argument<String>("token")
        val timeout = call.argument<Int>("timeout")
        ThingHomeSdk.getActivatorInstance().newThingGwActivator().newSearcher()
            .registerGwSearchListener {
                ThingHomeSdk.getActivatorInstance().newGwActivator(
                    ThingGwActivatorBuilder()
                        .setToken(token)
                        .setTimeOut(timeout!!.toLong())
                        .setContext(mContext)
                        .setHgwBean(it)
                        .setListener(object : IThingSmartActivatorListener {
                            override fun onError(errorCode: String?, errorMsg: String?) {
                                result.error(errorCode ?: "", errorMsg, null)
                            }

                            override fun onActiveSuccess(bean: DeviceBean?) {
                                if (bean != null) {
                                    result.success(
                                        this@TuyaHomeSdkFlutterPlugin.modelToDict(
                                            bean
                                        )
                                    )
                                } else {
                                    println("Tuya no connected")
                                    result.error("Bean i null", "Device not connected", null)
                                }
                            }

                            override fun onStep(step: String?, data: Any?) {
                                println("Tuya onStep $step,$data")
                            }

                        })
                ).start()
            }


    }


    private fun startConfigSubDevice(call: MethodCall, result: Result) {
        val devId = call.argument<String>("devId")
        val timeout = call.argument<Int>("timeout")
        val builder = ThingGwSubDevActivatorBuilder()
            .setDevId(devId!!)
            .setTimeOut(timeout!!.toLong())
            .setListener(
                object : IThingSmartActivatorListener {
                    override fun onError(errorCode: String?, errorMsg: String?) {
                        result.error(errorCode ?: "", errorMsg, null)
                    }

                    override fun onActiveSuccess(bean: DeviceBean?) {
                        if (bean != null) {
                            result.success(
                                this@TuyaHomeSdkFlutterPlugin.modelToDict(
                                    bean
                                )
                            )
                        } else {
                            println("Tuya no connected")
                            result.error("Bean i null", "Device not connected", null)
                        }
                    }

                    override fun onStep(step: String?, data: Any?) {
                        println("Tuya onStep $step,$data")
                    }

                }
            )
        ThingHomeSdk.getActivatorInstance().newGwSubDevActivator(builder).start()

    }


    private fun startConfigWiFiDevice(call: MethodCall, result: Result) {
        val ssid = call.argument<String>("ssid")
        val password = call.argument<String>("password")
        val token = call.argument<String>("token")
        val timeout = call.argument<Int>("timeout")

        val builder = ActivatorBuilder()
            .setSsid(ssid)
            .setContext(mContext)
            .setPassword(password)
            .setToken(token)
            .setActivatorModel(ActivatorModelEnum.THING_AP)
            .setTimeOut(timeout?.toLong() ?: 3000)
            .setListener(object : IThingSmartActivatorListener {
                override fun onError(errorCode: String?, errorMsg: String?) {
                    result.error(errorCode ?: "", errorMsg, null)
                }

                override fun onActiveSuccess(bean: DeviceBean?) {
                    if (bean != null) {
                        result.success(
                            this@TuyaHomeSdkFlutterPlugin.modelToDict(
                                bean
                            )
                        )
                    } else {
                        println("Tuya no connected")
                        result.error("Bean i null", "Device not connected", null)
                    }
                }

                override fun onStep(step: String?, data: Any?) {
                    println("Tuya onStep $step,$data")
                }
            })

        ThingHomeSdk.getActivatorInstance().newActivator(builder).start()
    }


    private fun publishDps(call: MethodCall, result: Result) {
        val deviceId = call.argument<String>("deviceId")
        val dps = call.argument<Map<String, Any>>("dps")
        this.device = ThingHomeSdk.newDeviceInstance(deviceId!!)
        val dp: String = JSON.toJSONString(dps)
        device!!.publishDps(dp, object : IResultCallback {
            override fun onError(errorCode: String?, error: String?) {
                result.error(errorCode!!, error, null)
            }

            override fun onSuccess() {
                result.success(true)
            }
        })
    }

    private val deviceListener = object : IDevListener {
        override fun onDpUpdate(devId: String?, dpStr: String?) {

            eventSink?.success(JSON.parse(dpStr))
        }


        override fun onRemoved(devId: String?) {

        }

        override fun onStatusChanged(devId: String?, online: Boolean) {

        }

        override fun onNetworkStatusChanged(devId: String?, status: Boolean) {

        }

        override fun onDevInfoUpdate(devId: String?) {

        }
    }


    private fun listenForDevice(call: MethodCall, result: Result) {
        val deviceId = call.argument<String>("deviceId")

        device = ThingHomeSdk.newDeviceInstance(deviceId!!)
        device?.registerDevListener(deviceListener)

        result.success(true)
    }


    /// Private Helper methods
    private fun checkPermission() {
        if (ContextCompat.checkSelfPermission(
                this.mContext,
                Manifest.permission.ACCESS_COARSE_LOCATION
            ) != PackageManager.PERMISSION_GRANTED
            || ContextCompat.checkSelfPermission(
                this.mContext,
                Manifest.permission.ACCESS_FINE_LOCATION
            ) != PackageManager.PERMISSION_GRANTED
            || ContextCompat.checkSelfPermission(
                this.mContext,
                Manifest.permission.BLUETOOTH_ADMIN
            ) != PackageManager.PERMISSION_GRANTED
            || ContextCompat.checkSelfPermission(
                this.mContext,
                Manifest.permission.BLUETOOTH
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            permissionGranted = false
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                ActivityCompat.requestPermissions(
                    mActivity!!,
                    arrayOf(
                        Manifest.permission.ACCESS_COARSE_LOCATION,
                        Manifest.permission.ACCESS_FINE_LOCATION,
                        Manifest.permission.BLUETOOTH_SCAN,
                        Manifest.permission.BLUETOOTH_CONNECT,
                        Manifest.permission.BLUETOOTH,
                        Manifest.permission.BLUETOOTH_ADMIN,

                        ),
                    1001
                )
            } else {
                ActivityCompat.requestPermissions(
                    mActivity!!,
                    arrayOf(
                        Manifest.permission.ACCESS_COARSE_LOCATION,
                        Manifest.permission.ACCESS_FINE_LOCATION,
                        Manifest.permission.BLUETOOTH,
                        Manifest.permission.BLUETOOTH_ADMIN,

                        ),
                    1001
                )
            }
        } else {
            permissionGranted = true
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ): Boolean {

        if (requestCode == 1001) {
            permissionGranted = grantResults.isNotEmpty() &&
                    grantResults[0] == PackageManager.PERMISSION_GRANTED
            return permissionGranted
        }

        return false
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        mActivity = binding.activity
        binding.addRequestPermissionsResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        mActivity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        mActivity = binding.activity
        binding.addRequestPermissionsResultListener(this)
    }

    override fun onDetachedFromActivity() {
        mActivity = null
    }

    override fun onListen(arguments: Any?, events: EventSink?) {
        this.eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        this.eventSink = null
        this.device?.unRegisterDevListener()
    }


    /* / Scene Management */


    private fun getSceneList(call: MethodCall, callBack: Result) {
        val homeId = call.argument<Int>("homeId")
        ThingHomeSdk.getSceneServiceInstance().baseService().getSimpleSceneAll(
            homeId!!.toLong(),
            object : com.thingclips.smart.scene.api.IResultCallback<List<NormalScene>?> {
                override fun onError(errorCode: String?, errorMessage: String?) {
                    callBack.error(errorCode ?: "", errorMessage, null)

                }

                override fun onSuccess(result: List<NormalScene>?) {
                    val scenes = arrayListOf<Map<String, Any?>>()
                    result?.forEach {
                        val item = hashMapOf<String, Any?>(
                            "id" to it.id,
                            "name" to it.name,
                            "gwId" to it.gwId,
                            "coverIcon" to it.coverIcon,
                            "displayColor" to it.displayColor,
                            "background" to it.background,
                            "isEnabled" to it.isEnabled,
                            "isStickyOnTop" to it.isStickyOnTop,
                            "isNewLocalScene" to it.isNewLocalScene,
                            "isLocalLinkage" to it.isLocalLinkage,
                            "linkageType" to it.linkageType,
                            "ruleGenre" to it.ruleGenre,
                            "arrowIconUrl" to it.arrowIconUrl,
                            "outOfWork" to it.outOfWork,
                            "conditions" to it.conditions?.map { it1 ->
                                hashMapOf(
                                    "entityType" to it1.entityType,
                                    "entityId" to it1.entityId,
                                    "expr" to it1.expr,
                                    "id" to it1.id,
                                    "entityName" to it1.entityName,
                                    "exprDisplay" to it1.exprDisplay,
                                    "condType" to it1.condType,
                                    "extraInfo" to JSON.toJSON(it1.extraInfo),

                                    )
                            }?.let { it2 -> ArrayList(it2) },
                            "actions" to it.actions?.map { it1 ->
                                hashMapOf(
                                    "id" to it1.id,
                                    "entityName" to it1.entityName,
                                    "pid" to it1.pid,
                                    "productId" to it1.productId,
                                    "actionDisplay" to it1.actionDisplay,
                                    "entityId" to it1.entityId,
                                    "productPic" to it1.productPic,
                                    "uiid" to it1.uiid,
                                    "executorProperty" to it1.executorProperty,

                                    )
                            }?.let { it2 -> ArrayList(it2) },
                            "statusConditions" to it.statusConditions?.map { it1 ->
                                hashMapOf(
                                    "entityType" to it1.entityType,
                                    "entityId" to it1.entityId,
                                    "expr" to it1.expr,
                                    "id" to it1.id,
                                    "entityName" to it1.entityName,
                                    "exprDisplay" to it1.exprDisplay,
                                    "condType" to it1.condType,
                                    "extraInfo" to if (it1.extraInfo != null) hashMapOf(
                                        "cityName" to it1.extraInfo?.cityName,
                                        "dpScale" to it1.extraInfo?.dpScale,
                                        "calType" to it1.extraInfo?.calType,
                                        "maxSeconds" to it1.extraInfo?.maxSeconds,
                                    ) else null,
                                )
                            },
                            "matchType" to it.matchType,
                            "categorys" to it.categorys,
                            "panelType" to it.panelType,

                            )
                        scenes.add(item)
                    }
                    callBack.success(scenes)
                }
            })

    }

    private fun fetchSceneDetail(call: MethodCall, callBack: Result) {
        val sceneId = call.argument<String>("sceneId")
        val homeId = call.argument<Int>("homeId")
        val supportHome = call.argument<Boolean>("supportHome")
        val ruleGenre = call.argument<Int>("ruleGenre")

        ThingHomeSdk.getSceneServiceInstance().baseService().getSceneDetailV1(
            homeId!!.toLong(),
            sceneId!!,
            ruleGenre,
            supportHome!!,
            object : com.thingclips.smart.scene.api.IResultCallback<NormalScene?> {
                override fun onError(errorCode: String?, errorMessage: String?) {
                    callBack.error(errorCode ?: "", errorMessage, null)
                }

                override fun onSuccess(result: NormalScene?) {

                    val item = hashMapOf<String, Any?>(
                        "id" to result!!.id,
                        "name" to result.name,
                        "gwId" to result.gwId,
                        "coverIcon" to result.coverIcon,
                        "background" to result.background,
                        "displayColor" to result.displayColor,
                        "isEnabled" to result.isEnabled,
                        "isStickyOnTop" to result.isStickyOnTop,
                        "isNewLocalScene" to result.isNewLocalScene,
                        "isLocalLinkage" to result.isLocalLinkage,
                        "linkageType" to result.linkageType,
                        "ruleGenre" to result.ruleGenre,
                        "arrowIconUrl" to result.arrowIconUrl,
                        "outOfWork" to result.outOfWork,
                        "conditions" to result.conditions?.map { it1 ->
                            hashMapOf(
                                "entityType" to it1.entityType,
                                "entityId" to it1.entityId,
                                "expr" to it1.expr,
                                "id" to it1.id,
                                "entityName" to it1.entityName,
                                "exprDisplay" to it1.exprDisplay,
                                "condType" to it1.condType,
                                "extraInfo" to JSON.toJSON(it1.extraInfo),

                                )
                        }?.let { it2 -> ArrayList(it2) },
                        "actions" to result.actions?.map { it1 ->
                            hashMapOf(
                                "id" to it1.id,
                                "entityName" to it1.entityName,
                                "pid" to it1.pid,
                                "productId" to it1.productId,
                                "actionDisplay" to it1.actionDisplay,
                                "entityId" to it1.entityId,
                                "productPic" to it1.productPic,
                                "uiid" to it1.uiid,
                                "executorProperty" to it1.executorProperty,

                                )
                        }?.let { it2 -> ArrayList(it2) },
                        "statusConditions" to result.statusConditions?.map { it1 ->
                            hashMapOf(
                                "entityType" to it1.entityType,
                                "entityId" to it1.entityId,
                                "expr" to it1.expr,
                                "id" to it1.id,
                                "entityName" to it1.entityName,
                                "exprDisplay" to it1.exprDisplay,
                                "condType" to it1.condType,
                                "extraInfo" to if (it1.extraInfo != null) hashMapOf(
                                    "cityName" to it1.extraInfo?.cityName,
                                    "dpScale" to it1.extraInfo?.dpScale,
                                    "calType" to it1.extraInfo?.calType,
                                    "maxSeconds" to it1.extraInfo?.maxSeconds,
                                ) else null,
                            )
                        },
                        "matchType" to result.matchType,
                        "categorys" to result.categorys,
                        "panelType" to result.panelType,

                        )
                    callBack.success(item)
                }
            })
    }

    private suspend fun getConditionDeviceDp(dev: String): List<DeviceConditionData> =
        suspendCoroutine { cont ->
            ThingHomeSdk.getSceneServiceInstance().deviceService().getConditionDeviceDpAll(
                dev,
                object :
                    com.thingclips.smart.scene.api.IResultCallback<List<ConditionItemDetail>?> {
                    override fun onError(errorCode: String?, errorMessage: String?) {
                        cont.resumeWith(kotlin.Result.success(emptyList()))
                    }

                    override fun onSuccess(result: List<ConditionItemDetail>?) {
                        val data = result?.map { it.mapToDeviceConditionData(dev) } ?: emptyList()
                        cont.resumeWith(kotlin.Result.success(data))
                    }
                }
            )
        }


    private fun addScene(call: MethodCall, callBack: Result) {
        val arguments = call.arguments as Map<*, *>

        val jsonString = JSON.toJSONString(arguments)

        val factory = JSON.parseObject(jsonString, ThingSmartSceneFactory::class.java)

        val dpCache: HashMap<String, List<DeviceConditionData>> = hashMapOf()

        CoroutineScope(Dispatchers.Main).launch {
            factory.conditions?.forEach {
                if (it.deviceId != null) {
                    dpCache[it.deviceId!!] = getConditionDeviceDp(it.deviceId!!)
                }
            }


            val scene = NormalScene().apply {
                name = factory.name
                matchType = factory.matchType ?: 1
                isStickyOnTop = factory.showFirstPage!!
                actions = factory.actions?.map { it.toTuyaModel() }
                preConditions = factory.preConditions?.map { it.toThingModel() }
                conditions =
                    factory.conditions?.map { it.toThingModel { deviceId, dpModelId -> dpCache[deviceId]!!.first { dp -> dp.datapointId == dpModelId.toLong() } } }

            }


            ThingHomeSdk.getSceneServiceInstance().baseService().saveScene(
                factory.homeId.toLong(),
                scene,
                object : com.thingclips.smart.scene.api.IResultCallback<NormalScene?> {
                    override fun onError(errorCode: String?, errorMessage: String?) {
                        callBack.error(errorCode ?: "", errorMessage, null)
                    }

                    override fun onSuccess(result: NormalScene?) {
                        val item = hashMapOf<String, Any?>(
                            "id" to result!!.id,
                            "name" to result.name,
                            "gwId" to result.gwId,
                            "coverIcon" to result.coverIcon,
                            "displayColor" to result.displayColor,
                            "background" to result.background,
                            "isEnabled" to result.isEnabled,
                            "isStickyOnTop" to result.isStickyOnTop,
                            "isNewLocalScene" to result.isNewLocalScene,
                            "isLocalLinkage" to result.isLocalLinkage,
                            "linkageType" to result.linkageType,
                            "ruleGenre" to result.ruleGenre,
                            "arrowIconUrl" to result.arrowIconUrl,
                            "outOfWork" to result.outOfWork,
                            "conditions" to result.conditions?.map { it1 ->
                                hashMapOf(
                                    "entityType" to it1.entityType,
                                    "entityId" to it1.entityId,
                                    "expr" to it1.expr,
                                    "id" to it1.id,
                                    "entityName" to it1.entityName,
                                    "exprDisplay" to it1.exprDisplay,
                                    "condType" to it1.condType,
                                    "extraInfo" to JSON.toJSON(it1.extraInfo),

                                    )
                            }?.let { it2 -> ArrayList(it2) },
                            "actions" to result.actions?.map { it1 ->
                                hashMapOf(
                                    "id" to it1.id,
                                    "entityName" to it1.entityName,
                                    "pid" to it1.pid,
                                    "productId" to it1.productId,
                                    "actionDisplay" to it1.actionDisplay,
                                    "entityId" to it1.entityId,
                                    "productPic" to it1.productPic,
                                    "uiid" to it1.uiid,
                                    "executorProperty" to it1.executorProperty,

                                    )
                            }?.let { it2 -> ArrayList(it2) },
                            "statusConditions" to result.statusConditions?.map { it1 ->
                                hashMapOf(
                                    "entityType" to it1.entityType,
                                    "entityId" to it1.entityId,
                                    "expr" to it1.expr,
                                    "id" to it1.id,
                                    "entityName" to it1.entityName,
                                    "exprDisplay" to it1.exprDisplay,
                                    "condType" to it1.condType,
                                    "extraInfo" to if (it1.extraInfo != null) hashMapOf(
                                        "cityName" to it1.extraInfo?.cityName,
                                        "dpScale" to it1.extraInfo?.dpScale,
                                        "calType" to it1.extraInfo?.calType,
                                        "maxSeconds" to it1.extraInfo?.maxSeconds,
                                    ) else null,
                                )
                            },
                            "matchType" to result.matchType,
                            "categorys" to result.categorys,
                            "panelType" to result.panelType,
                        )
                        callBack.success(item)
                    }
                })


        }

    }


    private fun editScene(call: MethodCall, callBack: Result) {
        val arguments = call.arguments as Map<*, *>

        val jsonString = JSON.toJSONString(arguments)

        val factory = JSON.parseObject(jsonString, ThingSmartSceneFactory::class.java)

        val dpCache: HashMap<String, List<DeviceConditionData>> = hashMapOf()

        CoroutineScope(Dispatchers.Main).launch {
            factory.conditions?.forEach {
                if (it.deviceId != null) {
                    dpCache[it.deviceId!!] = getConditionDeviceDp(it.deviceId!!)
                }
            }
            val scene = NormalScene()

            if (!factory.name.isNullOrEmpty()) {
                scene.name = factory.name
            }
            if (factory.matchType != null) {
                scene.matchType = factory.matchType!!
            }
            if (factory.showFirstPage != null) {
                scene.isStickyOnTop = factory.showFirstPage!!
            }
            if (factory.actions != null) {
                scene.actions = factory.actions?.map { it.toTuyaModel() }
            }
            if (factory.preConditions != null) {
                scene.preConditions = factory.preConditions?.map { it.toThingModel() }
            }
            if (factory.conditions != null) {
                scene.conditions =
                    factory.conditions?.map { it.toThingModel { deviceId, dpModelId -> dpCache[deviceId]!!.first { dp -> dp.datapointId == dpModelId.toLong() } } }
            }



            ThingHomeSdk.getSceneServiceInstance().baseService().modifyScene(
                factory.id!!,
                scene,
                object : com.thingclips.smart.scene.api.IResultCallback<NormalScene?> {
                    override fun onError(errorCode: String?, errorMessage: String?) {
                        callBack.error(errorCode ?: "", errorMessage, null)
                    }

                    override fun onSuccess(result: NormalScene?) {
                        val item = hashMapOf<String, Any?>(
                            "id" to result!!.id,
                            "name" to result.name,
                            "gwId" to result.gwId,
                            "coverIcon" to result.coverIcon,
                            "displayColor" to result.displayColor,
                            "background" to result.background,
                            "isEnabled" to result.isEnabled,
                            "isStickyOnTop" to result.isStickyOnTop,
                            "isNewLocalScene" to result.isNewLocalScene,
                            "isLocalLinkage" to result.isLocalLinkage,
                            "linkageType" to result.linkageType,
                            "ruleGenre" to result.ruleGenre,
                            "arrowIconUrl" to result.arrowIconUrl,
                            "outOfWork" to result.outOfWork,
                            "conditions" to result.conditions?.map { it1 ->
                                hashMapOf(
                                    "entityType" to it1.entityType,
                                    "entityId" to it1.entityId,
                                    "expr" to it1.expr,
                                    "id" to it1.id,
                                    "entityName" to it1.entityName,
                                    "exprDisplay" to it1.exprDisplay,
                                    "condType" to it1.condType,
                                    "extraInfo" to JSON.toJSON(it1.extraInfo),

                                    )
                            }?.let { it2 -> ArrayList(it2) },
                            "actions" to result.actions?.map { it1 ->
                                hashMapOf(
                                    "id" to it1.id,
                                    "entityName" to it1.entityName,
                                    "pid" to it1.pid,
                                    "productId" to it1.productId,
                                    "actionDisplay" to it1.actionDisplay,
                                    "entityId" to it1.entityId,
                                    "productPic" to it1.productPic,
                                    "uiid" to it1.uiid,
                                    "executorProperty" to it1.executorProperty,

                                    )
                            }?.let { it2 -> ArrayList(it2) },
                            "statusConditions" to result.statusConditions?.map { it1 ->
                                hashMapOf(
                                    "entityType" to it1.entityType,
                                    "entityId" to it1.entityId,
                                    "expr" to it1.expr,
                                    "id" to it1.id,
                                    "entityName" to it1.entityName,
                                    "exprDisplay" to it1.exprDisplay,
                                    "condType" to it1.condType,
                                    "extraInfo" to if (it1.extraInfo != null) hashMapOf(
                                        "cityName" to it1.extraInfo?.cityName,
                                        "dpScale" to it1.extraInfo?.dpScale,
                                        "calType" to it1.extraInfo?.calType,
                                        "maxSeconds" to it1.extraInfo?.maxSeconds,
                                    ) else null,
                                )
                            },
                            "matchType" to result.matchType,
                            "categorys" to result.categorys,
                            "panelType" to result.panelType,
                        )
                        callBack.success(item)
                    }
                })


        }

    }


    private fun removeScene(call: MethodCall, callBack: Result) {
        val homeId = call.argument<Int>("homeId")
        val sceneId = call.argument<String>("sceneId")
        ThingHomeSdk.getSceneServiceInstance().baseService().deleteSceneWithHomeId(
            homeId!!.toLong(),
            sceneId!!,
            object : com.thingclips.smart.scene.api.IResultCallback<Boolean> {
                override fun onError(errorCode: String?, errorMessage: String?) {
                    callBack.error(errorCode ?: "", errorMessage, null)
                }

                override fun onSuccess(result: Boolean) {
                    callBack.success(result)
                }
            })
    }

    private fun runScene(call: MethodCall, callBack: Result) {
        val sceneId = call.argument<String>("sceneId")
        val scene = NormalScene().apply {
            this.id = sceneId!!
        }

        ThingHomeSdk.getSceneServiceInstance().executeService()
            .executeScene(scene, object : IResultCallback {
                override fun onError(code: String?, error: String?) {
                    callBack.error(code ?: "", error, null)
                }

                override fun onSuccess() {
                    callBack.success(true)
                }
            })
    }

    private fun changeAutomation(call: MethodCall, callBack: Result) {
        val sceneId = call.argument<String>("sceneId")
        val status = call.argument<Boolean>("status") ?: false
        if (status) {
            ThingHomeSdk.getSceneServiceInstance().baseService().enableAutomation(
                sceneId!!,
                object : com.thingclips.smart.scene.api.IResultCallback<Boolean> {
                    override fun onError(errorCode: String?, errorMessage: String?) {
                        callBack.error(errorCode ?: "", errorMessage, null)
                    }

                    override fun onSuccess(result: Boolean) {
                        callBack.success(result)
                    }
                })
        } else {
            ThingHomeSdk.getSceneServiceInstance().baseService().disableAutomation(
                sceneId!!,
                object : com.thingclips.smart.scene.api.IResultCallback<Boolean> {
                    override fun onError(errorCode: String?, errorMessage: String?) {
                        callBack.error(errorCode ?: "", errorMessage, null)
                    }

                    override fun onSuccess(result: Boolean) {
                        callBack.success(result)
                    }
                })
        }

    }

    private fun addMember(call: MethodCall, callBack: Result) {
        val homeId = call.argument<Int>("homeId")

        val name = call.argument<String>("name")
        val autoAccept = call.argument<Boolean>("autoAccept")
        val countryCode = call.argument<String?>("countryCode")
        val account = call.argument<String?>("account")
        val role = call.argument<Int>("role")
        val wrapper = MemberWrapperBean.Builder()
            .setHomeId(homeId!!.toLong())
            .setNickName(name)
            .setAutoAccept(autoAccept!!)
            .setRole(role!!)

        if (countryCode != null) {
            wrapper.setCountryCode(countryCode)
        }
        if (account != null) {
            wrapper.setAccount(account)
        }

        ThingHomeSdk.getMemberInstance()
            .addMember(wrapper.build(), object : IThingDataCallback<MemberBean> {
                override fun onSuccess(result: MemberBean?) {
                    callBack.success(result?.memberId.toString())
                }

                override fun onError(errorCode: String?, errorMessage: String?) {
                    callBack.error(errorCode ?: "", errorMessage, null)
                }
            })
    }

    private fun queryMemberList(call: MethodCall, result: Result) {
        val homeId = call.argument<Int>("homeId")
        ThingHomeSdk.getMemberInstance()
            .queryMemberList(homeId!!.toLong(), object : IThingGetMemberListCallback {
                override fun onSuccess(memberBeans: MutableList<MemberBean>?) {
                    val data: ArrayList<HashMap<String, Any>> = arrayListOf()
                    memberBeans!!.forEach {
                        val item = hashMapOf<String, Any>()
                        item["memberId"] = it.memberId
                        item["name"] = it.nickName
                        item["homeId"] = it.homeId
                        item["role"] = it.role
                        item["mobile"] = ""
                        item["userName"] = it.account
                        item["uid"] = it.uid ?: ""
                        item["memberStatus"] = it.memberStatus
                        data.add(item)
                    }
                    result.success(data)

                }

                override fun onError(errorCode: String?, error: String?) {
                    result.error(errorCode ?: "", error, null)
                }
            })
    }

    private fun removeMember(call: MethodCall, result: Result) {
        val memberId = call.argument<Int>("memberId")
        ThingHomeSdk.getMemberInstance()
            .removeMember(memberId!!.toLong(), object : IResultCallback {
                override fun onError(code: String?, error: String?) {
                    result.error(code ?: "", error, null)
                }

                override fun onSuccess() {
                    result.success(true)
                }
            })
    }

    private fun modifyMember(call: MethodCall, result: Result) {
        val name = call.argument<String?>("name")
        val role = call.argument<Int?>("role")
        val memberId = call.argument<Int>("memberId")
        val wrapper = MemberWrapperBean.Builder()
            .setMemberId(memberId!!.toLong())


        if (name != null) {
            wrapper.setNickName(name)
        }
        if (role != null) {
            wrapper.setRole(role)
        }
        ThingHomeSdk.getMemberInstance().updateMember(wrapper.build(), object : IResultCallback {
            override fun onError(code: String?, error: String?) {
                result.error(code ?: "", error, null)
            }

            override fun onSuccess() {
                result.success(true)
            }
        })
    }

    private fun joinHome(call: MethodCall, result: Result) {
        val code = call.argument<String>("code")
        ThingHomeSdk.getHomeManagerInstance()
            .joinHomeByInviteCode(code!!, object : IResultCallback {
                override fun onError(code: String?, error: String?) {
                    result.error(code ?: "", error, null)
                }

                override fun onSuccess() {
                    result.success(true)
                }
            })
    }

    private fun cancelInvitation(call: MethodCall, result: Result) {
        val invitationID = call.argument<Int>("invitationID")
        ThingHomeSdk.getMemberInstance()
            .cancelMemberInvitationCode(invitationID!!.toLong(), object : IResultCallback {
                override fun onError(code: String?, error: String?) {
                    result.error(code ?: "", error, null)
                }

                override fun onSuccess() {
                    result.success(true)
                }
            })

    }

    private fun acceptOrRejectInvitation(call: MethodCall, result: Result) {
        val homeId = call.argument<Int>("homeId")
        val accept = call.argument<Boolean>("accept")
        ThingHomeSdk.getMemberInstance()
            .processInvitation(homeId!!.toLong(), accept!!, object : IResultCallback {
                override fun onError(code: String?, error: String?) {
                    result.error(code ?: "", error, null)
                }

                override fun onSuccess() {
                    result.success(true)
                }
            })

    }

    private fun queryInvitations(call: MethodCall, callBack: Result) {
        val homeId = call.argument<Int>("homeId")
        ThingHomeSdk.getMemberInstance()
            .getInvitationList(
                homeId!!.toLong(),
                object : IThingDataCallback<List<InviteListResponseBean>> {
                    override fun onSuccess(result: List<InviteListResponseBean>) {
                        val data: ArrayList<HashMap<String, Any>> = arrayListOf()
                        result.forEach {
                            val item = hashMapOf<String, Any>()
                            item["invitationID"] = it.invitationId
                            item["invitationCode"] = it.invitationCode
                            item["name"] = it.name
                            item["role"] = it.role
                            item["dealStatus"] = it.dealStatus
                            item["validTime"] = it.validTime
                            data.add(item)
                        }
                        callBack.success(data)
                    }


                    override fun onError(errorCode: String, error: String) {
                        callBack.error(errorCode ?: "", error, null)
                    }
                })

    }

    private fun modifyInvitation(call: MethodCall, result: Result) {
        val invitationId = call.argument<Int>("invitationId")
        val name = call.argument<String>("name")
        val role = call.argument<Int>("role")
        ThingHomeSdk.getMemberInstance()
            .updateInvitedMember(invitationId!!.toLong(), name, role!!, object : IResultCallback {
                override fun onError(code: String?, error: String?) {
                    result.error(code ?: "", error, null)
                }

                override fun onSuccess() {
                    result.success(true)
                }
            })
    }

}
