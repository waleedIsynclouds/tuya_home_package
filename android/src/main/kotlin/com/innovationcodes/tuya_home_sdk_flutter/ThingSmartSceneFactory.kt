package com.innovationcodes.tuya_home_sdk_flutter

import com.thingclips.scene.core.bean.ConditionBase
import com.thingclips.scene.core.enumerate.ActionExecutor
import com.thingclips.scene.core.enumerate.ConditionEntityType
import com.thingclips.scene.core.protocol.b.usualimpl.DeviceConditionBuilder
import com.thingclips.scene.core.protocol.b.usualimpl.GeofenceConditionBuilder
import com.thingclips.scene.core.protocol.b.usualimpl.SunRiseSetConditionBuilder
import com.thingclips.scene.core.protocol.b.usualimpl.TimingConditionBuilder
import com.thingclips.scene.core.protocol.b.usualimpl.WeatherConditionBuilder
import com.thingclips.scene.core.protocol.expr.usualimpl.SunSetRiseRule
import com.thingclips.smart.scene.model.action.SceneAction
import com.thingclips.smart.scene.model.condition.SceneCondition
import com.thingclips.smart.scene.model.constant.CONDITION_TYPE_DEVICE
import com.thingclips.smart.scene.model.constant.CONDITION_TYPE_MANUAL
import com.thingclips.smart.scene.model.constant.CONDITION_TYPE_PIR
import com.thingclips.smart.scene.model.constant.CONDITION_TYPE_WEATHER
import com.thingclips.smart.scene.model.constant.GeofencingType
import com.thingclips.smart.scene.model.constant.TimeInterval
import com.thingclips.smart.scene.model.constant.WeatherType
import com.thingclips.smart.scene.model.device.DeviceConditionData
import com.thingclips.smart.scene.model.edit.PreCondition
import com.thingclips.smart.scene.model.edit.PreConditionExpr


class ThingSmartSceneFactory() {
    var id :String?=null
    var homeId: Int = 0
    var name: String? = null
    var showFirstPage: Boolean? = null
    var matchType: Int? = null
    var actions: List<SceneActionModel>? = null
    var preConditions: List<ScenePreCondition>? = null
    var conditions: List<SceneConditionDTO>? = null
}

enum class SceneActionKind {
    deviceDp, groupDp, triggerScene, switchAutomation, delay, sendNotification, call, sms,
}

enum class SceneExprKind {
    boolValue, enumValue, compareValue, raw, timer, sunTimer, geofence, calculate, memberBackHome
}


enum class ScenePreConditionKind {
    allDay, daytime, night, customTime
}

class SceneActionModel() {
    var kind: SceneActionKind = SceneActionKind.deviceDp
    var devId: String? = null
    var devName: String? = null
    var groupId: String? = null
    var groupName: String? = null
    var sceneId: String? = null
    var sceneName: String? = null
    var executerProperty: Map<String, Any>? = null
    var extraProperty: Map<String, Any>? = null
    var autoSwitchType: Int? = null
    var delayHours: String? = null
    var delayMinutes: String? = null
    var delaySeconds: String? = null
    fun toTuyaModel(): SceneAction {

        return when (kind) {
            SceneActionKind.deviceDp -> SceneAction().apply {
                actionExecutor = ActionExecutor.DP_ISSUE.actualName
                entityId = devId
                entityName = devName
                this.executorProperty = this@SceneActionModel.executerProperty
                this.extraProperty = this@SceneActionModel.extraProperty
            }

            SceneActionKind.groupDp -> SceneAction().apply {
                actionExecutor = ActionExecutor.DEVICE_GROUP_DP_ISSUE.actualName
                entityId = groupId
                entityName = groupName
                this.executorProperty = this@SceneActionModel.executerProperty
                this.extraProperty = this@SceneActionModel.extraProperty
            }

            SceneActionKind.triggerScene -> SceneAction().apply {
                actionExecutor = ActionExecutor.RULE_TRIGGER.actualName
                entityId = sceneId
                entityName = sceneName
            }

            SceneActionKind.switchAutomation -> SceneAction().apply {
                actionExecutor = ActionExecutor.TOGGLE.actualName
                entityId = sceneId
                entityName = sceneName

                this.executorProperty = mapOf("switch" to autoSwitchType)
            }

            SceneActionKind.delay -> SceneAction().apply {
                actionExecutor = ActionExecutor.DELAY.actualName
                this.executorProperty = mapOf(
                    "hours" to delayHours, "minutes" to delayMinutes, "seconds" to delaySeconds
                )
            }

            SceneActionKind.sendNotification -> SceneAction().apply {
                actionExecutor = ActionExecutor.APP_PUSH_TRIGGER.actualName
            }

            SceneActionKind.call -> SceneAction().apply {
                actionExecutor = ActionExecutor.MOBILE_VOICE_SEND.actualName
            }

            SceneActionKind.sms -> SceneAction().apply {
                actionExecutor = ActionExecutor.SMS_SEND.actualName
            }
        }
    }
}

class ScenePreCondition() {
    var kind: ScenePreConditionKind = ScenePreConditionKind.allDay
    var sceneId: String? = null
    var conditionId: String? = null
    var loops: String = "1"
    var timeZoneId: String = ""
    var cityId: String? = null
    var cityName: String? = null
    var beginTime: String? = null
    var endTime: String? = null
    fun toThingModel(): PreCondition {

        return PreCondition().apply {
            id = conditionId
            condType = PreCondition.TYPE_TIME_CHECK
            expr = PreConditionExpr().apply {
                timeZoneId = this@ScenePreCondition.timeZoneId
                cityId = this@ScenePreCondition.cityId
                cityName = this@ScenePreCondition.cityName
                loops = this@ScenePreCondition.loops
                start = this@ScenePreCondition.beginTime
                end = this@ScenePreCondition.endTime
                timeInterval = when (kind) {
                    ScenePreConditionKind.allDay -> TimeInterval.TIME_INTERVAL_DAY.value
                    ScenePreConditionKind.night -> TimeInterval.TIME_INTERVAL_NIGHT.value
                    ScenePreConditionKind.daytime -> TimeInterval.TIME_INTERVAL_DAY.value
                    ScenePreConditionKind.customTime -> TimeInterval.TIME_INTERVAL_CUSTOM.value
                }
            }
        }


    }
}

data class CityDTO @JvmOverloads constructor(
    var cityId: Long = 0,
    var city: String = "",
    var area: String? = null,
    var pinyin: String? = null,
    var province: String? = null,
    var latitude: Double? = null,
    var longitude: Double? = null
) {


}

class SceneExprDTO() {

    // Basic discriminator
    var kind: SceneExprKind? = null

    // Common
    var type: String? = null
    var exprType: Int? = null
    var isTrue: Boolean? = null
    var chooseValue: Any? = null
    var compareOperator: String? = null


    // Timer
    var timeZoneId: String? = null
    var loops: String? = null
    var date: String? = null
    var time: String? = null

    // Sun timer
    var city: CityDTO? = null
    var sunType: Int? = null
    var deltaMinutes: Int? = null

    // Geofence
    var geoFenceType: Int? = null

    // Calculate
    var dpId: String? = null
    var dpType: String? = null
    var selectedValue: Any? = null

    // Member back home
    var memberIds: String? = null
}


class SceneConditionDTO(


) {
    enum class Kind {
        device, pir, weather, timer, sunTimer, geoFence, manual, calculateDuration, memberBackHome
    }

    var kind: Kind? = null

    // Device + dp
    var deviceId: String? = null
    var dpModelId: Int? = null

    // Nested expr
    var expr: SceneExprDTO? = null

    // City
    var city: CityDTO? = null

    // Geo
    var geoType: Int? = null
    var latitude: Double? = null
    var longitude: Double? = null
    var radius: Double? = null
    var geoTitle: String? = null

    // Duration
    var durationSeconds: Int? = null

    // Member
    var entitySubIds: String? = null
    var memberIds: String? = null
    var memberNames: String? = null
    fun toThingModel(deviceConditionDataProvider: (deviceId: String, dpModelId: Int) -> DeviceConditionData): SceneCondition? {
        return when (kind) {
            Kind.device -> {
                val base = DeviceConditionBuilder(
                    deviceId!!,
                    dpModelId!!.toString(),
                    CONDITION_TYPE_DEVICE,
                    deviceConditionDataProvider(deviceId!!, dpModelId!!),
                    expr!!.chooseValue,

                    ).build() as ConditionBase

                return SceneCondition(base)
            }

            Kind.pir -> {
                val base = DeviceConditionBuilder(
                    deviceId!!,
                    dpModelId!!.toString(),
                    CONDITION_TYPE_PIR,
                    deviceConditionDataProvider(deviceId!!, dpModelId!!),
                    expr!!.chooseValue,

                    ).build() as ConditionBase

                return SceneCondition(base)
            }

            Kind.weather -> {
                val base = WeatherConditionBuilder(
                    city!!.cityId.toString(),
                    city!!.city,
                    CONDITION_TYPE_WEATHER,
                    WeatherType.getByType(expr!!.type)!!,
                    expr!!.compareOperator,
                    expr!!.chooseValue!!

                ).build() as ConditionBase

                return SceneCondition(base)
            }

            Kind.timer -> {
                val base = TimingConditionBuilder(
                    expr!!.timeZoneId, expr!!.loops!!, expr!!.time!!, expr!!.date!!
                ).build() as ConditionBase
                return SceneCondition(base)
            }

            Kind.sunTimer -> {
                val type = when (expr!!.sunType) {
                    1 -> SunSetRiseRule.SunType.SUNRISE
                    2 -> SunSetRiseRule.SunType.SUNSET
                    else -> SunSetRiseRule.SunType.SUNSET
                }
                val base = SunRiseSetConditionBuilder(
                    city!!.cityId.toString(), type, expr!!.deltaMinutes!!
                ).build() as ConditionBase

                return SceneCondition(base)
            }

            Kind.geoFence -> {
                val type = when (geoType) {
                    0 -> GeofencingType.GEOFENCING_TYPE_ENTER
                    1 -> GeofencingType.GEOFENCING_TYPE_EXIT
                    3 -> GeofencingType.GEOFENCING_TYPE_INSIDE
                    4 -> GeofencingType.GEOFENCING_TYPE_OUTSIDE
                    else -> GeofencingType.GEOFENCING_TYPE_EXIT
                }
                val base = GeofenceConditionBuilder(
                    radius!!.toInt(), latitude!!, longitude!!, geoTitle!!, type.type
                ).build() as ConditionBase
                return SceneCondition(base)
            }

            Kind.manual -> SceneCondition().apply {
                this.entityType = CONDITION_TYPE_MANUAL
            }

            Kind.calculateDuration -> {
                val base = ConditionBase()
                    .apply {
                        this.duration = this@SceneConditionDTO.durationSeconds.toString()
                        this.entityType = ConditionEntityType.CONDITION_CALCULATE.type
                        this.entitySubIds = this@SceneConditionDTO.dpModelId.toString()
                        this.entityId = this@SceneConditionDTO.deviceId

                    }


                return SceneCondition(base)
            }

            Kind.memberBackHome -> TODO()
            else -> null
        }

    }
}
