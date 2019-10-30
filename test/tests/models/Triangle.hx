package tests.models;

import quadtree.CollisionAreaType;
import quadtree.types.Polygon;


class Triangle implements Polygon
{
    public var areaType: CollisionAreaType = CollisionAreaType.Polygon;
    public var collisionsEnabled: Bool = true;
    
    public var refX: Float = 0;
    public var refY: Float = 0;

    public var points: Array<Array<Float>>;

    public var collisionsDetected: Int = 0;


    public function new(a: Array<Float>, b: Array<Float>, c: Array<Float>)
    {
        points = new Array<Array<Float>>();
        points.push(a);
        points.push(b);
        points.push(c);
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
