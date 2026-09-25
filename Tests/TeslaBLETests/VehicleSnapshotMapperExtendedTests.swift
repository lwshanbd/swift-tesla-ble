import SwiftProtobuf
@testable import TeslaBLE
import XCTest

/// Fields added on top of the original snapshot surface: location, media
/// playback status, extended charge/climate/closures/software-update state,
/// and the rule that a field the vehicle didn't send maps to nil.
final class VehicleSnapshotMapperExtendedTests: XCTestCase {
    func testUnreportedChargeAndClimateFieldsAreNilNotZero() {
        var data = CarServer_VehicleData()
        data.chargeState = CarServer_ChargeState()
        data.climateState = CarServer_ClimateState()

        let snapshot = VehicleSnapshotMapper.map(data)
        XCTAssertNotNil(snapshot.charge)
        XCTAssertNil(snapshot.charge?.batteryLevel)
        XCTAssertNil(snapshot.charge?.chargingStatus)
        XCTAssertNil(snapshot.charge?.chargePortLatched)
        XCTAssertNotNil(snapshot.climate)
        XCTAssertNil(snapshot.climate?.driverTempSettingCelsius)
        XCTAssertNil(snapshot.climate?.isClimateOn)
        XCTAssertNil(snapshot.climate?.seatHeaterFrontLeft)
        XCTAssertNil(snapshot.climate?.defrostOn)
    }

    func testReportedZeroStaysZero() {
        var data = CarServer_VehicleData()
        var charge = CarServer_ChargeState()
        charge.batteryLevel = 0
        data.chargeState = charge
        var climate = CarServer_ClimateState()
        climate.fanStatus = 0
        climate.isClimateOn = false
        data.climateState = climate

        let snapshot = VehicleSnapshotMapper.map(data)
        XCTAssertEqual(snapshot.charge?.batteryLevel, 0)
        XCTAssertEqual(snapshot.climate?.fanStatus, 0)
        XCTAssertEqual(snapshot.climate?.isClimateOn, false)
    }

    func testLocationMapping() {
        var data = CarServer_VehicleData()
        var location = CarServer_LocationState()
        location.latitude = 37.4
        location.longitude = -122.1
        location.heading = 270
        location.gpsAsOf = 1_700_000_000
        location.geoLatitude = 37.41
        location.geoLongitude = -122.11
        location.geoHeading = 269.5
        location.geoElevation = 12
        location.geoAccuracy = 3
        location.locationName = "Home"
        location.homelinkNearby = true
        data.locationState = location

        let l = VehicleSnapshotMapper.map(data).location
        XCTAssertEqual(l?.coordinate?.latitude ?? 0, 37.4, accuracy: 0.0001)
        XCTAssertEqual(l?.coordinate?.longitude ?? 0, -122.1, accuracy: 0.0001)
        XCTAssertEqual(l?.headingDegrees, 270)
        XCTAssertEqual(l?.gpsAsOf, Date(timeIntervalSince1970: 1_700_000_000))
        XCTAssertEqual(l?.estimatedCoordinate?.latitude ?? 0, 37.41, accuracy: 0.0001)
        XCTAssertEqual(l?.estimatedHeadingDegrees ?? 0, 269.5, accuracy: 0.01)
        XCTAssertEqual(l?.elevation ?? 0, 12, accuracy: 0.01)
        XCTAssertEqual(l?.accuracy ?? 0, 3, accuracy: 0.01)
        XCTAssertEqual(l?.locationName, "Home")
        XCTAssertEqual(l?.homelinkNearby, true)
    }

    func testLocationWithoutFixHasNilCoordinate() {
        var data = CarServer_VehicleData()
        var location = CarServer_LocationState()
        location.latitude = 37.4
        data.locationState = location

        let l = VehicleSnapshotMapper.map(data).location
        XCTAssertNotNil(l)
        XCTAssertNil(l?.coordinate)
        XCTAssertNil(l?.headingDegrees)
    }

    func testMissingLocationStateIsNil() {
        XCTAssertNil(VehicleSnapshotMapper.map(CarServer_VehicleData()).location)
    }

    func testDriveRouteExtras() {
        var data = CarServer_VehicleData()
        var drive = CarServer_DriveState()
        drive.activeRouteTrafficMinutesDelay = 7
        drive.activeRouteEnergyAtArrival = 42
        var destination = CarServer_LatLong()
        destination.latitude = 34.05
        destination.longitude = -118.24
        drive.activeRouteCoordinates = destination
        data.driveState = drive

        let d = VehicleSnapshotMapper.map(data).drive
        XCTAssertEqual(d?.activeRouteTrafficMinutesDelay, 7)
        XCTAssertEqual(d?.activeRouteEnergyAtArrival, 42)
        XCTAssertEqual(d?.activeRouteCoordinates?.latitude ?? 0, 34.05, accuracy: 0.0001)
        XCTAssertEqual(d?.activeRouteCoordinates?.longitude ?? 0, -118.24, accuracy: 0.0001)
    }

    func testMediaPlaybackStatusAndSource() {
        let cases: [(CarServer_MediaPlaybackStatus, MediaState.PlaybackStatus)] = [
            (.stopped, .stopped), (.playing, .playing), (.paused, .paused),
        ]
        for (pbStatus, expected) in cases {
            var data = CarServer_VehicleData()
            var media = CarServer_MediaState()
            media.mediaPlaybackStatus = pbStatus
            media.nowPlayingSource = .spotify
            media.audioVolumeIncrement = 0.33
            data.mediaState = media

            let m = VehicleSnapshotMapper.map(data).media
            XCTAssertEqual(m?.playbackStatus, expected)
            XCTAssertEqual(m?.nowPlayingSource, .spotify)
            XCTAssertEqual(m?.audioVolumeIncrement ?? 0, 0.33, accuracy: 0.001)
        }
    }

    func testMediaWithoutPlaybackStatusIsNil() {
        var data = CarServer_VehicleData()
        var media = CarServer_MediaState()
        media.nowPlayingTitle = "Song"
        data.mediaState = media

        XCTAssertNil(VehicleSnapshotMapper.map(data).media?.playbackStatus)
    }

    func testUnnamedMediaSourceKeepsRawValue() {
        var data = CarServer_VehicleData()
        var media = CarServer_MediaState()
        media.nowPlayingSource = .toybox
        data.mediaState = media

        XCTAssertEqual(
            VehicleSnapshotMapper.map(data).media?.nowPlayingSource,
            .other(CarServer_MediaSourceType.toybox.rawValue),
        )
    }

    func testChargeExtras() {
        var data = CarServer_VehicleData()
        var charge = CarServer_ChargeState()
        charge.usableBatteryLevel = 70
        charge.idealBatteryRange = 260
        charge.chargeEnergyAdded = 12.5
        charge.chargeMilesAddedRated = 48
        charge.minutesToChargeLimit = 35
        charge.chargerPhases = 3
        charge.chargerPilotCurrent = 48
        charge.chargeCurrentRequest = 32
        charge.chargeCurrentRequestMax = 48
        charge.chargingAmps = 32
        charge.fastChargerPresent = true
        var type = CarServer_ChargeState.ChargerType()
        type.type = .supercharger(CarServer_Void())
        charge.fastChargerType = type
        charge.scheduledChargingPending = false
        charge.chargePortColdWeatherMode = true
        var latch = CarServer_ChargePortLatchState()
        latch.type = .engaged(CarServer_Void())
        charge.chargePortLatch = latch
        data.chargeState = charge

        let c = VehicleSnapshotMapper.map(data).charge
        XCTAssertEqual(c?.usableBatteryLevel, 70)
        XCTAssertEqual(c?.idealBatteryRangeMiles, 260)
        XCTAssertEqual(c?.chargeEnergyAddedKWh, 12.5)
        XCTAssertEqual(c?.chargeMilesAddedRated, 48)
        XCTAssertEqual(c?.minutesToChargeLimit, 35)
        XCTAssertEqual(c?.chargerPhases, 3)
        XCTAssertEqual(c?.chargerPilotCurrent, 48)
        XCTAssertEqual(c?.chargeCurrentRequest, 32)
        XCTAssertEqual(c?.chargeCurrentRequestMax, 48)
        XCTAssertEqual(c?.chargingAmps, 32)
        XCTAssertEqual(c?.fastChargerPresent, true)
        XCTAssertEqual(c?.fastChargerType, .supercharger)
        XCTAssertEqual(c?.scheduledChargingPending, false)
        XCTAssertEqual(c?.chargePortColdWeatherMode, true)
        XCTAssertEqual(c?.chargePortLatched, true)
    }

    func testClimateExtras() {
        var data = CarServer_VehicleData()
        var climate = CarServer_ClimateState()
        climate.isFrontDefrosterOn = true
        climate.isRearDefrosterOn = false
        climate.minAvailTempCelsius = 15
        climate.maxAvailTempCelsius = 28
        climate.seatHeaterRearLeftBack = 1
        climate.seatHeaterThirdRowRight = 3
        climate.seatFanFrontLeft = 2
        climate.seatFanFrontRight = 0
        climate.steeringWheelHeatLevel = .high
        climate.autoSteeringWheelHeat = true
        climate.autoSeatClimateLeft = true
        climate.wiperBladeHeater = false
        climate.sideMirrorHeaters = true
        climate.isPreconditioning = true
        climate.isAutoConditioningOn = true
        climate.batteryHeaterNoPower = false
        var keeper = CarServer_ClimateState.ClimateKeeperMode()
        keeper.type = .party(CarServer_Void())
        climate.climateKeeperMode = keeper
        climate.cabinOverheatProtection = .cabinOverheatProtectionFanOnly
        climate.cabinOverheatProtectionActivelyCooling = true
        data.climateState = climate

        let c = VehicleSnapshotMapper.map(data).climate
        XCTAssertEqual(c?.isFrontDefrosterOn, true)
        XCTAssertEqual(c?.isRearDefrosterOn, false)
        XCTAssertEqual(c?.minAvailableTempCelsius, 15)
        XCTAssertEqual(c?.maxAvailableTempCelsius, 28)
        XCTAssertEqual(c?.seatHeaterRearLeftBack, .low)
        XCTAssertEqual(c?.seatHeaterThirdRowRight, .high)
        XCTAssertEqual(c?.seatFanFrontLeft, 2)
        XCTAssertEqual(c?.seatFanFrontRight, 0)
        XCTAssertEqual(c?.steeringWheelHeatLevel, .high)
        XCTAssertEqual(c?.autoSteeringWheelHeat, true)
        XCTAssertEqual(c?.autoSeatClimateLeft, true)
        XCTAssertNil(c?.autoSeatClimateRight)
        XCTAssertEqual(c?.wiperBladeHeater, false)
        XCTAssertEqual(c?.sideMirrorHeaters, true)
        XCTAssertEqual(c?.isPreconditioning, true)
        XCTAssertEqual(c?.isAutoConditioningOn, true)
        XCTAssertEqual(c?.batteryHeaterNoPower, false)
        XCTAssertEqual(c?.climateKeeperMode, .camp)
        XCTAssertEqual(c?.cabinOverheatProtection, .fanOnly)
        XCTAssertEqual(c?.cabinOverheatProtectionActivelyCooling, true)
    }

    func testClosuresExtras() {
        var data = CarServer_VehicleData()
        var closures = CarServer_ClosuresState()
        var sentry = CarServer_ClosuresState.SentryModeState()
        sentry.type = .aware(CarServer_Void())
        closures.sentryModeState = sentry
        closures.sentryModeAvailable = true
        var display = CarServer_ClosuresState.DisplayState()
        display.type = .driving(CarServer_Void())
        closures.centerDisplayState = display
        closures.remoteStart = false
        closures.valetPinNeeded = true
        var limit = CarServer_SpeedLimitMode()
        limit.active = true
        limit.currentLimitMph = 65
        limit.maxLimitMph = 90
        closures.speedLimitMode = limit
        closures.tonneauPercentOpen = 40
        closures.tonneauInMotion = true
        data.closuresState = closures

        let c = VehicleSnapshotMapper.map(data).closures
        XCTAssertEqual(c?.sentryMode, .aware)
        XCTAssertEqual(c?.sentryModeActive, true)
        XCTAssertEqual(c?.sentryModeAvailable, true)
        XCTAssertEqual(c?.centerDisplayState, .driving)
        XCTAssertEqual(c?.remoteStart, false)
        XCTAssertEqual(c?.valetPinNeeded, true)
        XCTAssertEqual(c?.speedLimitMode?.active, true)
        XCTAssertEqual(c?.speedLimitMode?.currentLimitMph, 65)
        XCTAssertEqual(c?.speedLimitMode?.maxLimitMph, 90)
        XCTAssertNil(c?.speedLimitMode?.minLimitMph)
        XCTAssertEqual(c?.tonneauPercentOpen, 40)
        XCTAssertEqual(c?.tonneauInMotion, true)
    }

    func testSoftwareUpdateExtras() {
        var data = CarServer_VehicleData()
        var update = CarServer_SoftwareUpdateState()
        var status = CarServer_SoftwareUpdateState.SoftwareUpdateStatus()
        status.type = .scheduled(CarServer_Void())
        update.status = status
        update.scheduledTimeMs = 1_700_000_000_000
        update.warningTimeRemainingMs = 90000
        data.softwareUpdateState = update

        let s = VehicleSnapshotMapper.map(data).softwareUpdate
        XCTAssertEqual(s?.status, .scheduled)
        XCTAssertEqual(s?.scheduledTime, Date(timeIntervalSince1970: 1_700_000_000))
        XCTAssertEqual(s?.warningTimeRemainingSeconds, 90)
    }
}
