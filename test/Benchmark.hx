import tests.models.Box;
import quadtree.types.Collider;
import seedyrng.Random;
import quadtree.QuadTree;


class Benchmark
{
    var qt: QuadTree;
    var rand: Random;

    var areaWidth: Float;
    var areaHeight: Float;


    public function new(areaWidth: Float = 20000, areaHeight: Float = 20000)
    {
        this.areaWidth = areaWidth;
        this.areaHeight = areaHeight;

        qt = new QuadTree(0, 0, areaWidth, areaHeight);
        rand = new Random();
    }


    public function run()
    {
        var objects: Array<Collider> = new Array<Collider>();

        for (_ in 0...1000)
        {
            var width: Float = rand.random() * 100;
            var height: Float = rand.random() * 100;
            var x: Float = rand.random() * (areaWidth - width);
            var y: Float = rand.random() * (areaHeight - height);
            var angle: Float = rand.random() * Math.PI * 2;

            var box: Box = new Box(x, y, width, height);
            box.angle = angle;

            objects.push(box);
        }

        for (_ in 0...3)
        {
            var start: Timestamp = new Timestamp();

            qt.reset();

            qt.load(objects);
            var loadTime: Float = start.elapsed();
            start.reset();

            qt.execute();

            var executeTime: Float = start.elapsed();

            trace('Objects: ${objects.length}');
            trace('Load time: $loadTime');
            trace('Execute time: $executeTime');
        }
    }
}

abstract Timestamp(Float) to Float
{
    public static var Zero(get, never): Timestamp;


    public inline function new()
    {
        reset();
    }


    /**
     * Resets the timestamp to the current UNIX time.
     */
    public inline function reset()
    {
        this = getTimestamp();
    }


    /**
     * Returns the elapsed time since the timestamp in seconds.
     */
    public inline function elapsed(): Float
    {
        return elapsedMs() / 1000;
    }


    /**
     * Returns the elapsed time since the timestamp in milliseconds.
     */
    public inline function elapsedMs(): Float
    {
        return getTimestamp() - this;
    }


    /**
     * Returns `true` if more time has elapsed since this timestamp than the given timeout (in seconds).
     * A timeout value less than or equal to `0` is considered infinite and will always return false.
     */
    public inline function isTimedOut(timeout: Float): Bool
    {
        return timeout > 0 && elapsed() > timeout;
    }


    static inline function get_Zero(): Timestamp
    {
        return cast(0.0, Timestamp);
    }

    static inline function getTimestamp(): Float
    {
        #if (cpp || neko || hl)
            return Sys.time() * 1000;
        #else
            return Date.now().getTime();
        #end
    }

}

