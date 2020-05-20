import tests.TestQuadTreeAdd;
import tests.TestQuadTreeExecute;
import utest.Runner;
import utest.ui.Report;
import utest.ui.common.HeaderDisplayMode;
import utest.ui.common.HeaderDisplayMode.SuccessResultsDisplayMode;
import mcover.coverage.MCoverage;
import mcover.coverage.client.PrintClient;


class TestMain
{
    static function main()
    {
        runTests();
        //runBenchmark();
    }


    static function runTests()
    {
        var runner = new Runner();
        runner.onComplete.add(onComplete);

        runner.addCases("tests", false);

        Report.create(runner, SuccessResultsDisplayMode.NeverShowSuccessResults, HeaderDisplayMode.AlwaysShowHeader);

        runner.run();
    }


    static function runBenchmark()
    {
        var benchmark: Benchmark = new Benchmark();
        benchmark.run();
    }


    static function onComplete(runner: Runner)
    {
        #if !js
        var covLogger = MCoverage.getLogger();
        covLogger.report();
        #end
    }
}

