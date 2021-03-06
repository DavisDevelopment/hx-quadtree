package tests.models;

import quadtree.types.Collider;
import quadtree.CollisionAreaType;
import quadtree.types.Rectangle;
import tests.models.Constants.Ints;


class Box implements Rectangle
{
    /** Returns a bounding box with its top left corner on (0, 0) and the maximum size. **/
    public static var Max(get, never): Box;

    public var areaType: CollisionAreaType = CollisionAreaType.Rectangle;
    public var collisionsEnabled: Bool = true;
    
    public var x: Float;
    public var y: Float;
    public var width: Float;
    public var height: Float;
    public var angle: Float = 0;

    public var collisionsDetected: Int = 0;


    public function new(x: Float, y: Float, width: Float = 0, height: Float = 0)
    {
        this.x = x;
        this.y = y;
        this.width = width;
        this.height = height;
    }


    public function onOverlap(other: Collider): Void
    {
        collisionsDetected++;
    }


    static function get_Max(): Box
    {
        return new Box(0, 0, Ints.MAX, Ints.MAX);
    }
    

    public function moveToSeparate(deltaX: Float, deltaY: Float)
    {
        x += deltaX;
        y += deltaY;
    }
}

