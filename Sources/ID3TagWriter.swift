import Foundation

enum ID3TagWriter {
    static func write(title: String, artist: String, album: String, artwork: Data?, to url: URL) throws {
        let original = try Data(contentsOf: url)
        let audioStart = existingTagLength(in: original)
        let audio = original.subdata(in: audioStart..<original.count)

        var frames = Data()
        frames.append(textFrame(id: "TIT2", value: title))
        frames.append(textFrame(id: "TPE1", value: artist))
        frames.append(textFrame(id: "TALB", value: album))
        if let artwork {
            frames.append(pictureFrame(artwork))
        }

        var tag = Data("ID3".utf8)
        tag.append(contentsOf: [3, 0, 0]) // ID3v2.3, no flags
        tag.append(contentsOf: syncSafe(frames.count))
        tag.append(frames)
        tag.append(audio)
        try tag.write(to: url, options: .atomic)
    }

    private static func existingTagLength(in data: Data) -> Int {
        guard data.count >= 10,
              data[0] == 0x49, data[1] == 0x44, data[2] == 0x33 else { return 0 }
        let size = (Int(data[6] & 0x7f) << 21)
            | (Int(data[7] & 0x7f) << 14)
            | (Int(data[8] & 0x7f) << 7)
            | Int(data[9] & 0x7f)
        return min(data.count, 10 + size)
    }

    private static func textFrame(id: String, value: String) -> Data {
        guard !value.isEmpty else { return Data() }
        var payload = Data([1]) // UTF-16 with BOM
        payload.append(value.data(using: .utf16) ?? Data())
        return frame(id: id, payload: payload)
    }

    private static func pictureFrame(_ image: Data) -> Data {
        let isPNG = image.prefix(8) == Data([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a])
        var payload = Data([0])
        payload.append(Data((isPNG ? "image/png" : "image/jpeg").utf8))
        payload.append(0)
        payload.append(3) // front cover
        payload.append(0) // empty description
        payload.append(image)
        return frame(id: "APIC", payload: payload)
    }

    private static func frame(id: String, payload: Data) -> Data {
        var output = Data(id.utf8)
        let size = UInt32(payload.count)
        output.append(contentsOf: [
            UInt8((size >> 24) & 0xff), UInt8((size >> 16) & 0xff),
            UInt8((size >> 8) & 0xff), UInt8(size & 0xff), 0, 0
        ])
        output.append(payload)
        return output
    }

    private static func syncSafe(_ value: Int) -> [UInt8] {
        [
            UInt8((value >> 21) & 0x7f), UInt8((value >> 14) & 0x7f),
            UInt8((value >> 7) & 0x7f), UInt8(value & 0x7f)
        ]
    }
}
