import Foundation

/// Doors, windows, trunks, sunroof, and security/occupancy status.
public struct ClosuresState: Sendable, Equatable {
    /// `true` if the front-left door is open. Nil if the vehicle did not report this field.
    public var frontDriverDoor: Bool?
    /// `true` if the front-right door is open. Nil if the vehicle did not report this field.
    public var frontPassengerDoor: Bool?
    /// `true` if the rear-left door is open. Nil if the vehicle did not report this field.
    public var rearDriverDoor: Bool?
    /// `true` if the rear-right door is open. Nil if the vehicle did not report this field.
    public var rearPassengerDoor: Bool?
    /// `true` if the front trunk (frunk) is open. Nil if the vehicle did not report this field.
    public var frontTrunk: Bool?
    /// `true` if the rear trunk is open. Nil if the vehicle did not report this field.
    public var rearTrunk: Bool?
    /// `true` if the vehicle is currently locked. Nil if the vehicle did not report this field.
    public var locked: Bool?
    /// `true` if the front-left window is not fully closed. Nil if the vehicle did not report this field.
    public var windowDriverFront: Bool?
    /// `true` if the front-right window is not fully closed. Nil if the vehicle did not report this field.
    public var windowPassengerFront: Bool?
    /// `true` if the rear-left window is not fully closed. Nil if the vehicle did not report this field.
    public var windowDriverRear: Bool?
    /// `true` if the rear-right window is not fully closed. Nil if the vehicle did not report this field.
    public var windowPassengerRear: Bool?
    /// Current sunroof position state. Nil if the vehicle did not report this field or has no sunroof.
    public var sunroofState: SunroofState?
    /// Sunroof aperture as a percentage (0 = closed, 100 = fully open). Nil if the vehicle did not report this field.
    public var sunroofPercentOpen: Int?
    /// Whether Sentry Mode is currently armed/active. Nil if the vehicle did not report this field.
    public var sentryModeActive: Bool?
    /// Whether Valet Mode is enabled. Nil if the vehicle did not report this field.
    public var valetMode: Bool?
    /// Whether the vehicle detects an occupant present. Nil if the vehicle did not report this field.
    public var isUserPresent: Bool?

    /// Sunroof position state.
    public enum SunroofState: Sendable, Equatable {
        /// Fully closed.
        case closed
        /// Fully open (slid back).
        case open
        /// In vent / tilt position.
        case vent
        /// Actively moving between positions.
        case moving
        /// Performing a calibration cycle.
        case calibrating
        /// State not reported or unrecognized by the vehicle.
        case unknown
    }

    /// Detailed sentry mode state; ``sentryModeActive`` is its on/off summary. Nil if the vehicle did not report
    /// this field.
    public var sentryMode: SentryMode? = nil
    /// Whether sentry mode is available on this vehicle. Nil if the vehicle did not report this field.
    public var sentryModeAvailable: Bool? = nil
    /// What the center display is showing. Nil if the vehicle did not report this field.
    public var centerDisplayState: CenterDisplayState? = nil
    /// Whether keyless driving (remote start) is active. Nil if the vehicle did not report this field.
    public var remoteStart: Bool? = nil
    /// Whether leaving valet mode needs a PIN. Nil if the vehicle did not report this field.
    public var valetPinNeeded: Bool? = nil
    /// Owner-set Speed Limit Mode. This is not the posted road speed limit. Nil if the vehicle did not report
    /// this field.
    public var speedLimitMode: SpeedLimitMode? = nil
    /// Cybertruck tonneau cover position, 0–100. Nil if the vehicle did not report this field.
    public var tonneauPercentOpen: Int? = nil
    /// Whether the tonneau cover is moving. Nil if the vehicle did not report this field.
    public var tonneauInMotion: Bool? = nil

    /// Sentry mode state.
    public enum SentryMode: Sendable, Equatable {
        case off
        case idle
        case armed
        case aware
        case panic
        case quiet
    }

    /// Center display state.
    public enum CenterDisplayState: Sendable, Equatable {
        case off
        case dim
        case accessory
        case on
        case driving
        case charging
        case lock
        case sentry
        case dog
        case entertainment
    }

    /// Owner-set Speed Limit Mode settings.
    public struct SpeedLimitMode: Sendable, Equatable {
        /// Whether Speed Limit Mode is on.
        public var active: Bool?
        /// Whether a PIN has been set.
        public var pinCodeSet: Bool?
        /// The limit the owner chose, in mph.
        public var currentLimitMph: Double?
        /// Lowest limit the vehicle allows, in mph.
        public var minLimitMph: Double?
        /// Highest limit the vehicle allows, in mph.
        public var maxLimitMph: Double?

        public init(
            active: Bool? = nil,
            pinCodeSet: Bool? = nil,
            currentLimitMph: Double? = nil,
            minLimitMph: Double? = nil,
            maxLimitMph: Double? = nil,
        ) {
            self.active = active
            self.pinCodeSet = pinCodeSet
            self.currentLimitMph = currentLimitMph
            self.minLimitMph = minLimitMph
            self.maxLimitMph = maxLimitMph
        }
    }

    public init(
        frontDriverDoor: Bool? = nil,
        frontPassengerDoor: Bool? = nil,
        rearDriverDoor: Bool? = nil,
        rearPassengerDoor: Bool? = nil,
        frontTrunk: Bool? = nil,
        rearTrunk: Bool? = nil,
        locked: Bool? = nil,
        windowDriverFront: Bool? = nil,
        windowPassengerFront: Bool? = nil,
        windowDriverRear: Bool? = nil,
        windowPassengerRear: Bool? = nil,
        sunroofState: SunroofState? = nil,
        sunroofPercentOpen: Int? = nil,
        sentryModeActive: Bool? = nil,
        valetMode: Bool? = nil,
        isUserPresent: Bool? = nil,
    ) {
        self.frontDriverDoor = frontDriverDoor
        self.frontPassengerDoor = frontPassengerDoor
        self.rearDriverDoor = rearDriverDoor
        self.rearPassengerDoor = rearPassengerDoor
        self.frontTrunk = frontTrunk
        self.rearTrunk = rearTrunk
        self.locked = locked
        self.windowDriverFront = windowDriverFront
        self.windowPassengerFront = windowPassengerFront
        self.windowDriverRear = windowDriverRear
        self.windowPassengerRear = windowPassengerRear
        self.sunroofState = sunroofState
        self.sunroofPercentOpen = sunroofPercentOpen
        self.sentryModeActive = sentryModeActive
        self.valetMode = valetMode
        self.isUserPresent = isUserPresent
    }
}
