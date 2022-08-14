import XCTest
import simd
import MatrixUtils
@testable import Transform

final class TransformComponentTests: XCTestCase {

  // Matrix Manipulation Tests

  func testGlobalMatrix() {
    
  }

  // Hierarchy Tests

  func testInitialParentNil() {
    // GIVEN
    let transform = Transform()

    // THEN
    XCTAssertNil(transform.parent)
  }

  // MARK: - Hierarchy Tests - Add Child

  func testAddChildParentSet() {
    // GIVEN
    let child = Transform()
    let parent = Transform()

    // WHEN
    parent.addChild(child)

    // THEN
    XCTAssertIdentical(child.parent, parent)
  }

  func testAddChildCountIsOne() {
    // GIVEN
    let child = Transform()
    let parent = Transform()

    // WHEN
    parent.addChild(child)

    // THEN
    XCTAssertEqual(parent.children.count, 1)
  }

  func testAddChildRetrieveSameInstance() {
    // GIVEN
    let child = Transform()
    let parent = Transform()

    // WHEN
    parent.addChild(child)

    // THEN
    XCTAssertIdentical(parent.children[0], child)
  }

  func testAddChildRemoveEmptiesChildren() throws {
    // GIVEN
    let child = Transform()
    let parent = Transform()

    // WHEN
    parent.addChild(child)
    try parent.removeChild(at: 0)

    XCTAssertEqual(parent.children.count, 0)
  }

  func testAddChildRemoveClearsParent() throws {
    // GIVEN
    let child = Transform()
    let parent = Transform()

    // WHEN
    parent.addChild(child)
    try parent.removeChild(at: 0)

    XCTAssertNil(child.parent)
  }

  func testAddChildRemoveFromParentEmptiesChildren() {
    // GIVEN
    let child = Transform()
    let parent = Transform()

    // WHEN
    parent.addChild(child)
    child.removeFromParent()

    // THEN:
    XCTAssertEqual(parent.children.count, 0)
  }

  func testAddChildRemoveFromParentClearsParent() {
    // GIVEN
    let child = Transform()
    let parent = Transform()

    // WHEN
    parent.addChild(child)
    child.removeFromParent()

    // THEN:
    XCTAssertNil(child.parent)
  }

  func testAddChildPastCount() {
    // GIVEN
    let child = Transform()
    let parent = Transform()

    // WHEN:
    parent.insertChild(child, at: 10)

    // THEN:
    XCTAssertEqual(parent.index(of: child), 0)
  }

  func testChildrenAddedAtTheEnd() {
    // GIVEN
    let parent = Transform()
    let child1 = Transform()
    let child2 = Transform()

    // WHEN:
    parent.addChild(child1)
    parent.addChild(child2)

    // THEN
    XCTAssertEqual(parent.index(of: child1), 0)
    XCTAssertEqual(parent.index(of: child2), 1)
  }

  func testRemoveUnknownChildNoOp() {
    // GIVEN
    let parent = Transform()
    let child1 = Transform()
    let child2 = Transform()

    // WHEN:
    parent.addChild(child1)
    parent.removeChild(child2)

    // THEN
    XCTAssertIdentical(parent.children[0], child1)
  }

  func testSwapChildren() {
    // GIVEN
    let parent = Transform()
    let child1 = Transform()
    let child2 = Transform()

    // WHEN:
    parent.addChild(child1)
    parent.addChild(child2)
    parent.swapChildren(at: 0, and: 1)

    // THEN
    XCTAssertEqual(parent.index(of: child1), 1)
    XCTAssertEqual(parent.index(of: child2), 0)
  }

  // MARK: - Transform Tests

  func testSetLocalTransformUpdatesGlobal() {
    // GIVEN
    let transform = Transform()
    let scale = float4x4(scale: 2)

    // WHEN
    transform.local = scale

    // THEN
    XCTAssertEqual(transform.world, scale)
  }

  func testSetLocalTransformUpdatesDescendantGlobal() {
    // GIVEN
    let parent = Transform()
    let child = Transform()
    let scale = float4x4(scale: 2)
    parent.addChild(child)

    // WHEN
    parent.local = scale

    // THEN
    XCTAssertEqual(parent.world, scale)
  }
}
