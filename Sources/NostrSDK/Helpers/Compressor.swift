import Foundation
import Compression

public enum CompressorError: Error {
    case compressionFailed
    case decompressionFailed
}

public class Compressor {
    
    // MARK: - ZLib
        
    static func decompressWithZLib(_ data: Data) throws -> Data {
        return try decompress(data, algorithm: COMPRESSION_ZLIB)
    }

    // MARK: - Brotli
    
    static func decompressWithBrotli(_ data: Data) throws -> Data {
        return try decompress(data, algorithm: COMPRESSION_BROTLI)
    }

    // MARK: - Internal Compression Logic
        
    private static func decompress(_ data: Data, algorithm: compression_algorithm) throws -> Data {
        let destinationBufferSize = 1_000_000
        var decompressed = Data()

        try data.withUnsafeBytes { (sourcePointer: UnsafeRawBufferPointer) in
            let source = sourcePointer.bindMemory(to: UInt8.self).baseAddress!
            let sourceSize = data.count

            let destinationBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: destinationBufferSize)
            defer { destinationBuffer.deallocate() }

            let decompressedSize = compression_decode_buffer(
                destinationBuffer,
                destinationBufferSize,
                source,
                sourceSize,
                nil,
                algorithm
            )

            guard decompressedSize > 0 else {
                throw CompressorError.decompressionFailed
            }

            decompressed.append(destinationBuffer, count: decompressedSize)
        }

        return decompressed
    }
}
