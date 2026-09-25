import Foundation

/// Basic now-playing media information and audio volume.
public struct MediaState: Sendable, Equatable {
    /// Artist name of the currently playing track. Nil if the vehicle did not report this field.
    public var nowPlayingArtist: String?
    /// Title of the currently playing track. Nil if the vehicle did not report this field.
    public var nowPlayingTitle: String?
    /// Current audio volume on the vehicle's raw scale. Nil if the vehicle did not report this field.
    public var audioVolume: Double?
    /// Maximum audio volume on the vehicle's raw scale. Nil if the vehicle did not report this field.
    public var audioVolumeMax: Double?
    /// Whether remote media control is currently permitted. Nil if the vehicle did not report this field.
    public var remoteControlEnabled: Bool?

    /// Whether media is playing, paused or stopped. Nil if the vehicle did not report this field.
    public var playbackStatus: PlaybackStatus? = nil
    /// The active media source. Nil if the vehicle did not report this field.
    public var nowPlayingSource: Source? = nil
    /// Volume step used by volume up and down. Nil if the vehicle did not report this field.
    public var audioVolumeIncrement: Double? = nil

    /// Media playback status.
    public enum PlaybackStatus: Sendable, Equatable {
        case stopped
        case playing
        case paused
    }

    /// Media source. Sources without a case here are reported as ``other(_:)`` with the protocol's raw value.
    public enum Source: Sendable, Equatable {
        case none
        case am
        case fm
        case xm
        case siriusXm
        case dab
        case bluetooth
        case localFiles
        case iPod
        case auxIn
        case spotify
        case tidal
        case tuneIn
        case slacker
        case stingray
        case onlineRadio
        case qqMusic
        case netEaseMusic
        case ximalaya
        case browser
        case theater
        case game
        case other(Int)
    }

    public init(
        nowPlayingArtist: String? = nil,
        nowPlayingTitle: String? = nil,
        audioVolume: Double? = nil,
        audioVolumeMax: Double? = nil,
        remoteControlEnabled: Bool? = nil,
    ) {
        self.nowPlayingArtist = nowPlayingArtist
        self.nowPlayingTitle = nowPlayingTitle
        self.audioVolume = audioVolume
        self.audioVolumeMax = audioVolumeMax
        self.remoteControlEnabled = remoteControlEnabled
    }
}
