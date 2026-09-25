import Foundation
import SwiftProtobuf

// MARK: - VehicleSnapshotMapper

/// Internal bridge from `CarServer_*` protobuf types to the public Swift-native
/// model types in this module.
///
/// This is the only file inside `Sources/` that references `CarServer_*`
/// protobuf types; every other layer works exclusively with the Swift-native
/// models so the protobuf surface never leaks into public API.
enum VehicleSnapshotMapper {
    // MARK: - Public API

    static func map(_ data: CarServer_VehicleData) -> TeslaVehicleSnapshot {
        var snapshot = TeslaVehicleSnapshot(
            charge: data.hasChargeState ? mapCharge(data.chargeState) : nil,
            climate: data.hasClimateState ? mapClimate(data.climateState) : nil,
            drive: data.hasDriveState ? mapDrive(data.driveState) : nil,
            closures: data.hasClosuresState ? mapClosures(data.closuresState) : nil,
            tirePressure: data.hasTirePressureState ? mapTirePressure(data.tirePressureState) : nil,
            media: data.hasMediaState ? mapMedia(data.mediaState) : nil,
            mediaDetail: data.hasMediaDetailState ? mapMediaDetail(data.mediaDetailState) : nil,
            softwareUpdate: data.hasSoftwareUpdateState ? mapSoftwareUpdate(data.softwareUpdateState) : nil,
            chargeSchedule: data.hasChargeScheduleState ? ChargeScheduleState() : nil,
            preconditionSchedule: data.hasPreconditioningScheduleState ? PreconditionScheduleState() : nil,
            parentalControls: data.hasParentalControlsState ? mapParentalControls(data.parentalControlsState) : nil,
        )
        snapshot.location = data.hasLocationState ? mapLocation(data.locationState) : nil
        return snapshot
    }

    /// Fast path used by high-frequency drive-state polls: extracts only the
    /// drive sub-section from a full `CarServer_VehicleData` payload and
    /// returns an empty `DriveState` if none is present.
    static func mapDrive(_ data: CarServer_VehicleData) -> DriveState {
        guard data.hasDriveState else { return DriveState() }
        return mapDrive(data.driveState)
    }

    // MARK: - Sub-state mappers

    /// Returns `value` only when the field's presence wrapper is set, so a
    /// field the vehicle didn't send maps to nil rather than to its zero value.
    private static func ifSet<Wrapper, Value>(_ presence: Wrapper?, _ value: @autoclosure () -> Value) -> Value? {
        presence == nil ? nil : value()
    }

    private static func mapCharge(_ pb: CarServer_ChargeState) -> ChargeState {
        var state = ChargeState(
            batteryLevel: ifSet(pb.optionalBatteryLevel, Int(pb.batteryLevel)),
            batteryRangeMiles: ifSet(pb.optionalBatteryRange, Double(pb.batteryRange)),
            estBatteryRangeMiles: ifSet(pb.optionalEstBatteryRange, Double(pb.estBatteryRange)),
            chargingStatus: pb.hasChargingState ? mapChargingStatus(pb.chargingState) : nil,
            chargerVoltage: ifSet(pb.optionalChargerVoltage, Int(pb.chargerVoltage)),
            chargerCurrent: ifSet(pb.optionalChargerActualCurrent, Int(pb.chargerActualCurrent)),
            chargerPower: ifSet(pb.optionalChargerPower, Int(pb.chargerPower)),
            chargeLimitPercent: ifSet(pb.optionalChargeLimitSoc, Int(pb.chargeLimitSoc)),
            minutesToFullCharge: ifSet(pb.optionalMinutesToFullCharge, Int(pb.minutesToFullCharge)),
            chargeRateMph: ifSet(pb.optionalChargeRateMph, Double(pb.chargeRateMph)),
            chargePortOpen: ifSet(pb.optionalChargePortDoorOpen, pb.chargePortDoorOpen),
            chargePortLatched: pb.hasChargePortLatch ? mapChargePortLatch(pb.chargePortLatch) : nil,
        )
        state.usableBatteryLevel = ifSet(pb.optionalUsableBatteryLevel, Int(pb.usableBatteryLevel))
        state.idealBatteryRangeMiles = ifSet(pb.optionalIdealBatteryRange, Double(pb.idealBatteryRange))
        state.chargeEnergyAddedKWh = ifSet(pb.optionalChargeEnergyAdded, Double(pb.chargeEnergyAdded))
        state.chargeMilesAddedRated = ifSet(pb.optionalChargeMilesAddedRated, Double(pb.chargeMilesAddedRated))
        state.minutesToChargeLimit = ifSet(pb.optionalMinutesToChargeLimit, Int(pb.minutesToChargeLimit))
        state.chargerPhases = ifSet(pb.optionalChargerPhases, Int(pb.chargerPhases))
        state.chargerPilotCurrent = ifSet(pb.optionalChargerPilotCurrent, Int(pb.chargerPilotCurrent))
        state.chargeCurrentRequest = ifSet(pb.optionalChargeCurrentRequest, Int(pb.chargeCurrentRequest))
        state.chargeCurrentRequestMax = ifSet(pb.optionalChargeCurrentRequestMax, Int(pb.chargeCurrentRequestMax))
        state.chargingAmps = ifSet(pb.optionalChargingAmps, Int(pb.chargingAmps))
        state.fastChargerPresent = ifSet(pb.optionalFastChargerPresent, pb.fastChargerPresent)
        state.fastChargerType = pb.hasFastChargerType ? mapFastChargerType(pb.fastChargerType) : nil
        state.scheduledChargingPending = ifSet(pb.optionalScheduledChargingPending, pb.scheduledChargingPending)
        state.chargePortColdWeatherMode = ifSet(pb.optionalChargePortColdWeatherMode, pb.chargePortColdWeatherMode)
        return state
    }

    private static func mapClimate(_ pb: CarServer_ClimateState) -> ClimateState {
        var state = ClimateState(
            insideTempCelsius: ifSet(pb.optionalInsideTempCelsius, Double(pb.insideTempCelsius)),
            outsideTempCelsius: ifSet(pb.optionalOutsideTempCelsius, Double(pb.outsideTempCelsius)),
            driverTempSettingCelsius: ifSet(pb.optionalDriverTempSetting, Double(pb.driverTempSetting)),
            passengerTempSettingCelsius: ifSet(pb.optionalPassengerTempSetting, Double(pb.passengerTempSetting)),
            fanStatus: ifSet(pb.optionalFanStatus, Int(pb.fanStatus)),
            isClimateOn: ifSet(pb.optionalIsClimateOn, pb.isClimateOn),
            seatHeaterFrontLeft: ifSet(pb.optionalSeatHeaterLeft, pb.seatHeaterLeft).flatMap(mapSeatHeater),
            seatHeaterFrontRight: ifSet(pb.optionalSeatHeaterRight, pb.seatHeaterRight).flatMap(mapSeatHeater),
            seatHeaterRearLeft: ifSet(pb.optionalSeatHeaterRearLeft, pb.seatHeaterRearLeft).flatMap(mapSeatHeater),
            seatHeaterRearCenter: ifSet(pb.optionalSeatHeaterRearCenter, pb.seatHeaterRearCenter)
                .flatMap(mapSeatHeater),
            seatHeaterRearRight: ifSet(pb.optionalSeatHeaterRearRight, pb.seatHeaterRearRight).flatMap(mapSeatHeater),
            steeringWheelHeater: ifSet(pb.optionalSteeringWheelHeater, pb.steeringWheelHeater),
            isBatteryHeaterOn: ifSet(pb.optionalBatteryHeater, pb.batteryHeater),
            defrostOn: pb.hasDefrostMode ? mapDefrost(pb.defrostMode) : nil,
            bioweaponMode: ifSet(pb.optionalBioweaponModeOn, pb.bioweaponModeOn),
        )
        state.isFrontDefrosterOn = ifSet(pb.optionalIsFrontDefrosterOn, pb.isFrontDefrosterOn)
        state.isRearDefrosterOn = ifSet(pb.optionalIsRearDefrosterOn, pb.isRearDefrosterOn)
        state.minAvailableTempCelsius = ifSet(pb.optionalMinAvailTempCelsius, Double(pb.minAvailTempCelsius))
        state.maxAvailableTempCelsius = ifSet(pb.optionalMaxAvailTempCelsius, Double(pb.maxAvailTempCelsius))
        state.seatHeaterRearLeftBack = ifSet(pb.optionalSeatHeaterRearLeftBack, pb.seatHeaterRearLeftBack)
            .flatMap(mapSeatHeater)
        state.seatHeaterRearRightBack = ifSet(pb.optionalSeatHeaterRearRightBack, pb.seatHeaterRearRightBack)
            .flatMap(mapSeatHeater)
        state.seatHeaterThirdRowLeft = ifSet(pb.optionalSeatHeaterThirdRowLeft, pb.seatHeaterThirdRowLeft)
            .flatMap(mapSeatHeater)
        state.seatHeaterThirdRowRight = ifSet(pb.optionalSeatHeaterThirdRowRight, pb.seatHeaterThirdRowRight)
            .flatMap(mapSeatHeater)
        state.seatFanFrontLeft = ifSet(pb.optionalSeatFanFrontLeft, Int(pb.seatFanFrontLeft))
        state.seatFanFrontRight = ifSet(pb.optionalSeatFanFrontRight, Int(pb.seatFanFrontRight))
        state.steeringWheelHeatLevel = ifSet(pb.optionalSteeringWheelHeatLevel, pb.steeringWheelHeatLevel)
            .map(mapSteeringWheelHeatLevel)
        state.autoSteeringWheelHeat = ifSet(pb.optionalAutoSteeringWheelHeat, pb.autoSteeringWheelHeat)
        state.autoSeatClimateLeft = ifSet(pb.optionalAutoSeatClimateLeft, pb.autoSeatClimateLeft)
        state.autoSeatClimateRight = ifSet(pb.optionalAutoSeatClimateRight, pb.autoSeatClimateRight)
        state.wiperBladeHeater = ifSet(pb.optionalWiperBladeHeater, pb.wiperBladeHeater)
        state.sideMirrorHeaters = ifSet(pb.optionalSideMirrorHeaters, pb.sideMirrorHeaters)
        state.isPreconditioning = ifSet(pb.optionalIsPreconditioning, pb.isPreconditioning)
        state.isAutoConditioningOn = ifSet(pb.optionalIsAutoConditioningOn, pb.isAutoConditioningOn)
        state.batteryHeaterNoPower = ifSet(pb.optionalBatteryHeaterNoPower, pb.batteryHeaterNoPower)
        state.climateKeeperMode = pb.hasClimateKeeperMode ? mapKeeperMode(pb.climateKeeperMode) : nil
        state.cabinOverheatProtection = ifSet(pb.optionalCabinOverheatProtection, pb.cabinOverheatProtection)
            .map(mapCabinOverheatProtection)
        state.cabinOverheatProtectionActivelyCooling = ifSet(
            pb.optionalCabinOverheatProtectionActivelyCooling,
            pb.cabinOverheatProtectionActivelyCooling,
        )
        state.cabinOverheatProtectionActivationTemp = ifSet(
            pb.optionalCopActivationTemperature,
            pb.copActivationTemperature,
        ).flatMap(mapCopActivationTemp)
        return state
    }

    private static func mapDrive(_ pb: CarServer_DriveState) -> DriveState {
        let shiftState = mapShift(pb.shiftState)
        let speedMph: Double? = pb.optionalSpeedFloat != nil ? Double(pb.speedFloat) : nil
        let powerKW: Int? = pb.optionalPower != nil ? Int(pb.power) : nil
        let odometerHundredthsMile: Int? = pb.optionalOdometerInHundredthsOfAMile != nil
            ? Int(pb.odometerInHundredthsOfAMile) : nil
        let destination: String? = pb.optionalActiveRouteDestination != nil
            ? pb.activeRouteDestination : nil
        let minutesToArrival: Double? = pb.optionalActiveRouteMinutesToArrival != nil
            ? Double(pb.activeRouteMinutesToArrival) : nil
        let milesToArrival: Double? = pb.optionalActiveRouteMilesToArrival != nil
            ? Double(pb.activeRouteMilesToArrival) : nil

        var state = DriveState(
            shiftState: shiftState,
            speedMph: speedMph,
            powerKW: powerKW,
            odometerHundredthsMile: odometerHundredthsMile,
            activeRouteDestination: destination,
            activeRouteMinutesToArrival: minutesToArrival,
            activeRouteMilesToArrival: milesToArrival,
        )
        state.activeRouteTrafficMinutesDelay = ifSet(
            pb.optionalActiveRouteTrafficMinutesDelay,
            Double(pb.activeRouteTrafficMinutesDelay),
        )
        state.activeRouteEnergyAtArrival = ifSet(
            pb.optionalActiveRouteEnergyAtArrival,
            Double(pb.activeRouteEnergyAtArrival),
        )
        state.activeRouteCoordinates = pb.hasActiveRouteCoordinates
            ? Coordinate(
                latitude: Double(pb.activeRouteCoordinates.latitude),
                longitude: Double(pb.activeRouteCoordinates.longitude),
            ) : nil
        return state
    }

    private static func mapLocation(_ pb: CarServer_LocationState) -> LocationState {
        let coordinate: Coordinate? = pb.optionalLatitude != nil && pb.optionalLongitude != nil
            ? Coordinate(latitude: Double(pb.latitude), longitude: Double(pb.longitude)) : nil
        let estimated: Coordinate? = pb.optionalGeoLatitude != nil && pb.optionalGeoLongitude != nil
            ? Coordinate(latitude: Double(pb.geoLatitude), longitude: Double(pb.geoLongitude)) : nil
        return LocationState(
            coordinate: coordinate,
            headingDegrees: ifSet(pb.optionalHeading, Int(pb.heading)),
            gpsAsOf: ifSet(pb.optionalGpsAsOf, Date(timeIntervalSince1970: TimeInterval(pb.gpsAsOf))),
            estimatedCoordinate: estimated,
            estimatedHeadingDegrees: ifSet(pb.optionalGeoHeading, Double(pb.geoHeading)),
            elevation: ifSet(pb.optionalGeoElevation, Double(pb.geoElevation)),
            accuracy: ifSet(pb.optionalGeoAccuracy, Double(pb.geoAccuracy)),
            locationName: ifSet(pb.optionalLocationName, pb.locationName),
            homelinkNearby: ifSet(pb.optionalHomelinkNearby, pb.homelinkNearby),
        )
    }

    private static func mapClosures(_ pb: CarServer_ClosuresState) -> ClosuresState {
        let sunroofState: ClosuresState.SunroofState? = pb.hasSunRoofState
            ? mapSunroof(pb.sunRoofState) : nil
        let sunroofPercentOpen: Int? = pb.optionalSunRoofPercentOpen != nil
            ? Int(pb.sunRoofPercentOpen) : nil
        let sentryModeActive: Bool? = pb.hasSentryModeState
            ? mapSentry(pb.sentryModeState) : nil

        var state = ClosuresState(
            frontDriverDoor: pb.optionalDoorOpenDriverFront != nil ? pb.doorOpenDriverFront : nil,
            frontPassengerDoor: pb.optionalDoorOpenPassengerFront != nil ? pb.doorOpenPassengerFront : nil,
            rearDriverDoor: pb.optionalDoorOpenDriverRear != nil ? pb.doorOpenDriverRear : nil,
            rearPassengerDoor: pb.optionalDoorOpenPassengerRear != nil ? pb.doorOpenPassengerRear : nil,
            frontTrunk: pb.optionalDoorOpenTrunkFront != nil ? pb.doorOpenTrunkFront : nil,
            rearTrunk: pb.optionalDoorOpenTrunkRear != nil ? pb.doorOpenTrunkRear : nil,
            locked: pb.optionalLocked != nil ? pb.locked : nil,
            windowDriverFront: pb.optionalWindowOpenDriverFront != nil ? pb.windowOpenDriverFront : nil,
            windowPassengerFront: pb.optionalWindowOpenPassengerFront != nil ? pb.windowOpenPassengerFront : nil,
            windowDriverRear: pb.optionalWindowOpenDriverRear != nil ? pb.windowOpenDriverRear : nil,
            windowPassengerRear: pb.optionalWindowOpenPassengerRear != nil ? pb.windowOpenPassengerRear : nil,
            sunroofState: sunroofState,
            sunroofPercentOpen: sunroofPercentOpen,
            sentryModeActive: sentryModeActive,
            valetMode: pb.optionalValetMode != nil ? pb.valetMode : nil,
            isUserPresent: pb.optionalIsUserPresent != nil ? pb.isUserPresent : nil,
        )
        state.sentryMode = pb.hasSentryModeState ? mapSentryMode(pb.sentryModeState) : nil
        state.sentryModeAvailable = ifSet(pb.optionalSentryModeAvailable, pb.sentryModeAvailable)
        state.centerDisplayState = pb.hasCenterDisplayState ? mapDisplayState(pb.centerDisplayState) : nil
        state.remoteStart = ifSet(pb.optionalRemoteStart, pb.remoteStart)
        state.valetPinNeeded = ifSet(pb.optionalValetPinNeeded, pb.valetPinNeeded)
        if pb.hasSpeedLimitMode {
            let mode = pb.speedLimitMode
            state.speedLimitMode = ClosuresState.SpeedLimitMode(
                active: ifSet(mode.optionalActive, mode.active),
                pinCodeSet: ifSet(mode.optionalPinCodeSet, mode.pinCodeSet),
                currentLimitMph: ifSet(mode.optionalCurrentLimitMph, Double(mode.currentLimitMph)),
                minLimitMph: ifSet(mode.optionalMinLimitMph, Double(mode.minLimitMph)),
                maxLimitMph: ifSet(mode.optionalMaxLimitMph, Double(mode.maxLimitMph)),
            )
        }
        state.tonneauPercentOpen = ifSet(pb.optionalTonneauPercentOpen, Int(pb.tonneauPercentOpen))
        state.tonneauInMotion = ifSet(pb.optionalTonneauInMotion, pb.tonneauInMotion)
        return state
    }

    private static func mapTirePressure(_ pb: CarServer_TirePressureState) -> TirePressureState {
        TirePressureState(
            frontLeft: TirePressureState.Tire(
                pressureBar: pb.optionalTpmsPressureFl != nil ? Double(pb.tpmsPressureFl) : nil,
                hasWarning: pb.optionalTpmsHardWarningFl != nil || pb.optionalTpmsSoftWarningFl != nil
                    ? (pb.tpmsHardWarningFl || pb.tpmsSoftWarningFl) : nil,
            ),
            frontRight: TirePressureState.Tire(
                pressureBar: pb.optionalTpmsPressureFr != nil ? Double(pb.tpmsPressureFr) : nil,
                hasWarning: pb.optionalTpmsHardWarningFr != nil || pb.optionalTpmsSoftWarningFr != nil
                    ? (pb.tpmsHardWarningFr || pb.tpmsSoftWarningFr) : nil,
            ),
            rearLeft: TirePressureState.Tire(
                pressureBar: pb.optionalTpmsPressureRl != nil ? Double(pb.tpmsPressureRl) : nil,
                hasWarning: pb.optionalTpmsHardWarningRl != nil || pb.optionalTpmsSoftWarningRl != nil
                    ? (pb.tpmsHardWarningRl || pb.tpmsSoftWarningRl) : nil,
            ),
            rearRight: TirePressureState.Tire(
                pressureBar: pb.optionalTpmsPressureRr != nil ? Double(pb.tpmsPressureRr) : nil,
                hasWarning: pb.optionalTpmsHardWarningRr != nil || pb.optionalTpmsSoftWarningRr != nil
                    ? (pb.tpmsHardWarningRr || pb.tpmsSoftWarningRr) : nil,
            ),
            recommendedColdFrontBar: pb.optionalTpmsRcpFrontValue != nil
                ? Double(pb.tpmsRcpFrontValue) : nil,
            recommendedColdRearBar: pb.optionalTpmsRcpRearValue != nil
                ? Double(pb.tpmsRcpRearValue) : nil,
        )
    }

    private static func mapMedia(_ pb: CarServer_MediaState) -> MediaState {
        var state = MediaState(
            nowPlayingArtist: pb.optionalNowPlayingArtist != nil ? pb.nowPlayingArtist : nil,
            nowPlayingTitle: pb.optionalNowPlayingTitle != nil ? pb.nowPlayingTitle : nil,
            audioVolume: pb.optionalAudioVolume != nil ? Double(pb.audioVolume) : nil,
            audioVolumeMax: pb.optionalAudioVolumeMax != nil ? Double(pb.audioVolumeMax) : nil,
            remoteControlEnabled: pb.optionalRemoteControlEnabled != nil
                ? pb.remoteControlEnabled : nil,
        )
        state.playbackStatus = ifSet(pb.optionalMediaPlaybackStatus, pb.mediaPlaybackStatus)
            .flatMap(mapPlaybackStatus)
        state.nowPlayingSource = ifSet(pb.optionalNowPlayingSource, pb.nowPlayingSource).map(mapMediaSource)
        state.audioVolumeIncrement = ifSet(pb.optionalAudioVolumeIncrement, Double(pb.audioVolumeIncrement))
        return state
    }

    private static func mapMediaDetail(_ pb: CarServer_MediaDetailState) -> MediaDetailState {
        MediaDetailState(
            nowPlayingDurationSeconds: pb.optionalNowPlayingDuration != nil
                ? Double(pb.nowPlayingDuration) : nil,
            nowPlayingElapsedSeconds: pb.optionalNowPlayingElapsed != nil
                ? Double(pb.nowPlayingElapsed) : nil,
            nowPlayingAlbum: pb.optionalNowPlayingAlbum != nil ? pb.nowPlayingAlbum : nil,
            nowPlayingStation: pb.optionalNowPlayingStation != nil ? pb.nowPlayingStation : nil,
            nowPlayingSource: pb.optionalNowPlayingSourceString != nil
                ? pb.nowPlayingSourceString : nil,
            a2dpSourceName: pb.optionalA2DpSourceName != nil ? pb.a2DpSourceName : nil,
        )
    }

    private static func mapSoftwareUpdate(_ pb: CarServer_SoftwareUpdateState) -> SoftwareUpdateState {
        var state = SoftwareUpdateState(
            version: pb.optionalVersion != nil ? pb.version : nil,
            downloadPercent: pb.optionalDownloadPerc != nil ? Int(pb.downloadPerc) : nil,
            installPercent: pb.optionalInstallPerc != nil ? Int(pb.installPerc) : nil,
            expectedDurationSeconds: pb.optionalExpectedDurationSec != nil
                ? Int(pb.expectedDurationSec) : nil,
        )
        state.status = pb.hasStatus ? mapSoftwareUpdateStatus(pb.status) : nil
        state.scheduledTime = ifSet(
            pb.optionalScheduledTimeMs,
            Date(timeIntervalSince1970: TimeInterval(pb.scheduledTimeMs) / 1000),
        )
        state.warningTimeRemainingSeconds = ifSet(
            pb.optionalWarningTimeRemainingMs,
            Int(pb.warningTimeRemainingMs / 1000),
        )
        return state
    }

    private static func mapParentalControls(_ pb: CarServer_ParentalControlsState) -> ParentalControlsState {
        ParentalControlsState(
            active: pb.optionalParentalControlsActive != nil ? pb.parentalControlsActive : nil,
            pinSet: pb.optionalParentalControlsPinSet != nil ? pb.parentalControlsPinSet : nil,
        )
    }

    // MARK: - Enum helpers

    private static func mapChargingStatus(
        _ pb: CarServer_ChargeState.ChargingState,
    ) -> ChargeState.ChargingStatus? {
        guard let type = pb.type else { return nil }
        switch type {
        case .disconnected: return .disconnected
        case .charging: return .charging
        case .complete: return .complete
        case .stopped: return .stopped
        case .starting: return .starting
        case .unknown, .noPower, .calibrating: return .disconnected
        }
    }

    private static func mapShift(_ pb: CarServer_ShiftState) -> DriveState.ShiftState? {
        guard let type = pb.type else { return nil }
        switch type {
        case .p: return .park
        case .r: return .reverse
        case .n: return .neutral
        case .d: return .drive
        case .invalid, .sna: return nil
        }
    }

    private static func mapSunroof(
        _ pb: CarServer_ClosuresState.SunRoofState,
    ) -> ClosuresState.SunroofState? {
        guard let type = pb.type else { return nil }
        switch type {
        case .closed: return .closed
        case .open: return .open
        case .vent: return .vent
        case .moving: return .moving
        case .calibrating: return .calibrating
        case .unknown: return .unknown
        }
    }

    private static func mapSentry(
        _ pb: CarServer_ClosuresState.SentryModeState,
    ) -> Bool? {
        guard let type = pb.type else { return nil }
        switch type {
        case .off: return false
        case .idle, .armed, .aware, .panic, .quiet: return true
        }
    }

    private static func mapDefrost(
        _ pb: CarServer_ClimateState.DefrostMode,
    ) -> Bool? {
        guard let type = pb.type else { return nil }
        switch type {
        case .off: return false
        case .normal, .max: return true
        }
    }

    private static func mapSeatHeater(_ rawLevel: Int32) -> ClimateState.SeatHeaterLevel? {
        ClimateState.SeatHeaterLevel(rawValue: Int(rawLevel))
    }

    private static func mapChargePortLatch(_ pb: CarServer_ChargePortLatchState) -> Bool? {
        guard let type = pb.type else { return nil }
        switch type {
        case .engaged: return true
        case .disengaged: return false
        case .sna, .blocking: return nil
        }
    }

    private static func mapFastChargerType(
        _ pb: CarServer_ChargeState.ChargerType,
    ) -> ChargeState.FastChargerType? {
        guard let type = pb.type else { return nil }
        switch type {
        case .supercharger: return .supercharger
        case .chademo: return .chademo
        case .gb: return .gb
        case .combo: return .combo
        case .acsingleWireCan: return .acSingleWireCAN
        case .mcsingleWireCan: return .mcSingleWireCAN
        case .tesla: return .tesla
        case .other: return .other
        case .sna: return nil
        }
    }

    private static func mapSteeringWheelHeatLevel(
        _ pb: CarServer_StwHeatLevel,
    ) -> ClimateState.SteeringWheelHeatLevel {
        switch pb {
        case .off: .off
        case .low: .low
        case .high: .high
        case .unknown, .UNRECOGNIZED: .unknown
        }
    }

    private static func mapKeeperMode(
        _ pb: CarServer_ClimateState.ClimateKeeperMode,
    ) -> ClimateState.ClimateKeeperMode? {
        guard let type = pb.type else { return nil }
        switch type {
        case .off: return .off
        case .on: return .on
        case .dog: return .dog
        // "Party" is the protocol's name for Camp mode.
        case .party: return .camp
        case .unknown: return .unknown
        }
    }

    private static func mapCabinOverheatProtection(
        _ pb: CarServer_ClimateState.CabinOverheatProtection_E,
    ) -> ClimateState.CabinOverheatProtection {
        switch pb {
        case .cabinOverheatProtectionOff: .off
        case .cabinOverheatProtectionOn: .on
        case .cabinOverheatProtectionFanOnly: .fanOnly
        case .UNRECOGNIZED: .unknown
        }
    }

    private static func mapCopActivationTemp(
        _ pb: CarServer_ClimateState.CopActivationTemp,
    ) -> ClimateState.CabinOverheatActivationTemp? {
        switch pb {
        case .low: .low
        case .medium: .medium
        case .high: .high
        case .unspecified, .UNRECOGNIZED: nil
        }
    }

    private static func mapSentryMode(
        _ pb: CarServer_ClosuresState.SentryModeState,
    ) -> ClosuresState.SentryMode? {
        guard let type = pb.type else { return nil }
        switch type {
        case .off: return .off
        case .idle: return .idle
        case .armed: return .armed
        case .aware: return .aware
        case .panic: return .panic
        case .quiet: return .quiet
        }
    }

    private static func mapDisplayState(
        _ pb: CarServer_ClosuresState.DisplayState,
    ) -> ClosuresState.CenterDisplayState? {
        guard let type = pb.type else { return nil }
        switch type {
        case .off: return .off
        case .dim: return .dim
        case .accessory: return .accessory
        case .on: return .on
        case .driving: return .driving
        case .charging: return .charging
        case .lock: return .lock
        case .sentry: return .sentry
        case .dog: return .dog
        case .entertainment: return .entertainment
        }
    }

    private static func mapPlaybackStatus(_ pb: CarServer_MediaPlaybackStatus) -> MediaState.PlaybackStatus? {
        switch pb {
        case .stopped: .stopped
        case .playing: .playing
        case .paused: .paused
        case .UNRECOGNIZED: nil
        }
    }

    private static func mapMediaSource(_ pb: CarServer_MediaSourceType) -> MediaState.Source {
        switch pb {
        case .none: .none
        case .am: .am
        case .fm: .fm
        case .xm: .xm
        case .siriusXm: .siriusXm
        case .dab: .dab
        case .bluetooth: .bluetooth
        case .localFiles: .localFiles
        case .iPod: .iPod
        case .auxIn: .auxIn
        case .spotify: .spotify
        case .tidal: .tidal
        case .tuneIn: .tuneIn
        case .slacker: .slacker
        case .stingray: .stingray
        case .onlineRadio, .onlineRadio2: .onlineRadio
        case .qqmusic, .qqmusic2: .qqMusic
        case .netEaseMusic: .netEaseMusic
        case .ximalaya: .ximalaya
        case .browser: .browser
        case .theater: .theater
        case .game: .game
        default: .other(pb.rawValue)
        }
    }

    private static func mapSoftwareUpdateStatus(
        _ pb: CarServer_SoftwareUpdateState.SoftwareUpdateStatus,
    ) -> SoftwareUpdateState.Status? {
        guard let type = pb.type else { return nil }
        switch type {
        case .unknown: return .none
        case .installing: return .installing
        case .scheduled: return .scheduled
        case .available: return .available
        case .downloadingWifiWait: return .downloadingWifiWait
        case .downloading: return .downloading
        }
    }
}
