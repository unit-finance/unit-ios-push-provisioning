//
//  UNAppEntitlements.swift
//  UnitPushProvisioning
//

import Foundation
import MachO

/// Reads the host app's own entitlements. iOS has no API for this, so they are read from the app binary:
/// simulator builds embed them as a plist section, device builds carry them in the code signature.
enum UNAppEntitlements {
    /// nil when the entitlements could not be read.
    static func current() -> [String: Any]? {
        #if targetEnvironment(simulator)
        return embeddedSection()
        #else
        guard let path = Bundle.main.executablePath else { return nil }
        return codeSignature(ofExecutableAt: path)
        #endif
    }

    static func embeddedSection() -> [String: Any]? {
        let executablePath = Bundle.main.executablePath
        for index in 0..<_dyld_image_count() {
            guard let name = _dyld_get_image_name(index), String(cString: name) == executablePath,
                  let header = _dyld_get_image_header(index) else { continue }
            var size: UInt = 0
            let section = header.withMemoryRebound(to: mach_header_64.self, capacity: 1) {
                getsectiondata($0, "__TEXT", "__entitlements", &size)
            }
            guard let section else { return nil }
            return propertyList(Data(bytes: section, count: Int(size)))
        }
        return nil
    }

    static func codeSignature(ofExecutableAt path: String) -> [String: Any]? {
        guard let binary = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe),
              let header: mach_header_64 = binary.read(at: 0), header.magic == MH_MAGIC_64 else { return nil }

        var offset = MemoryLayout<mach_header_64>.size
        for _ in 0..<header.ncmds {
            guard let command: load_command = binary.read(at: offset), command.cmdsize > 0 else { return nil }
            if command.cmd == UInt32(LC_CODE_SIGNATURE) {
                guard let signature: linkedit_data_command = binary.read(at: offset),
                      let blob = binary.slice(at: Int(signature.dataoff), count: Int(signature.datasize)) else { return nil }
                return entitlements(inSignature: blob)
            }
            offset += Int(command.cmdsize)
        }
        return nil
    }
}

private extension UNAppEntitlements {
    struct Signature {
        static let superBlobMagic: UInt32 = 0xfade0cc0
        static let entitlementsMagic: UInt32 = 0xfade7171
        static let entitlementsSlot: UInt32 = 5
    }

    // A signature is a big-endian table: magic, length, count, then (slot type, offset) pairs.
    // The entitlements blob is magic, length, then an XML plist. A signature without one has no entitlements.
    static func entitlements(inSignature blob: Data) -> [String: Any]? {
        guard blob.bigEndianUInt32(at: 0) == Signature.superBlobMagic,
              let count = blob.bigEndianUInt32(at: 8) else { return nil }

        for index in 0..<Int(count) {
            let entry = 12 + index * 8
            guard blob.bigEndianUInt32(at: entry) == Signature.entitlementsSlot else { continue }
            guard let start = blob.bigEndianUInt32(at: entry + 4).map(Int.init),
                  blob.bigEndianUInt32(at: start) == Signature.entitlementsMagic,
                  let length = blob.bigEndianUInt32(at: start + 4).map(Int.init), length >= 8,
                  let plist = blob.slice(at: start + 8, count: length - 8) else { return nil }
            return propertyList(plist)
        }
        return [:]
    }

    static func propertyList(_ data: Data) -> [String: Any]? {
        (try? PropertyListSerialization.propertyList(from: data, format: nil)) as? [String: Any]
    }
}

private extension Data {
    func slice(at offset: Int, count: Int) -> Data? {
        guard offset >= 0, count >= 0, offset <= self.count - count else { return nil }
        return subdata(in: (startIndex + offset)..<(startIndex + offset + count))
    }

    func read<T>(at offset: Int) -> T? {
        slice(at: offset, count: MemoryLayout<T>.size)?.withUnsafeBytes { $0.loadUnaligned(as: T.self) }
    }

    func bigEndianUInt32(at offset: Int) -> UInt32? {
        (read(at: offset) as UInt32?).map(UInt32.init(bigEndian:))
    }
}
