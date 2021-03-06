package quadtree.helpers;


/**
    Taken from: https://github.com/HaxeFlixel/flixel/blob/master/flixel/math/FlxMath.hx
**/
class MathUtils
{
	/** Constant to account for floating point numerical errors. Number smaller than this will be considered zero. **/
	public static inline var EPSILON: Float = 0.0000001;


	/** The number to multiply radians with to convert them to degrees. **/
	public static inline var TO_DEG: Float = 180 / 3.1415926535897932384626433832795028841971693993751058209749445923078164062;


	/** The number to multiply degrees with to convert them to radians. **/
	public static inline var TO_RAD: Float = 3.1415926535897932384626433832795028841971693993751058209749445923078164062 / 180;


    /**
	 * A faster, but less accurate version of `Math.cos()`.
	 * About 2-6 times faster with < 0.05% average error.
	 *
	 * @param	n	The angle in radians.
	 * @return	An approximated cosine of `n`.
	 */
    public static inline function fastCos(n: Float): Float
    {
        return fastSin(n + 1.570796327);
    }


    /**
	 * A faster but slightly less accurate version of `Math.sin()`.
	 * About 2-6 times faster with < 0.05% average error.
	 *
	 * @param	n	The angle in radians.
	 * @return	An approximated sine of `n`.
	 */
    public static function fastSin(n: Float): Float
	{
		n *= 0.3183098862; // divide by pi to normalize

		// bound between -1 and 1
		if (n > 1)
		{
			n -= (Math.ceil(n) >> 1) << 1;
		}
		else if (n < -1)
		{
			n += (Math.ceil(-n) >> 1) << 1;
		}

		// this approx only works for -pi <= rads <= pi, but it's quite accurate in this region
		if (n > 0)
		{
			return n * (3.1 + n * (0.5 + n * (-7.2 + n * 3.6)));
		}
		else
		{
			return n * (3.1 - n * (0.5 + n * (7.2 + n * 3.6)));
		}
	}


	public static inline function fastAtan2(y: Float, x: Float): Float
	{
		// TODO
		return Math.atan2(y, x);
	}


	/**
		Returns the number with the smaller absolute value.
	**/
	public static inline function minAbs(a: Float, b: Float): Float
	{
		return Math.abs(a) <= Math.abs(b) ? a : b;
	}


	/**
		Returns the number with the larger absolute value.
	**/
	public static inline function maxAbs(a: Float, b: Float): Float
	{
		return Math.abs(a) >= Math.abs(b) ? a : b;
	}


	/**
		Returns `true` if the two given numbers are either both positive, both negative or both zero.

		A simple shortcut to checking with comparisons since `a > 0 && b > 0` takes longer to write than
		`a * b > 0` but is slightly faster.
	**/
	public static inline function areParallel(a: Float, b: Float): Bool
	{
		return (isZero(a) && isZero(b))
			|| (a > 0 && b > 0)
			|| (a < 0 && b < 0);
	}


	public static inline function floatEquals(f1: Float, f2: Float): Bool
	{
		return Math.abs(f1 - f2) < EPSILON;
	}


	public static inline function isZero(f: Float): Bool
	{
		return Math.abs(f) < EPSILON;
	}


	public static inline function isNonZero(f: Float): Bool
	{
		return !isZero(f);
	}


    public static inline function rotateX(cos: Float, sin: Float, x: Float, y: Float, x0: Float, y0: Float): Float
    {
        return x0 + (x - x0)*cos - (y - y0)*sin;
    }


    public static inline function rotateY(cos: Float, sin: Float, x: Float, y: Float, x0: Float, y0: Float): Float
    {
        return y0 + (x - x0)*sin + (y - y0)*cos;
    }


	/**
		Calculates the angle between two given points in radians.
	**/
	public static inline function angleBetween(fromX: Float, fromY: Float, toX: Float, toY: Float): Float
	{
		return Math.atan2(toY - fromY, toX - fromX);
	}
}
