/*
 This source file is part of the Swift.org open source project

 Copyright (c) 2021 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception

 See http://swift.org/LICENSE.txt for license information
 See http://swift.org/CONTRIBUTORS.txt for Swift project authors
 */

import struct Foundation.URL

import PackageCollectionsSigning
import TSCBasic

/// Configuration in this file is intended for package collection sources to define certificate policies
/// that are more restrictive. For example, a source may want to require that all their package
/// collections be signed using certificate that belongs to certain subject user ID.
internal struct PackageCollectionSourceCertificatePolicy {
    private static let defaultSourceCertPolicies: [String: CertificatePolicyConfig] = [:]

    private let sourceCertPolicies: [String: CertificatePolicyConfig]

    var allRootCerts: [String]? {
        let allRootCerts = self.sourceCertPolicies.values
            .compactMap { $0.base64EncodedRootCerts }
            .flatMap { $0 }
        return allRootCerts.isEmpty ? nil : allRootCerts
    }

    init(sourceCertPolicies: [String: CertificatePolicyConfig]? = nil) {
        self.sourceCertPolicies = sourceCertPolicies ?? Self.defaultSourceCertPolicies
    }

    func mustBeSigned(source: Model.CollectionSource) -> Bool {
        source.certPolicyConfigKey.map { self.sourceCertPolicies[$0] != nil } ?? false
    }

    func certificatePolicyKey(for source: Model.CollectionSource) -> CertificatePolicyKey? {
        // Certificate policy is associated to a collection host
        source.certPolicyConfigKey.flatMap { self.sourceCertPolicies[$0]?.certPolicyKey }
    }

    struct CertificatePolicyConfig {
        let certPolicyKey: CertificatePolicyKey

        /// Root CAs of the signing certificates. Each item is the base64-encoded string
        /// of the DER representation of a root CA.
        let base64EncodedRootCerts: [String]?
    }
}

private extension Model.CollectionSource {
    var certPolicyConfigKey: String? {
        self.url.host
    }
}
