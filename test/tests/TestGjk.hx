package tests;

import quadtree.helpers.MathUtils;
import quadtree.CollisionAreaType;
import tests.models.MovingPoint;
import tests.models.Point;
import tests.models.MovingBox;
import tests.models.EmptyPolygon;
import tests.models.Circle;
import tests.models.Box;
import quadtree.gjk.VectorLinkedList;
import quadtree.gjk.Simplex;
import quadtree.gjk.Vector;
import utest.Async;
import utest.Assert;
import quadtree.gjk.Gjk;
import utest.ITest;
import tests.models.Triangle;


class TestGjk extends Gjk implements ITest
{
    function testGetFarthestPointInDirection()
    {
        var t1: Triangle = new Triangle([0, 0], [0.5, 0.5], [1, 0]);

        Assert.isTrue( getFarthestPointInDirection(t1, v(1, 0)).equals( v(1, 0) )     );
        Assert.isTrue( getFarthestPointInDirection(t1, v(-1, 0)).equals( v(0, 0) )    );
        Assert.isTrue( getFarthestPointInDirection(t1, v(0, 1)).equals( v(0.5, 0.5) ) );
        Assert.isTrue( getFarthestPointInDirection(t1, v(0, -1)).equals( v(0, 0) )    );

        var t2: Triangle = new Triangle([10, 10], [10, 20], [20, 30]);

        Assert.isTrue( getFarthestPointInDirection(t2, v(1, 0)).equals( v(20, 30) )   );
        Assert.isTrue( getFarthestPointInDirection(t2, v(-1, 0)).equals( v(10, 10) )  );
        Assert.isTrue( getFarthestPointInDirection(t2, v(0, 1)).equals( v(20, 30) )   );
        Assert.isTrue( getFarthestPointInDirection(t2, v(0, -1)).equals( v(10, 10) )  );

        var e: EmptyPolygon = new EmptyPolygon();

        Assert.isNull( getFarthestPointInDirection(e, v(1, 0))  );
        Assert.isNull( getFarthestPointInDirection(e, v(-1, 0)) );
        Assert.isNull( getFarthestPointInDirection(e, v(0, 1))  );
        Assert.isNull( getFarthestPointInDirection(e, v(0, -1)) );

        var b: MovingBox = new MovingBox(100, 100, 100, 200);
        b.angle = 90 * MathUtils.TO_RAD;

        Assert.isTrue( getFarthestPointInDirection(b, v(1, 0)).equals( v(250, 150) )   );
        Assert.isTrue( getFarthestPointInDirection(b, v(-1, 0)).equals( v(50, 250) )  );
        Assert.isTrue( getFarthestPointInDirection(b, v(0, 1)).equals( v(250, 250) )   );
        Assert.isTrue( getFarthestPointInDirection(b, v(0, -1)).equals( v(50, 150) )  );


        var p: Point = new Point(100, 100);

        Assert.isTrue( getFarthestPointInDirection(p, v(1, 0)).equals( v(100, 100) )   );
        Assert.isTrue( getFarthestPointInDirection(p, v(-1, 0)).equals( v(100, 100) )  );
        Assert.isTrue( getFarthestPointInDirection(p, v(0, 1)).equals( v(100, 100) )   );
        Assert.isTrue( getFarthestPointInDirection(p, v(0, -1)).equals( v(100, 100) )  );

        var mp: MovingPoint = new MovingPoint(100, 100);
        mp.moveTo(100, 200);

        Assert.isTrue( getFarthestPointInDirection(mp, v(1, 0)).equals( v(100, 100) )   );
        Assert.isTrue( getFarthestPointInDirection(mp, v(-1, 0)).equals( v(100, 100) )  );
        Assert.isTrue( getFarthestPointInDirection(mp, v(0, 1)).equals( v(100, 200) )   );
        Assert.isTrue( getFarthestPointInDirection(mp, v(0, -1)).equals( v(100, 100) )  );

        mp.areaType = cast(0, CollisionAreaType);
        Assert.raises( () -> getFarthestPointInDirection(mp, v(1, 0)), String );
    }


    function testCheck()
    {
        var a: Triangle = new Triangle([0, 1], [1, -1], [-1, -1]);
        var b: Triangle = new Triangle([0, -1], [1, 1], [-1, 1]);

        var direction: Vector = v(0, 1);

        var aFar: Vector = getFarthestPointInDirection(a, direction);
        var bFar: Vector = getFarthestPointInDirection(b, direction.invert());
        var support0: Vector = aFar.copy().sub(bFar);
        direction.invert();

        Assert.isTrue( aFar.equals(v(0, 1)) );
        Assert.isTrue( bFar.equals(v(0, -1)) );
        Assert.isTrue( support0.equals(v(0, 2)) );
        Assert.isTrue( support0.equals(getSupportVector(a, b, direction)) );
        Assert.isTrue( direction.equals(v(0, 1)) );

        var simplex: Simplex = new Simplex();
        simplex.push(support0.copy());

        direction.invert();
        Assert.isTrue( direction.equals(v(0, -1)) );
        
        aFar = getFarthestPointInDirection(a, direction);
        bFar = getFarthestPointInDirection(b, direction.invert());
        var support1 = aFar.copy().sub(bFar);
        direction.invert();
        
        Assert.isTrue( aFar.equals(v(1, -1)) );
        Assert.isTrue( bFar.equals(v(1, 1)) );
        Assert.isTrue( support1.equals(v(0, -2)) );
        Assert.isTrue( support1.equals(getSupportVector(a, b, direction)) );
        Assert.isTrue( support1.dotVector(direction) > 0 );
        Assert.isTrue( direction.equals(v(0, -1)) );

        simplex.push(support1.copy());
        Assert.equals(2, simplex.length);

        direction = simplex.calculateDirection(this);
        
        Assert.isTrue( support1.copy().invert().equals(v(0, 2)) );                     // Ainv = (0, -2)
        Assert.isTrue( support0.copy().sub(support1).equals(v(0, 4)) );                 // AB = (0, 4)
        Assert.isTrue( support0.copy().sub(support1).perpendicular().equals(v(4, 0)) ); // ABperp = (4, 0)
        Assert.equals( 0, support0.copy().sub(support1).perpendicular().dotVector(support1.copy().invert()) );
        Assert.isTrue( direction.equals(v(-4, 0)) );

        var support2 = getSupportVector(a, b, direction);
        Assert.isTrue( support2.equals(v(-2, -2)) );
        Assert.isTrue( support2.dotVector(direction) > 0 );

        simplex.push(support2.copy());
        Assert.equals(3, simplex.length);

        direction = simplex.calculateDirection(this);

        Assert.isNull(direction);
    }


    function testTriangles()
    {
        var t1: Triangle = new Triangle([0, 0], [0, 1], [1, 0]);
        var t2: Triangle = new Triangle([0, 0], [1, 1], [1, 0]);
        var t3: Triangle = new Triangle([10, 10], [10, 20], [20, 30]);

        Assert.isTrue(checkOverlap(t1, t2));
        Assert.isFalse(checkOverlap(t1, t3));
    }


    function testVariousCollisions()
    {
        var b: Box = new Box(100, 100, 10, 10);
        var t1: Triangle = new Triangle([90, 90], [110, 110], [90, 80]); // yes
        var t2: Triangle = new Triangle([60, 60], [80, 80], [60, 80]); // no
        var c1: Circle = new Circle(90, 90, 20); // yes
        var c2: Circle = new Circle(90, 90, 2); // no
        var c3: Circle = new Circle(105, 105, 2); // yes

        Assert.isTrue(checkOverlap(b, t1));
        Assert.isFalse(checkOverlap(b, t2));
        Assert.isTrue(checkOverlap(b, c1));
        Assert.isFalse(checkOverlap(b, c2));
        Assert.isTrue(checkOverlap(b, c3));
    }


    function testMovingRectangleAndCircle() 
    {
        var b1: MovingBox = new MovingBox(100, 100, 100, 100);
        var b2: MovingBox = new MovingBox(190, 190, 10, 10);
        b2.moveTo(200, 200);
        var p1: MovingPoint = new MovingPoint(199, 199);
        p1.moveTo(202, 202);
        var b3: Box = new Box(220, 220, 2, 2);
        var c1: Circle = new Circle(221, 221, 4);

        Assert.isFalse(checkOverlap(b1, c1));
        Assert.isFalse(checkOverlap(b2, c1));
        Assert.isTrue(checkOverlap(b3, c1));
        Assert.isFalse(checkOverlap(p1, c1));
    }


    function testRotatedRectangles()
    {
        var b1: Box = new Box(0, 0, 100, 10);
        var b2: Box = new Box(0, 30, 100, 10);

        Assert.isFalse(checkOverlap(b1, b2));

        b1.angle = 90 * MathUtils.TO_RAD;
        
        Assert.isTrue(checkOverlap(b1, b2));

        b1.angle = 180 * MathUtils.TO_RAD;
        
        Assert.isFalse(checkOverlap(b1, b2));
    }
    
    
    inline function v(x: Float, y: Float): Vector return new VectorLinkedList(x, y);
}
