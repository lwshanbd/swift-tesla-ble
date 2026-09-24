# TeslaBLEDemo

A minimal SwiftUI example app exercising the `TeslaBLE` package against a real Tesla vehicle. The app covers:

- First-time BLE pairing (`connect(mode: .pairing)` + unsigned `addKey` + reconnect-until-active).
- Reading drive state (`fetchDrive()`) and charge state (`fetch(.categories([.charge]))`) with pull-to-refresh and an opt-in **Live** toggle that polls both (drive every 500 ms and charge every 5 s by default, each adjustable).
- A landscape instrument cluster for drive and charge state on iPhone.
- Two signed commands: `security.unlock` and `actions.honk`.

## Running

1. Open `Examples/TeslaBLEDemo/TeslaBLEDemo.xcodeproj` in Xcode 26.2 or later.
2. Select the `TeslaBLEDemo` scheme.
3. In **Signing & Capabilities**, set a development team — automatic signing is on; no team is baked into the committed project.
4. Build and run on a real iOS 26.2+ device. CoreBluetooth does not work in the simulator.
5. Enter your vehicle's 17-character VIN, tap **Start pairing**, and follow the prompt on the car's center console (tap your existing owner key card).
6. After authorization completes, the app keeps retrying the signed handshake until the new key is active, then the dashboard auto-connects. Pull to refresh or flip **Live** to read drive and charge state, and rotate an iPhone to landscape for the instrument cluster; use **Unlock** and **Honk** to prove the signed command path.

## Caveats

- The keypair is stored in the Keychain with `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`. It is not included in iCloud or device backups; restoring to a new device requires re-pairing.
- The demo runs foreground-only. Background BLE is out of scope.
- The demo is single-vehicle. Use **Forget this vehicle** to clear the stored key + VIN and re-pair a different car.
