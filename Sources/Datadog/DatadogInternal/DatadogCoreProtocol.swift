/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at Datadog (https://www.datadoghq.com/).
 * Copyright 2019-2020 Datadog, Inc.
 */

import Foundation

public internal(set) var defaultDatadogCore: DatadogCoreProtocol = NOOPDatadogCore()

/// A Datadog Core holds a set of features and is responsible of managing their storage
/// and upload mechanism. It also provides a thread-safe scope for writing events.
public protocol DatadogCoreProtocol {
    // MARK: - V1 interface

    /// Registers a feature instance by its type description.
    ///
    /// - Parameter instance: The feaure instance to register
    func register<T>(feature instance: T?)

    /// Returns a Feature instance by its type.
    ///
    /// - Parameters:
    ///   - type: The feature instance type.
    /// - Returns: The feature if any.
    func feature<T>(_ type: T.Type) -> T?
}

/// Provide feature specific storage configuration.
internal struct FeatureStorageConfiguration {
    /// A set of paths for managing persisted data for this Feature.
    /// Each path is relative to the root folder of given SDK instance.
    struct Directories {
        /// The path for writing authorized data (when tracking consent is granted).
        let authorized: String
        /// The path for writing unauthorized data (when tracking consent is pending).
        let unauthorized: String
        /// The list of deprecated paths from previous versions of this feature. It is used to perform cleanup.
        let deprecated: [String]
    }

    /// Directories storing data for this Feature.
    let directories: Directories

    // MARK: - V1 interface

    /// A human-readable name of this Feature used for naming internal queues specific to this Feature and annotating
    /// origin of telemetry and verbosity logs produced by the SDK.
    let featureName: String
}

/// Provide feature specific upload configuration.
internal struct FeatureUploadConfiguration {
    // MARK: - V1 interface

    /// A human-readable name of this Feature used for naming internal queues specific to this Feature and annotating
    /// origin of telemetry and verbosity logs produced by the SDK.
    let featureName: String

    /// Creates the V1's `RequetsBuilder` for uploading data in this Feature.
    /// In V2 we will change it to build requests based on V2 context and batch metadata.
    let createRequestBuilder: (DatadogV1Context, Telemetry?) -> RequestBuilder

    /// Data format for constructing Feature payloads in V1. It is applied by the reader when reading data from batch and
    /// before passing it to the uploader.
    let payloadFormat: DataFormat
}

/// A datadog feature providing thread-safe scope for writing events.
public protocol FeatureScope {
    // TODO: RUMM-2133
}

/// No-op implementation of `DatadogFeatureRegistry`.
internal struct NOOPDatadogCore: DatadogCoreProtocol {
    // MARK: - V1 interface

    /// no-op
    func register<T>(feature instance: T?) {}

    /// no-op
    func feature<T>(_ type: T.Type) -> T? {
        return nil
    }
}
