import Foundation

/// Current battery and charge-port status reported by the vehicle.
public struct ChargeState: Sendable, Equatable {
    /// State of charge in percent (0–100). Nil if the vehicle did not report this field.
    public var batteryLevel: Int?
    /// Rated remaining range in miles. Nil if the vehicle did not report this field.
    public var batteryRangeMiles: Double?
    /// Estimated remaining range in miles based on recent driving. Nil if the vehicle did not report this field.
    public var estBatteryRangeMiles: Double?
    /// Current charging session status. Nil if the vehicle did not report this field.
    public var chargingStatus: ChargingStatus?
    /// Charger voltage in volts. Nil if the vehicle did not report this field.
    public var chargerVoltage: Int?
    /// Charger actual current in amps. Nil if the vehicle did not report this field.
    public var chargerCurrent: Int?
    /// Charger power in kilowatts. Nil if the vehicle did not report this field.
    public var chargerPower: Int?
    /// User-configured charge limit in percent (0–100). Nil if the vehicle did not report this field.
    public var chargeLimitPercent: Int?
    /// Estimated minutes remaining until charging completes. Nil if the vehicle did not report this field.
    public var minutesToFullCharge: Int?
    /// Range added per hour of charging, in miles per hour. Nil if the vehicle did not report this field.
    public var chargeRateMph: Double?
    /// Whether the charge port door is physically open. Nil if the vehicle did not report this field.
    public var chargePortOpen: Bool?
    /// Whether the charge port latch is engaged on the connector. Nil if the vehicle did not report this field.
    public var chargePortLatched: Bool?

    /// High-level charging session state.
    public enum ChargingStatus: Sendable, Equatable {
        /// No charge cable connected.
        case disconnected
        /// Actively drawing power from the charger.
        case charging
        /// Charging session finished (battery reached target SoC).
        case complete
        /// Charging paused or stopped by the user or vehicle.
        case stopped
        /// Handshake in progress, not yet drawing power.
        case starting
    }

    /// Charge percentage usable right now; lower than ``batteryLevel`` when the pack is cold. Nil if the vehicle
    /// did not report this field.
    public var usableBatteryLevel: Int? = nil
    /// Ideal range in miles. Nil if the vehicle did not report this field.
    public var idealBatteryRangeMiles: Double? = nil
    /// Energy added in the current or most recent charging session, in kWh. Nil if the vehicle did not report
    /// this field.
    public var chargeEnergyAddedKWh: Double? = nil
    /// Rated range added in the current or most recent charging session, in miles. Nil if the vehicle did not
    /// report this field.
    public var chargeMilesAddedRated: Double? = nil
    /// Estimated minutes until the charge limit is reached. Nil if the vehicle did not report this field.
    public var minutesToChargeLimit: Int? = nil
    /// Number of AC phases in use. Nil if the vehicle did not report this field.
    public var chargerPhases: Int? = nil
    /// Current offered by the charger (pilot), in amps. Nil if the vehicle did not report this field.
    public var chargerPilotCurrent: Int? = nil
    /// Requested charging current, in amps. Nil if the vehicle did not report this field.
    public var chargeCurrentRequest: Int? = nil
    /// Maximum charging current the vehicle may request, in amps. Nil if the vehicle did not report this field.
    public var chargeCurrentRequestMax: Int? = nil
    /// Charging current set by the user, in amps. Nil if the vehicle did not report this field.
    public var chargingAmps: Int? = nil
    /// Whether a DC fast charger is connected. Nil if the vehicle did not report this field.
    public var fastChargerPresent: Bool? = nil
    /// Kind of DC fast charger connected. Nil if the vehicle did not report this field.
    public var fastChargerType: FastChargerType? = nil
    /// Whether a scheduled charge is waiting to start. Nil if the vehicle did not report this field.
    public var scheduledChargingPending: Bool? = nil
    /// Whether the charge port is in cold weather mode. Nil if the vehicle did not report this field.
    public var chargePortColdWeatherMode: Bool? = nil

    /// DC fast charger kind.
    public enum FastChargerType: Sendable, Equatable {
        case supercharger
        case chademo
        case gb
        case combo
        case acSingleWireCAN
        case mcSingleWireCAN
        case tesla
        case other
    }

    public init(
        batteryLevel: Int? = nil,
        batteryRangeMiles: Double? = nil,
        estBatteryRangeMiles: Double? = nil,
        chargingStatus: ChargingStatus? = nil,
        chargerVoltage: Int? = nil,
        chargerCurrent: Int? = nil,
        chargerPower: Int? = nil,
        chargeLimitPercent: Int? = nil,
        minutesToFullCharge: Int? = nil,
        chargeRateMph: Double? = nil,
        chargePortOpen: Bool? = nil,
        chargePortLatched: Bool? = nil,
    ) {
        self.batteryLevel = batteryLevel
        self.batteryRangeMiles = batteryRangeMiles
        self.estBatteryRangeMiles = estBatteryRangeMiles
        self.chargingStatus = chargingStatus
        self.chargerVoltage = chargerVoltage
        self.chargerCurrent = chargerCurrent
        self.chargerPower = chargerPower
        self.chargeLimitPercent = chargeLimitPercent
        self.minutesToFullCharge = minutesToFullCharge
        self.chargeRateMph = chargeRateMph
        self.chargePortOpen = chargePortOpen
        self.chargePortLatched = chargePortLatched
    }
}
