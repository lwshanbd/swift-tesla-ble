import Foundation

/// Installed firmware version and in-progress software update status.
public struct SoftwareUpdateState: Sendable, Equatable {
    /// Current installed firmware version string. Nil if the vehicle did not report this field.
    public var version: String?
    /// Download progress of a pending update in percent (0–100). Nil if the vehicle did not report this field.
    public var downloadPercent: Int?
    /// Install progress of a pending update in percent (0–100). Nil if the vehicle did not report this field.
    public var installPercent: Int?
    /// Expected total install duration in seconds. Nil if the vehicle did not report this field.
    public var expectedDurationSeconds: Int?

    /// Update lifecycle status. Nil if the vehicle did not report this field.
    public var status: Status? = nil
    /// When an update is scheduled to install. Nil if the vehicle did not report this field.
    public var scheduledTime: Date? = nil
    /// Seconds left in the pre-install warning countdown. Nil if the vehicle did not report this field.
    public var warningTimeRemainingSeconds: Int? = nil

    /// Software update lifecycle status.
    public enum Status: Sendable, Equatable {
        case none
        case downloading
        case downloadingWifiWait
        case available
        case scheduled
        case installing
    }

    public init(
        version: String? = nil,
        downloadPercent: Int? = nil,
        installPercent: Int? = nil,
        expectedDurationSeconds: Int? = nil,
    ) {
        self.version = version
        self.downloadPercent = downloadPercent
        self.installPercent = installPercent
        self.expectedDurationSeconds = expectedDurationSeconds
    }
}
