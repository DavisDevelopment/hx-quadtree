package tests.models;

import quadtree.CollisionAreaType;
import quadtree.types.Polygon;


class EmptyPolygon implements Polygon
{
    public var areaType: CollisionAreaType = CollisionAreaType.Polygon;
    public var collisionsEnabled: Bool = true;

    public var refX: Float = 0;
    public var refY: Float = 0;

    public var points: Array<Array<Float>>;

    public var collisionsDetected: Int = 0;


    public function new()
    {
        points = new Array<Array<Float>>();
    }


    public function onOverlap(_)
    {
        collisionsDetected++;
    }
    

    public function moveToSeparate(deltaX: Float, deltaY: Float)
    {
        refX += deltaX;
        refY += deltaY;
    }
}
