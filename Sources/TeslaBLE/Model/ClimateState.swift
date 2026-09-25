import Foundation

/// Cabin climate, seat heater, and defrost status reported by the vehicle.
public struct ClimateState: Sendable, Equatable {
    /// Interior cabin temperature in degrees Celsius. Nil if the vehicle did not report this field.
    public var insideTempCelsius: Double?
    /// Exterior ambient temperature in degrees Celsius. Nil if the vehicle did not report this field.
    public var outsideTempCelsius: Double?
    /// Driver-side climate setpoint in degrees Celsius. Nil if the vehicle did not report this field.
    public var driverTempSettingCelsius: Double?
    /// Passenger-side climate setpoint in degrees Celsius. Nil if the vehicle did not report this field.
    public var passengerTempSettingCelsius: Double?
    /// HVAC fan level (raw vehicle scale, typically 0–7). Nil if the vehicle did not report this field.
    public var fanStatus: Int?
    /// Whether the HVAC system is currently running. Nil if the vehicle did not report this field.
    public var isClimateOn: Bool?
    /// Front-left seat heater level. Nil if the vehicle did not report this field.
    public var seatHeaterFrontLeft: SeatHeaterLevel?
    /// Front-right seat heater level. Nil if the vehicle did not report this field.
    public var seatHeaterFrontRight: SeatHeaterLevel?
    /// Rear-left seat heater level. Nil if the vehicle did not report this field.
    public var seatHeaterRearLeft: SeatHeaterLevel?
    /// Rear-center seat heater level. Nil if the vehicle did not report this field.
    public var seatHeaterRearCenter: SeatHeaterLevel?
    /// Rear-right seat heater level. Nil if the vehicle did not report this field.
    public var seatHeaterRearRight: SeatHeaterLevel?
    /// Whether the steering wheel heater is on. Nil if the vehicle did not report this field.
    public var steeringWheelHeater: Bool?
    /// Whether the high-voltage battery heater is active. Nil if the vehicle did not report this field.
    public var isBatteryHeaterOn: Bool?
    /// Whether defrost mode is active (normal or max). Nil if the vehicle did not report this field.
    public var defrostOn: Bool?
    /// Whether Bioweapon Defense Mode is on. Nil if the vehicle did not report this field.
    public var bioweaponMode: Bool?

    /// Seat heater intensity level.
    public enum SeatHeaterLevel: Int, Sendable, Equatable {
        /// Heater off.
        case off = 0
        /// Low heat.
        case low = 1
        /// Medium heat.
        case medium = 2
        /// High heat.
        case high = 3
    }

    /// Whether the front defroster is on. Nil if the vehicle did not report this field.
    public var isFrontDefrosterOn: Bool? = nil
    /// Whether the rear defroster is on. Nil if the vehicle did not report this field.
    public var isRearDefrosterOn: Bool? = nil
    /// Lowest cabin setpoint the vehicle accepts, in °C. Nil if the vehicle did not report this field.
    public var minAvailableTempCelsius: Double? = nil
    /// Highest cabin setpoint the vehicle accepts, in °C. Nil if the vehicle did not report this field.
    public var maxAvailableTempCelsius: Double? = nil
    /// Rear left-back seat heater level. Nil if the vehicle did not report this field.
    public var seatHeaterRearLeftBack: SeatHeaterLevel? = nil
    /// Rear right-back seat heater level. Nil if the vehicle did not report this field.
    public var seatHeaterRearRightBack: SeatHeaterLevel? = nil
    /// Third-row left seat heater level. Nil if the vehicle did not report this field.
    public var seatHeaterThirdRowLeft: SeatHeaterLevel? = nil
    /// Third-row right seat heater level. Nil if the vehicle did not report this field.
    public var seatHeaterThirdRowRight: SeatHeaterLevel? = nil
    /// Front-left ventilated seat fan level, 0–3. Nil if the vehicle did not report this field.
    public var seatFanFrontLeft: Int? = nil
    /// Front-right ventilated seat fan level, 0–3. Nil if the vehicle did not report this field.
    public var seatFanFrontRight: Int? = nil
    /// Steering wheel heat level on vehicles with multi-level heating. Nil if the vehicle did not report this
    /// field.
    public var steeringWheelHeatLevel: SteeringWheelHeatLevel? = nil
    /// Whether the steering wheel heater is managed automatically. Nil if the vehicle did not report this field.
    public var autoSteeringWheelHeat: Bool? = nil
    /// Whether automatic seat climate is on for the driver seat. Nil if the vehicle did not report this field.
    public var autoSeatClimateLeft: Bool? = nil
    /// Whether automatic seat climate is on for the front passenger seat. Nil if the vehicle did not report
    /// this field.
    public var autoSeatClimateRight: Bool? = nil
    /// Whether the wiper blade heater is on. Nil if the vehicle did not report this field.
    public var wiperBladeHeater: Bool? = nil
    /// Whether the side mirror heaters are on. Nil if the vehicle did not report this field.
    public var sideMirrorHeaters: Bool? = nil
    /// Whether the cabin is preconditioning. Nil if the vehicle did not report this field.
    public var isPreconditioning: Bool? = nil
    /// Whether automatic HVAC conditioning is on. Nil if the vehicle did not report this field.
    public var isAutoConditioningOn: Bool? = nil
    /// Whether the battery heater wants power but has none. Nil if the vehicle did not report this field.
    public var batteryHeaterNoPower: Bool? = nil
    /// Climate keeper mode (Keep, Dog, Camp). Nil if the vehicle did not report this field.
    public var climateKeeperMode: ClimateKeeperMode? = nil
    /// Cabin overheat protection setting. Nil if the vehicle did not report this field.
    public var cabinOverheatProtection: CabinOverheatProtection? = nil
    /// Whether cabin overheat protection is cooling right now. Nil if the vehicle did not report this field.
    public var cabinOverheatProtectionActivelyCooling: Bool? = nil

    /// Steering wheel heat level.
    public enum SteeringWheelHeatLevel: Sendable, Equatable {
        case off
        case low
        case high
        case unknown
    }

    /// Climate keeper mode.
    public enum ClimateKeeperMode: Sendable, Equatable {
        case off
        case on
        case dog
        case camp
        case unknown
    }

    /// Cabin overheat protection setting.
    public enum CabinOverheatProtection: Sendable, Equatable {
        case off
        case on
        case fanOnly
        case unknown
    }

    public init(
        insideTempCelsius: Double? = nil,
        outsideTempCelsius: Double? = nil,
        driverTempSettingCelsius: Double? = nil,
        passengerTempSettingCelsius: Double? = nil,
        fanStatus: Int? = nil,
        isClimateOn: Bool? = nil,
        seatHeaterFrontLeft: SeatHeaterLevel? = nil,
        seatHeaterFrontRight: SeatHeaterLevel? = nil,
        seatHeaterRearLeft: SeatHeaterLevel? = nil,
        seatHeaterRearCenter: SeatHeaterLevel? = nil,
        seatHeaterRearRight: SeatHeaterLevel? = nil,
        steeringWheelHeater: Bool? = nil,
        isBatteryHeaterOn: Bool? = nil,
        defrostOn: Bool? = nil,
        bioweaponMode: Bool? = nil,
    ) {
        self.insideTempCelsius = insideTempCelsius
        self.outsideTempCelsius = outsideTempCelsius
        self.driverTempSettingCelsius = driverTempSettingCelsius
        self.passengerTempSettingCelsius = passengerTempSettingCelsius
        self.fanStatus = fanStatus
        self.isClimateOn = isClimateOn
        self.seatHeaterFrontLeft = seatHeaterFrontLeft
        self.seatHeaterFrontRight = seatHeaterFrontRight
        self.seatHeaterRearLeft = seatHeaterRearLeft
        self.seatHeaterRearCenter = seatHeaterRearCenter
        self.seatHeaterRearRight = seatHeaterRearRight
        self.steeringWheelHeater = steeringWheelHeater
        self.isBatteryHeaterOn = isBatteryHeaterOn
        self.defrostOn = defrostOn
        self.bioweaponMode = bioweaponMode
    }
}
