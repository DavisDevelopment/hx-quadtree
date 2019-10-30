package tests.models;

import quadtree.helpers.MathUtils;
import quadtree.CollisionAreaType;
import quadtree.types.MovingRectangle;


class MovingBox extends Box implements MovingRectangle
{
    public var lastX: Float;
    public var lastY: Float;


    public function new(x: Float, y: Float, width: Float = 0, height: Float = 0, angleDegrees: Float = 0)
    {
        super(x, y, width, height);

        lastX = this.x;
        lastY = this.y;

        angle = MathUtils.TO_RAD * angleDegrees;

        areaType = CollisionAreaType.MovingRectangle;
    }


    public function moveTo(x: Float, y: Float)
    {
        lastX = this.x;
        lastY = this.y;

        this.x = x;
        this.y = y;
    }
}
