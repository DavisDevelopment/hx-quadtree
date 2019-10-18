Quadtree Haxe
[![pipeline status](https://gitlab.com/haath/quadtree/badges/master/pipeline.svg)](https://gitlab.com/haath/quadtree/pipelines/latest)
[![coverage report](https://gitlab.com/haath/quadtree/badges/master/coverage.svg)](https://gitlab.com/haath/quadtree/pipelines/latest)
[![license](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](https://gitlab.com/haath/quadtree/blob/master/LICENSE)
[![release](https://img.shields.io/badge/release-haxelib-informational)](https://lib.haxe.org/p/quadtree/)
====================


## Installation

```bash
$ haxelib install quadtree
```


## Usage

### Colliding object types

Objects that will be checked for collisions, should implement one of the following interface:

- `Point`
- `Rectangle`
- `MovingPoint`
- `MovingRectangle`

```haxe
import quadtree.CollisionAreaType;
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

    public function onOverlap(other: Point)
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


