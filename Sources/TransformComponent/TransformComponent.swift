import Foundation
import Component
import MatrixUtils
import simd

/**
 */
public class TransformComponent: Component {

  // MARK: - Designated Initializer

  public init() {
    local = .identity
  }

  // MARK: - Matrix Manipulation

  /**
   The matrix that expresses this transform in the coordinate system of the parent.

   Modifying this value triggers recalculation of the world matrix and that of every descendant,
   recursively.
   */
  public var local: float4x4 {
    didSet {
      updateWorldTransformAndPropagateToDescendants()
    }
  }

  /**
   The matrix that expresses this transform in the global coordinate system.

   Updated automatically when the local matrix of the receiver or one of its ancestors is updated.
   */
  private (set) public var world: float4x4 = .identity


  private func updateWorldTransformAndPropagateToDescendants() {
    world = (parent?.world ?? matrix_identity_float4x4) * local
    children.forEach {  $0.updateWorldTransformAndPropagateToDescendants() }
  }

  // MARK: - Codable Support

  enum CodingKeys: String, CodingKey {
    case local
  }

  required public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    local = try container.decode(float4x4.self, forKey: .local)
    world = matrix_identity_float4x4
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(local, forKey: .local)
  }

  // MARK: - Tree Hierarchy

  /**
   The parent transform component in the hierarchy. Nil if root.
   */
  private(set) public var parent: TransformComponent? {
    didSet {
      updateWorldTransformAndPropagateToDescendants()
    }
  }

  /**
   The child transform components in the hierarchy.
   */
  private(set) public var children: [TransformComponent] = []

  /**
   If the passed transform is already a child of the receiver, it is reinserted at the specified
   index.
   If it is a child o another transform, it is first removed from its previous parent.
   After insertion, the world matrix of the new child and all its descendants are recomputed
   recursively.
   */
  public func insertChild(_ child: TransformComponent, at index: Int) {
    child.removeFromParent()

    let safeIndex = min(index, children.count)

    children.insert(child, at: safeIndex)
    child.parent = self
  }

  /**
   Removes the child at the specified index and returns it. Throws if the index is out fo bounds.
   */
  @discardableResult
  public func removeChild(at index: Int) throws -> TransformComponent {
    guard index < children.count else {
      throw TransformComponentError.indexOutOfBounds
    }
    let child = children.remove(at: index)
    child.parent = nil
    return child
  }

  public func swapChildren(at index1: Int, and index2: Int) {
    guard index1 != index2 else { return }
    children.swapAt(index1, index2)
  }

  public func index(of child: TransformComponent) -> Int? {
    return children.firstIndex(where: { $0 === child })
  }

  public func removeChild(_ child: TransformComponent) {
    guard let index = index(of: child) else {
      return
    }
    _ = try? removeChild(at: index)
  }

  public func addChild(_ child: TransformComponent) {
    insertChild(child, at: children.count)
  }

  public func removeFromParent() {
    guard let parent = parent else {
      return
    }
    guard let index = parent.children.firstIndex (where: { $0 === self }) else {
      return
    }
    _ = try? parent.removeChild(at: index)
  }
}

// MARK: - Supporting Types and Extensions

public enum TransformComponentError: LocalizedError {
  case indexOutOfBounds
}
