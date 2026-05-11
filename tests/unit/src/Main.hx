class Main
{
    static public function main():Void
    {
        utest.UTest.run
        (   [ new debug.LoggerTest()
            , new debug.ansi.ColorTest()
            , new debug.ansi.StyleToolsTest()
            ]
        );
    }
}