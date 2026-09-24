# Development Conventions

swift-tesla-ble is an SDK: a SwiftPM package (Swift 6.2) whose `TeslaBLE`
library lets iOS apps control Tesla vehicles over Bluetooth LE. iOS 17 is the
product platform; macOS 13 is declared only so the unit suite also runs on a
Mac host. `Examples/TeslaBLEDemo` is a demo iOS app that consumes the SDK by
local path.

## Where to look

- `README.md` § Usage and § Command surface for the public API;
  § Architecture for the source layout.
- `docs/superpowers/specs/` and `docs/superpowers/plans/` for the design
  behind an existing feature. They record the design as first written; where
  they differ from the code, the code wins.
- `Vendor/tesla-vehicle-command`, the Go reference (Tesla's implementation,
  a git submodule), for wire format, crypto, session, and command semantics.
  The Swift port follows `internal/authentication/`, `internal/dispatcher/`,
  `pkg/protocol/`, `pkg/vehicle/`, and `pkg/connector/ble/`. A new worktree
  does not check out the submodule: read it from the main checkout, but run
  `git submodule update --init` in the worktree before a task runs anything
  from it (`make proto`, fixture regeneration).
- `Examples/TeslaBLEDemo/README.md` for the demo app.

## Ground rules

- The main checkout is the user's live workspace: its working tree and index
  are read-only. Anything that leaves them untouched may run there; anything
  that would change them belongs in a linked worktree created from the
  latest `main` (`.worktrees/<branch>`, or the harness's native worktree
  tool). The final squash-merge is the only exception.
- Commits follow Conventional Commits (the `conventional-commit` skill;
  titles of at most 50 characters) and carry a `Co-authored-by` trailer. Run
  `make format` before each commit on the branch.
- Follow Apple's Swift API Design Guidelines and match the surrounding code.

## SDK rules

- Every `public` declaration is a contract with host apps. Hand-written
  public API takes and returns Swift-native types; `VehicleQueryResult`,
  which wraps raw protobuf messages by design, is the only exception, and
  new API adds no more. When a change alters public API or documented
  behavior, update the DocC comments and `README.md` and describe the change
  in the commit body; mark a source-breaking change with `!` and a
  `BREAKING CHANGE:` footer.
- Protocol behavior must match the Go reference byte for byte. The fixture
  vectors are ground truth: when one fails, fix the Swift code. Change a
  vector only as `Tests/TeslaBLETests/Fixtures/README.md` describes.
- Never hand-edit `Sources/TeslaBLE/Generated/`; regenerate it with
  `make proto` (`README.md` § Regenerating). The generated types are public,
  so a regeneration that changes them changes public API. Leave `Vendor/`
  clean: `.gitmodules` sets `ignore = all`, so `git status` hides changes
  there; check with `git -C Vendor/tesla-vehicle-command status`.
- SDK code logs only through `Log` and `LogMessage`, whose interpolation
  whitelist keeps VINs, keys, and payloads out of logs. Every `LogSafe`
  conformance lives in `LogMessage.swift` and must preserve that guarantee.

## Verification

The unit suite runs against a fake transport and committed fixtures and
needs no Bluetooth hardware or vehicle. Run it freely without asking.

Each worktree has its own iPhone simulator, named after the worktree:
create it with `xcrun simctl create <name> "<iPhone model>"`, which prints
its UDID, or reuse it if it already exists. Use it for every simulator step.
Do not use another simulator unless the user asks; a dedicated device keeps
concurrent worktrees from interfering with each other.

Every commit that touches `Sources/`, `Tests/`, or `Package.swift` must pass
the unit suite on both destinations:

- Mac host: `make test`, the same run as CI.
- iPhone simulator:

  ```sh
  xcodebuild test -scheme swift-tesla-ble \
    -destination "platform=iOS Simulator,id=<UDID>" \
    -skip-testing:TeslaBLETests/KeychainTeslaKeyStoreTests \
    -collect-test-diagnostics never
  ```

  The package test bundle has no host app, so Keychain calls fail there with
  `errSecMissingEntitlement` (-34018); `make test` covers those tests.
  `-collect-test-diagnostics never` keeps a failing run from stalling about
  ten minutes on diagnostics collection.

When the diff touches public API, `Package.swift`, or `Examples/`, also build
the demo app for the worktree's simulator:

```sh
xcodebuild build -project Examples/TeslaBLEDemo/TeslaBLEDemo.xcodeproj \
  -scheme TeslaBLEDemo -destination "platform=iOS Simulator,id=<UDID>"
```

For demo UI changes, run the app and check the affected screens with the
`sim-use` skill. CoreBluetooth does not work in the simulator, so screens
that need a vehicle connection cannot be reached there.

Neither destination exercises Bluetooth or the iOS Keychain. When the diff
changes transport, session, crypto, dispatcher, command encoding, response
decoding, or `KeychainTeslaKeyStore`, list in the report what needs checking
on real hardware with the demo app.

Whatever this section required for the diff must pass before the merge is
requested.

## Finishing a task

A task is done when the branch is squash-merged into `main` and the worktree
is gone. The only planned pause is the merge confirmation in step 3; do not
stop for approval anywhere else.

1. Run whatever Verification the diff requires, then have an independent
   reviewer with fresh context (a review subagent where the harness has one,
   otherwise a separate pass over the diff) read the full diff against the
   task and its spec in `docs/superpowers/specs/`, if any. Fix what it
   finds, rerun the affected tests, and re-review the fixes; stop once a
   pass raises nothing new, and list anything left on purpose in step 3.
2. Rebase onto the latest `main`. If the rebase pulled in or touched code,
   rerun whatever Verification required.
3. Report and wait for the user's go-ahead: the branch name, the commits
   (`git log --oneline main..HEAD`), what Verification ran and passed, any
   public API change (flag source-breaking ones), any review finding left
   unfixed, and what still needs checking on real hardware. Do not merge
   until the user confirms.
4. In the main checkout, confirm that `main` is checked out and nothing is
   staged (`git diff --cached --quiet`); otherwise report instead of
   merging. Run `git merge --squash <branch>` and commit with one
   Conventional Commits message for the whole branch, keeping any `!`,
   `BREAKING CHANGE:` footer, and public API notes. Never move `main` with
   plumbing (`commit-tree`, `update-ref`).
5. Delete the worktree's simulator (`xcrun simctl delete <UDID>`) and its
   DerivedData with the `xcode-derived-data` skill (pass the worktree's
   absolute path), then `git worktree remove` (`--force` if the submodule
   was initialized there) and `git branch -D`.

Questions, error reports, and review requests want analysis only: no file
edits and no git state changes unless asked.
