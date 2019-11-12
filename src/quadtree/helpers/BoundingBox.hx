package quadtree.helpers;

import quadtree.types.Collider;
import quadtree.types.Rectangle;


class BoundingBox implements Rectangle
{
    public final areaType: CollisionAreaType = CollisionAreaType.Rectangle;
    public final collisionsEnabled: Bool = false;
    public final angle: Float = 0;
    
    public var x: Float;
    public var y: Float;
    public var width: Float;
    public var height: Float;

    // For caching them.
    @:noCompletion
    public var next: BoundingBox;


    public function new(x: Float, y: Float, width: Float = 0, height: Float = 0)
    {
        this.x = x;
        this.y = y;
        this.width = width;
        this.height = height;
    }


    @IgnoreCover
    public function onOverlap(other: Collider): Void { }
    

    @IgnoreCover
    public function moveToSeparate(deltaX: Float, deltaY: Float) { }
}
