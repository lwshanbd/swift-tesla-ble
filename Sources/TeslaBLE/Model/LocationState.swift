import Foundation

/// A latitude and longitude in degrees (WGS-84).
public struct Coordinate: Sendable, Equatable {
    /// Latitude in degrees.
    public var latitude: Double
    /// Longitude in degrees.
    public var longitude: Double

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

/// GPS position, heading and place information reported by the vehicle.
public struct LocationState: Sendable, Equatable {
    /// Raw GPS position. Nil if the vehicle did not report this field.
    public var coordinate: Coordinate?
    /// GPS heading in degrees, 0–359, clockwise from north. Nil if the vehicle did not report this field.
    public var headingDegrees: Int?
    /// When the GPS fix was taken. Nil if the vehicle did not report this field.
    public var gpsAsOf: Date?
    /// Position from the vehicle's own location estimator. Nil if the vehicle did not report this field.
    public var estimatedCoordinate: Coordinate?
    /// Heading from the vehicle's own location estimator, in degrees. Nil if the vehicle did not report this
    /// field.
    public var estimatedHeadingDegrees: Double?
    /// Elevation from the vehicle's location estimator. Nil if the vehicle did not report this field.
    public var elevation: Double?
    /// Accuracy of the estimated position. Nil if the vehicle did not report this field.
    public var accuracy: Double?
    /// Name of the current place, such as a saved location. Nil if the vehicle did not report this field.
    public var locationName: String?
    /// Whether a HomeLink device is in range. Nil if the vehicle did not report this field.
    public var homelinkNearby: Bool?

    public init(
        coordinate: Coordinate? = nil,
        headingDegrees: Int? = nil,
        gpsAsOf: Date? = nil,
        estimatedCoordinate: Coordinate? = nil,
        estimatedHeadingDegrees: Double? = nil,
        elevation: Double? = nil,
        accuracy: Double? = nil,
        locationName: String? = nil,
        homelinkNearby: Bool? = nil,
    ) {
        self.coordinate = coordinate
        self.headingDegrees = headingDegrees
        self.gpsAsOf = gpsAsOf
        self.estimatedCoordinate = estimatedCoordinate
        self.estimatedHeadingDegrees = estimatedHeadingDegrees
        self.elevation = elevation
        self.accuracy = accuracy
        self.locationName = locationName
        self.homelinkNearby = homelinkNearby
    }
}
