//
//  Extensions.swift
//  tuya_home_sdk_flutter
//
//  Created by Basem Abduallah on 08/07/2025.
//

import Foundation
import ThingSmartDeviceKit
import ThingSmartHomeKit
import TuyaHomeSdkKit

extension ThingSmartSceneModel {

    func toDictionary() -> [String: Any?] {
        var dict: [String: Any?] = [:]
        dict["id"] = sceneId
        dict["name"] = name
        dict["gwId"] = gwId
        dict["coverIcon"] = coverIcon
        dict["displayColor"] = displayColor
        dict["isEnabled"] = enabled
        dict["isStickyOnTop"] = stickyOnTop
        dict["isNewLocalScene"] = newLocalScene
        dict["isLocalLinkage"] = localLinkage
        dict["linkageType"] = linkageType.rawValue
        dict["ruleGenre"] = ruleGenre.rawValue
        dict["arrowIconUrl"] = arrowIconUrl
        dict["outOfWork"] = outOfWork.rawValue
        dict["matchType"] = matchType.rawValue
        dict["categorys"] = categorys
        dict["panelType"] = panelType.rawValue
        dict["background"] = background
        dict["preConditions"] =
            preConditions?.map { condition in
                var preDict: [String: Any?] = [:]
                preDict["id"] = condition.scenarioId ?? NSNull()
                preDict["condType"] = condition.condType ?? NSNull()
                preDict["conditionId"] = condition.conditionId ?? NSNull()
                preDict["expr"] = condition.expr ?? [:]
                return preDict
            } ?? []
        dict["conditions"] =
            conditions?.map { condition in
                return [

                    "entityType": condition.entityType.rawValue,
                    "entityId": condition.entityId ?? NSNull(),
                    "expr": condition.expr ?? [NSNull()],
                    "id": condition.scenarioId ?? NSNull(),
                    "entityName": condition.entityName ?? NSNull(),
                    "exprDisplay": condition.exprDisplay ?? NSNull(),
                    "condType": condition.conditionExpressionType.rawValue,
                    "extraInfo": condition.extraInfo ?? [:],

                ]
            } ?? []
        dict["statusConditions"] =
            statusConditions?.map { condition in
                return [
                    "entityType": condition.entityType.rawValue,
                    "entityId": condition.entityId ?? NSNull(),
                    "expr": condition.expr ?? [NSNull()],
                    "id": condition.scenarioId ?? NSNull(),
                    "entityName": condition.entityName ?? NSNull(),
                    "exprDisplay": condition.exprDisplay ?? NSNull(),
                    "condType": condition.conditionExpressionType.rawValue,
                    "extraInfo": condition.extraInfo ?? [:],

                ]
            } ?? []
        dict["actions"] =
            actions?.map { act in

                var actionDict: [String: Any?] = [:]
                actionDict["id"] = act.actionId
                actionDict["entityName"] = act.entityName
                actionDict["pid"] = act.pid
                actionDict["productId"] = act.productId
                actionDict["actionDisplay"] = act.actionDisplay
                actionDict["entityId"] = act.entityId
                actionDict["productPic"] = act.productPic
                actionDict["uiid"] = act.uiid
                actionDict["executorProperty"] = act.executorProperty ?? [:]
                actionDict["extraProperty"] = act.extraProperty ?? [:]

                return actionDict
            } ?? []
        return dict
    }

}

struct ThingSmartSceneFactory: Codable {
    let id:String?
    let homeId: Int?
    let name: String?
    let showFirstPage: Bool?
    let matchType: Int?
    let actions: [SceneActionModel]?
    let preConditions: [ScenePreCondition]?
    let conditions : [SceneConditionDTO]?
}

// MARK: - Enum equivalents

enum SceneActionKind: String, Codable {
    case deviceDp
    case groupDp
    case triggerScene
    case switchAutomation
    case delay
    case sendNotification
    case call
    case sms
}

// MARK: - Codable struct that mirrors the Dart model
struct SceneActionModel: Codable {
    let kind: SceneActionKind

    // Device / group
    let devId: String?
    let devName: String?
    let groupId: String?
    let groupName: String?

    // Scene
    let sceneId: String?
    let sceneName: String?

    // DP execution
    let executerProperty: [String: AnyCodable]?
    let extraProperty: [String: AnyCodable]?

    // Enable / disable automation
    let autoSwitchType: Int?

    // Delay
    let delayHours: String?
    let delayMinutes: String?
    let delaySeconds: String?

    // Convenience: convert to Tuya’s ThingSmartSceneActionModel if you need it
    func toTuyaModel() -> ThingSmartSceneActionModel {
        switch kind {
        case .deviceDp:
            return ThingSmartSceneActionFactory.createDeviceDpAction(
                withDevId: devId ?? "",
                devName: devName ?? "",
                executerProperty: executerProperty ?? [:],
                extraProperty: extraProperty ?? [:]
            )

        case .groupDp:
            return ThingSmartSceneActionFactory.createGroupDpAction(
                withGroupId: groupId ?? "",
                groupName: groupName ?? "",
                executerProperty: executerProperty ?? [:],
                extraProperty: extraProperty ?? [:]
            )

        case .triggerScene:
            return ThingSmartSceneActionFactory.createTriggerSceneAction(
                withSceneId: sceneId ?? "",
                sceneName: sceneName ?? ""
            )

        case .switchAutomation:

            return ThingSmartSceneActionFactory.createSwitchAutoAction(
                withSceneId: sceneId ?? "",
                sceneName: sceneName ?? "",
                type: AutoSwitchType.init(rawValue: autoSwitchType ?? 1)!
            )

        case .delay:
            return ThingSmartSceneActionFactory.createDelayAction(
                withHours: delayHours ?? "0",
                minutes: delayMinutes ?? "0",
                seconds: delaySeconds ?? "0"
            )

        case .sendNotification:
            return ThingSmartSceneActionFactory.createSendNotificationAction()

        case .call:
            return ThingSmartSceneActionFactory.createCallAction()

        case .sms:
            return ThingSmartSceneActionFactory.createSmsAction()
        }
    }
}

enum ScenePreConditionKind: String, Codable {
    case allDay, daytime, night, customTime
}

struct ScenePreCondition: Codable {
    let kind: ScenePreConditionKind
    let sceneId: String?
    let conditionId: String?
    let loops: String
    let timeZoneId: String
    let cityId: String?
    let cityName: String?
    let beginTime: String?
    let endTime: String?
    
    func toThingModel() -> ThingSmartScenePreConditionModel? {

            switch kind {
            case .allDay:
                return ThingSmartScenePreConditionFactory.creatAllDayPreCondition(
                    withSceneId: sceneId,
                    existConditionId: conditionId,
                    loops: loops,
                    timeZoneId: timeZoneId
                )

            case .daytime:
                guard
                    let cityId,
                    let cityName
                else { return nil }

                return ThingSmartScenePreConditionFactory.createDayTimePreCondition(
                    withSceneId: sceneId,
                    existConditionId: conditionId,
                    loops: loops,
                    cityId: cityId,
                    cityName: cityName,
                    timeZoneId: timeZoneId
                )

            case .night:
                guard
                    let cityId,
                    let cityName
                else { return nil }

                return ThingSmartScenePreConditionFactory.createNightTimePreCondition(
                    withSceneId: sceneId,
                    existConditionId: conditionId,
                    loops: loops,
                    cityId: cityId,
                    cityName: cityName,
                    timeZoneId: timeZoneId
                )

            case .customTime:
                guard
                    let cityId,
                    let cityName,
                    let beginTime,
                    let endTime
                else { return nil }

                return ThingSmartScenePreConditionFactory.createCustomTimePreCondition(
                    withSceneId: sceneId,
                    existConditionId: conditionId,
                    loops: loops,
                    cityId: cityId,
                    cityName: cityName,
                    timeZoneId: timeZoneId,
                    beginTime: beginTime,
                    endTime: endTime
                )
            }
        }
}


public struct AnyCodable: Codable {
    public let value: Any

    public init(_ value: Any) {
        self.value = value
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let int = try? container.decode(Int.self) {
            self.value = int
        } else if let double = try? container.decode(Double.self) {
            self.value = double
        } else if let bool = try? container.decode(Bool.self) {
            self.value = bool
        } else if let string = try? container.decode(String.self) {
            self.value = string
        } else if let array = try? container.decode([AnyCodable].self) {
            self.value = array.map(\.value)
        } else if let dict = try? container.decode([String: AnyCodable].self) {
            self.value = dict.mapValues { $0.value }
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unsupported type"
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch value {
        case let int as Int: try container.encode(int)
        case let double as Double: try container.encode(double)
        case let bool as Bool: try container.encode(bool)
        case let string as String: try container.encode(string)
        case let array as [Any]:
            try container.encode(array.map { AnyCodable($0) })
        case let dict as [String: Any]:
            try container.encode(dict.mapValues { AnyCodable($0) })
        default:
            throw EncodingError.invalidValue(
                value,
                EncodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Unsupported type"
                )
            )
        }
    }
}

// MARK: - DTOs that mirror Dart maps ---------------------------------------

enum SceneExprKind: String, Codable {
    case boolValue, enumValue, compareValue, raw
    case timer, sunTimer, geofence, calculate, memberBackHome
}

struct CityDTO: Codable {
    let cityId: Int64
    let city: String
    let area: String?
    let pinyin: String?
    let province: String?
    let latitude: Double?
    let longitude: Double?

    func toThingCity() -> ThingSmartCityModel {
        let m = ThingSmartCityModel()
        m.cityId = cityId
        m.city = city
        m.area = area ?? ""
        m.pinyin = pinyin ?? ""
        m.province = province ?? ""
        m.tempLatitude = latitude ?? 0
        m.tempLongitude = longitude ?? 0
        return m
    }
}

struct SceneExprDTO: Codable {

    // Basic discriminator
    let kind: SceneExprKind

    // Common
    let type: String?
    let exprType: Int?        // matches `ExprType`
    let isTrue: Bool?
    let chooseValue : AnyCodable?
    let compareOperator: String?
    

    // Timer
    let timeZoneId: String?
    let loops: String?
    let date: String?
    let time: String?

    // Sun timer
    let city: CityDTO?
    let sunType: Int?         // matches `SunType`
    let deltaMinutes: Int?

    // Geofence
    let geoFenceType: Int?    // matches `GeoFenceType`

    // Calculate
    let dpId: String?
    let dpType: String?
    let selectedValue: AnyCodable?

    // Member back home
    let memberIds: String?
}

// MARK: - Conversion to ThingSmartSceneExprModel ---------------------------

extension SceneExprDTO {

    func toThingModel() -> ThingSmartSceneExprModel? {

        switch kind {

        // ───────────────── Bool ─────────────────
        case .boolValue:
            guard
                let type,
                let isTrue,
                let exprType
            else { return nil }

            return ThingSmartSceneConditionExprBuilder.createBoolExpr(
                withType: type,
                isTrue: isTrue,
                exprType: ExprType(rawValue: exprType) ?? .device
            )

        // ───────────────── Enum ─────────────────
        case .enumValue:
            guard
                let type,
                let chooseValue,
                let exprType
            else { return nil }

            return ThingSmartSceneConditionExprBuilder.createEnumExpr(
                withType: type,
                chooseValue: chooseValue.value as! String ,
                exprType: ExprType(rawValue: exprType) ?? .device
            )

        // ─────────────── Compare ───────────────
        case .compareValue:
            guard
                let type,
                let compareOperator,
                let chooseValue,
                let exprType
            else { return nil }

            return ThingSmartSceneConditionExprBuilder.createValueExpr(
                withType: type,
                operater: compareOperator,
                chooseValue: chooseValue.value as! Int ,
                exprType: ExprType(rawValue: exprType) ?? .device
            )

        // ───────────────── Raw ─────────────────
        case .raw:
            guard
                let type,
                let exprType
            else { return nil }

            return ThingSmartSceneConditionExprBuilder.createRawExpr(
                withType: type,
                exprType: ExprType(rawValue: exprType) ?? .device
            )

        // ─────────────── Timer ────────────────
        case .timer:
            guard
                let timeZoneId, let loops,
                let date, let time
            else { return nil }

            return ThingSmartSceneConditionExprBuilder.createTimerExpr(
                withTimeZoneId: timeZoneId,
                loops: loops,
                date: date,
                time: time
            )

        // ───────────── Sun timer ──────────────
        case .sunTimer:
            guard
                let city,
                let sunType,
                let deltaMinutes
            else { return nil }

            return ThingSmartSceneConditionExprBuilder.createSunsetriseTimerExpr(
                withCity: city.toThingCity(),
                type: SunType(rawValue: sunType) ?? .rise,
                deltaMinutes: deltaMinutes
            )

        // ───────────── Geofence ───────────────
        case .geofence:
            guard let geoFenceType else { return nil }

            return ThingSmartSceneConditionExprBuilder.buildGeofenceExpr(
                with: GeoFenceType(rawValue: geoFenceType) ?? .reach
            )

        // ───────────── Calculate ──────────────
        case .calculate:
            guard let dpId, let dpType, let selectedValue else { return nil }

            return ThingSmartSceneConditionExprBuilder.buildCalculateExpr(
                withDpId: dpId,
                dpType: dpType,
                selectedValue: selectedValue.value
            )

        // ─────── Member back home ─────────────
        case .memberBackHome:
            guard let memberIds else { return nil }

            return ThingSmartSceneConditionExprBuilder.buildMemberBackHomeExpr(
                withMemberIds: memberIds
            )
        }
    }
}
// MARK: - Codable helpers (reuse AnyCodable + CityDTO from the expr bridge)

struct SceneConditionDTO: Codable {
    enum Kind: String, Codable {
        case device, pir, weather, timer, sunTimer, geoFence
        case manual, calculateDuration, memberBackHome
    }

    let kind: Kind

    // Device + dp
    let deviceId: String?
    let dpModelId: Int?

    // Nested expr
    let expr: SceneExprDTO?

    // City
    let city: CityDTO?

    // Geo
    let geoType: Int?
    let latitude: Double?
    let longitude: Double?
    let radius: Double?
    let geoTitle: String?

    // Duration
    let durationSeconds: Int?

    // Member
    let entitySubIds: String?
    let memberIds: String?
    let memberNames: String?
}

// MARK: - Conversion --------------------------------------------------------

extension SceneConditionDTO {
    
    
    
    

    func toThingModel(dpLookup: (String,Int) -> ThingSmartSceneDPModel?) -> ThingSmartSceneConditionModel? {
        
        switch kind {

        // ───────────── Device / Pir (same signature) ─────────────
        case .device, .pir:
            guard
                let devId = deviceId,
                let dpId = dpModelId,
                let exprDTO = expr,
                let exprModel = exprDTO.toThingModel(),
                let dev = ThingSmartDevice(deviceId: devId)?.deviceModel,
                let dpModel = dpLookup(deviceId!,dpId)
            else { return nil }

            if kind == .pir {
                return ThingSmartSceneConditionFactory.createPirCondition(
                    withDevice: dev,
                    dpModel: dpModel,
                    exprModel: exprModel
                )
            } else {
                return ThingSmartSceneConditionFactory.createDeviceCondition(
                    withDevice: dev,
                    dpModel: dpModel,
                    exprModel: exprModel
                )
            }

        // ───────────── Weather ─────────────
        case .weather:
            guard
                let city,
                let dpId = dpModelId,
                let exprDTO = expr,
                let exprModel = exprDTO.toThingModel(),
                let dpModel = dpLookup(deviceId!,dpId)
            else { return nil }

            return ThingSmartSceneConditionFactory.createWhetherCondition(
                withCity: city.toThingCity(),
                dpModel: dpModel,
                exprModel: exprModel
            )

        // ───────────── Timer ─────────────
        case .timer:
            guard let exprDTO = expr, let exprModel = exprDTO.toThingModel() else { return nil }
            return ThingSmartSceneConditionFactory.createTimerCondition(
                with: exprModel
            )

        // ───────────── Sun timer ─────────────
        case .sunTimer:
            guard
                let city,
                let exprDTO = expr,
                let exprModel = exprDTO.toThingModel()
            else { return nil }
            
                
            return ThingSmartSceneConditionFactory.createSunsetriseTimerCondition(
                withCity: city.toThingCity(),
                exprModel: exprModel
            )

        // ───────────── Geo fence ─────────────
        case .geoFence:
            guard
                let geoType, let latitude,
                let longitude, let radius, let geoTitle
            else { return nil }

            return ThingSmartSceneConditionFactory.createGeoFenceCondition(
                withGeoType: GeoFenceType(rawValue: geoType) ?? .reach,
                geoLati: CGFloat(latitude),
                geoLonti: CGFloat(longitude),
                geoRadius: CGFloat(radius),
                geoTitle: geoTitle
            )

        // ───────────── Manual ─────────────
        case .manual:
            return ThingSmartSceneConditionFactory.createManualExecuteCondition()

        // ───────────── Calculate duration ─────────────
        case .calculateDuration:
            guard
                let devId = deviceId,
                let dpId = dpModelId,
                let exprDTO = expr,
                let exprModel = exprDTO.toThingModel(),
                let dur = durationSeconds,
                let dev = ThingSmartDevice(deviceId: devId)?.deviceModel,
                let dpModel = dpLookup(deviceId!,dpId)
            else { return nil }

            return ThingSmartSceneConditionFactory.calculateCondition(
                with: dev,
                dpModel: dpModel,
                exprModel: exprModel,
                durationTime: TimeInterval(dur)
            )

        // ───────────── Member back home ─────────────
        case .memberBackHome:
            guard
                let devId = deviceId,
                let subIds = entitySubIds,
                let memberIds,
                let memberNames
            else { return nil }
            
            return ThingSmartSceneConditionFactory.memberBackHomeCondition(
                withDevId: devId,
                entitySubIds: subIds,
                memberIds: memberIds,
                memberNames: memberNames
            )
        }
    }
}


