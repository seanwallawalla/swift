// REQUIRES: OS=macosx
// RUN: %empty-directory(%t)
// RUN: %empty-directory(%t/includes)

// Build external Swift library/module to also check conformances to external protocols
// RUN: %target-build-swift %S/Inputs/swiftmodules/testModB.swift -parse-as-library -emit-module -emit-library -module-name testModB -o %t/includes/testModB.o

// RUN: %target-build-swift %s -parse-as-library -target %target-cpu-apple-macosx10.15 -I %t/includes -emit-module -emit-library -module-name AssociatedTypeRequirements -o %t/AssociatedTypeRequirements %t/includes/testModB.o

// RUN: %target-swift-reflection-dump -binary-filename %t/AssociatedTypeRequirements | %FileCheck %s

// CHECK: ASSOCIATED TYPES:
// CHECK: - AssociatedTypeRequirements.Foo : AssociatedTypeRequirements.myProto
// CHECK-NEXT: typealias PerformReturn = opaque type symbolic reference
// CHECK-NEXT: opaque type symbolic reference
// CHECK-NEXT: (bound_generic_struct AssociatedTypeRequirements.Bar

// CHECK: conformance requirements:
// CHECK-NEXT: AssociatedTypeRequirements.protoA
// CHECK-NEXT: AssociatedTypeRequirements.protoB
// CHECK-NEXT: testModB.testModBProtocol

// CHECK: same-type requirements:
// CHECK-NEXT: A.AssociatedTypeRequirements.protoB.K = Sf (Swift.Float)
// CHECK-NEXT: A.AssociatedTypeRequirements.protoA.T = 8testModB0aB7BStructV (testModB.testModBStruct)

import testModB

public protocol myProto {
    associatedtype PerformReturn
    func perform() -> PerformReturn
}
public protocol protoA<T> {
    associatedtype T
}
public protocol protoB<K> {
    associatedtype K
}

public struct Bar<M, N> : protoA, protoB, testModBProtocol {
    public typealias T = M
    public typealias K = N
}

public struct Foo : myProto {
    public func perform() -> some protoA<testModBStruct> & protoB<Float> & testModBProtocol { return baz() }
}

private func baz() -> some protoA<testModBStruct> & protoB<Float> & testModBProtocol { return Bar<testModBStruct, Float>() }
