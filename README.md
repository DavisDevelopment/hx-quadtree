Quadtree
[![pipeline status](https://gitlab.com/haath/quadtree/badges/master/pipeline.svg)](https://gitlab.com/haath/quadtree/pipelines/latest)
[![coverage report](https://gitlab.com/haath/quadtree/badges/master/coverage.svg)](https://gitlab.com/haath/quadtree/pipelines/latest)
[![license](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](https://gitlab.com/haath/quadtree/blob/master/LICENSE)
[![release](https://img.shields.io/badge/release-haxelib-informational)](https://lib.haxe.org/p/quadtree/)
====================


Fast, optimized and configurable collision-detection library with Quad Trees.
Efficient implementation of the GJK algorithm to support any convex polygon shape, with separate faster handling of specialized cases like between rectangles and points.


## Installation

```bash
$ haxelib install quadtree
```


## Usage

### Colliding object types

Objects that will be checked for collisions, should implement one of the following interfaces:

- `Point`
- `Rectangle`
- `MovingPoint`
- `MovingRectangle`
- `Polygon`
- `Circle`

```haxe
import quadtree.CollisionAreaType;
import quadtree.types.Collider;
import quadtree.types.Rectangle;

class Box implements Rectangle
{
    // Value denoting the object's type, to avoid reflection calls
    // for better performance.
    public var areaType: CollisionAreaType = CollisionAreaType.Rectangle;

    // Use this to temporarily disable an object's collision 
    // without removing it from whatever list it may be in.
    public var collisionsEnabled: Bool = true;

    public var x: Float = 0;
    public var y: Float = 0;
    public var width: Float = 100;
    public var height: Float = 100;

    public function onOverlap(other: Collider)
    {
        // Called when this object overlaps with another.
    }
}
```


### Using the Quad Tree

The tree is static and should be re-built on every frame.

```haxe
import quadtree.QuadTree;
```

To check an array of objects for collisions between themselves.

```haxe
// Initialize a tree with set boundaries.
var qt: QuadTree = new QuadTree(x, y, width, height);
qt.load(objectList);
qt.execute();
```

To check an array of objects for collisions between them and another list of objects.

```haxe
var qt: QuadTree = new QuadTree(x, y, width, height);
qt.load(objectList1, objectList2);
qt.execute();
```

The `load()` function only adds the objects to the tree, it does not reset it.
Therefore if collisions are checked in a loop, for example in each frame of a game, then `reset()` has to be called as well.

```haxe
var qt: QuadTree = new QuadTree(x, y, width, height);

while (gameRunning)
{
    qt.reset();
    qt.load(objectList);
    qt.execute();
}
```


### Configuring the QuadTree

Being familiar with quad-trees, you can also configure its properties.

```haxe
// The maximum depth of the tree.
// After it is reached, leaf nodes will simply be filled with all objects added to them.
// Quad trees with large boundaries (f.e world maps) may benefit from having a bigger maxDepth.
// This parameter should not be changed after load() and before reset().
qt.maxDepth = 5;

// The amount of objects a node can hold before it is subdivided into quadrants.
// The amount of collision checks that happen on each node will be equal to this number squared.
// Quad trees with large boundaries (f.e world maps) may benefit from having less objects per node,
// this way the tree will be split more often and objects far-away from each other won't be checked against each other as much.
// This parameter should not be changed after load() and before reset().
qt.objectsPerNode = 4;

// Set a custom function to further handle the overlapping of two objects.
// This callback will be called each time two objects overlap, and if it returns false
// the onOverlap() method of the objects will not be called.
qt.setOverlapProcessCallback(function(collisionResult: quadtree.helpers.CollisionResult)
{
    var obj0 = collisionResult.object0;
    var obj1 = collisionResult.object1;
    return true;
});
```


### Collision Separation and Velocity

This library can also handle the separation of overlapping objects,
as well as calculating their velocities according to momentum conservation.

A good place to perform this would be the overlap process callback,
which is called before objects are notified of their collision.

```haxe
import quadtree.Physics;
import quadtree.helpers.CollisionResult;

qt.setOverlapProcessCallback(function(collisionResult: CollisionResult)
{
    var obj0 = collisionResult.object0;
    var obj1 = collisionResult.object1;

    // First separate the objects.
    Physics.separate(collisionResult);
    
    if (collisionResult.separationHappened)
    {
        // If separation actually happened, we can also update their velocities.

        // First configure the collision result.
        collisionResult.obj1Velocity.set( ... );
        collisionResult.obj1Mass = ...;
        collisionResult.obj1Elasticity = ...;
        collisionResult.obj1Immovable = false;

        // Similary for object2.
        collisionResult.obj2Velocity.set( ... );

        // The next function will calculate the new velocity for each object,
        // and modify the two vectors, obj1Velocity and obj2Velocity.
        Physics.momentumConservationCollision(collisionResult);

        // Finally, update the velocities on the objects themselves.
        obj0.velocity = collisionResult.obj1Velocity;
        obj1.velocity = collisionResult.obj2Velocity;
    }

    return collisionResult.separationHappened;
});
```


### Static Objects

Having a group of immovable objects, for example trees, tilemaps or other parts of the environment, 
means that time can be saved in the construction of the QuadTree, by leaving those objects loaded
in the second group of the tree and only partially reseting it to re-construct the first group.
This can be done with the `resetFirstGroup()` function as shown in the example below.

```haxe
// Group of characters, who are moving objects.
var characters: Array<Collider>;

// Group of static trees.
var trees: Array<Collider>;

var qt: QuadTree = new QuadTree(x, y, width, height);

// Load the trees into the second group once.
qt.load(null, trees);

while (true)
{
    // Load characters into the first group.
    qt.load(characters);

    qt.execute();

    // Reset the characters group in the tree to build it again in the next cycle.
    qt.resetFirstGroup();
}

```

