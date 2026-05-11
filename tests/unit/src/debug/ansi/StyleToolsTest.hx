package debug.ansi;

import debug.ansi.Color;
import debug.ansi.StyleTools;
import utest.Assert;

using debug.ansi.StyleTools;

class StyleToolsTest extends utest.Test
{
    function testColor()
    {
        assertStyle("\u001b[30mGRAY\u001b[39m"   , StyleTools.color("GRAY"   , GRAY   ));
        assertStyle("\u001b[31mRED\u001b[39m"    , StyleTools.color("RED"    , RED    ));
        assertStyle("\u001b[32mGREEN\u001b[39m"  , StyleTools.color("GREEN"  , GREEN  ));
        assertStyle("\u001b[33mYELLOW\u001b[39m" , StyleTools.color("YELLOW" , YELLOW ));
        assertStyle("\u001b[34mBLUE\u001b[39m"   , StyleTools.color("BLUE"   , BLUE   ));
        assertStyle("\u001b[35mMAGENTA\u001b[39m", StyleTools.color("MAGENTA", MAGENTA));
        assertStyle("\u001b[36mCYAN\u001b[39m"   , StyleTools.color("CYAN"   , CYAN   ));
        assertStyle("\u001b[37mWHITE\u001b[39m"  , StyleTools.color("WHITE"  , WHITE  ));
        
        assertStyle("\u001b[38;2;255;165;0mORANGE\u001b[39m"  , StyleTools.color("ORANGE", ORANGE));
        assertStyle("\u001b[38;2;128;0;128mPURPLE\u001b[39m"  , StyleTools.color("PURPLE", PURPLE));
        assertStyle("\u001b[38;2;255;192;203mPINK\u001b[39m"  , StyleTools.color("PINK", PINK));
        assertStyle("\u001b[38;2;0;0;0m000000\u001b[39m"      , StyleTools.color("000000", BLACK));
        assertStyle("\u001b[38;2;170;170;170mAAAAAA\u001b[39m", StyleTools.color("AAAAAA", 0xAAAAAA));
    }
    
    function testStyle()
    {
        #if logger.unit_test.show_styles
        final results = [];
        #end
        function assert(expected, actual, ?wrappingStyle:Style, ?msg, ?pos)
        {
            #if logger.unit_test.show_styles
            results.push(StyleTools.style('start-${actual}-end', wrappingStyle ?? COLOR_FG(RED)));
            #end
            assertStyle(expected, actual, msg, pos);
        }
        
        assert("\u001b[40mGRAY_BG\u001b[49m"                , StyleTools.style("GRAY_BG"      , COLOR_BG(GRAY      )));
        assert("\u001b[41mRED_BG\u001b[49m"                 , StyleTools.style("RED_BG"       , COLOR_BG(RED       )));
        assert("\u001b[42mGREEN_BG\u001b[49m"               , StyleTools.style("GREEN_BG"     , COLOR_BG(GREEN     )));
        assert("\u001b[43mYELLOW_BG\u001b[49m"              , StyleTools.style("YELLOW_BG"    , COLOR_BG(YELLOW    )));
        assert("\u001b[44mBLUE_BG\u001b[49m"                , StyleTools.style("BLUE_BG"      , COLOR_BG(BLUE      )));
        assert("\u001b[45mMAGENTA_BG\u001b[49m"             , StyleTools.style("MAGENTA_BG"   , COLOR_BG(MAGENTA   )));
        assert("\u001b[46mCYAN_BG\u001b[49m"                , StyleTools.style("CYAN_BG"      , COLOR_BG(CYAN      )));
        assert("\u001b[47mWHITE_BG\u001b[49m"               , StyleTools.style("WHITE_BG"     , COLOR_BG(WHITE     )));
        assert("\u001b[48;2;255;165;0mORANGE_BG\u001b[49m"  , StyleTools.style("ORANGE_BG"    , COLOR_BG(ORANGE    )));
        assert("\u001b[48;2;128;0;128mPURPLE_BG\u001b[49m"  , StyleTools.style("PURPLE_BG"    , COLOR_BG(PURPLE    )));
        assert("\u001b[48;2;255;192;203mPINK_BG\u001b[49m"  , StyleTools.style("PINK_BG"      , COLOR_BG(PINK      )));
        assert("\u001b[48;2;0;0;0m000000_BG\u001b[49m"      , StyleTools.style("000000_BG"    , COLOR_BG(BLACK     )));
        assert("\u001b[48;2;170;170;170mAAAAAA_BG\u001b[49m", StyleTools.style("AAAAAA_BG"    , COLOR_BG(0xAAAAAA)));
        
        assert("\u001b[1mBOLD\u001b[22m"                    , StyleTools.style("BOLD"         , BOLD         )); 
        assert("\u001b[2mDIM\u001b[22m"                     , StyleTools.style("DIM"          , DIM          )); 
        assert("\u001b[3mITALIC\u001b[23m"                  , StyleTools.style("ITALIC"       , ITALIC       )); 
        assert("\u001b[4mUNDERLINE\u001b[24m"               , StyleTools.style("UNDERLINE"    , UNDERLINE    )); 
        assert("\u001b[5mBLINK_SLOW\u001b[25m"              , StyleTools.style("BLINK_SLOW"   , BLINK(false) )); 
        assert("\u001b[6mBLINK_FAST\u001b[25m"              , StyleTools.style("BLINK_FAST"   , BLINK(true ) )); 
        assert("\u001b[7mINVERSE\u001b[27m"                 , StyleTools.style("INVERSE"      , INVERSE      )); 
        assert("\u001b[8mCONCEAL\u001b[28m"                 , StyleTools.style("CONCEAL"      , CONCEAL      )); 
        assert("\u001b[9mSTRIKETHROUGH\u001b[29m"           , StyleTools.style("STRIKETHROUGH", STRIKETHROUGH));
        
        #if logger.unit_test.show_styles
        trace(results.join(" "));
        #end
    }
    
    function testStyleMany()
    {
        #if logger.unit_test.show_styles
        final results = [];
        #end
        function assert(expected, actual, ?wrappingStyle:Style, ?msg, ?pos)
        {
            #if logger.unit_test.show_styles
            results.push(StyleTools.style('start-${actual}-end', wrappingStyle ?? COLOR_FG(RED)));
            #end
            assertStyle(expected, actual, msg, pos);
        }
        
        assert("\u001b[40;1mGRAY_BG_BOLD\u001b[22;49m"          , StyleTools.style("GRAY_BG_BOLD" , [ COLOR_BG(GRAY      ), BOLD         ]));
        assert("\u001b[41;2mRED_BG_DIM\u001b[22;49m"            , StyleTools.style("RED_BG_DIM"   , [ COLOR_BG(RED       ), DIM          ]));
        assert("\u001b[42;3mGREEN_BG_ITAL\u001b[23;49m"         , StyleTools.style("GREEN_BG_ITAL", [ COLOR_BG(GREEN     ), ITALIC       ]));
        assert("\u001b[43;4mYELLOW_BG_UN\u001b[24;49m"          , StyleTools.style("YELLOW_BG_UN" , [ COLOR_BG(YELLOW    ), UNDERLINE    ]));
        assert("\u001b[44;5mBLUE_BG_BL_S\u001b[25;49m"          , StyleTools.style("BLUE_BG_BL_S" , [ COLOR_BG(BLUE      ), BLINK(false) ]));
        assert("\u001b[35;6mMAGENTA_BL_F\u001b[25;39m"          , StyleTools.style("MAGENTA_BL_F" , [ COLOR_FG(MAGENTA   ), BLINK(true ) ]), COLOR_BG(RED));
        assert("\u001b[37;7mWHITE_INV\u001b[27;39m"             , StyleTools.style("WHITE_INV"    , [ COLOR_FG(WHITE     ), INVERSE      ]), COLOR_BG(RED));
        assert("\u001b[36;8mCYAN_HIDE\u001b[28;39m"             , StyleTools.style("CYAN_HIDE"    , [ COLOR_FG(CYAN      ), CONCEAL      ]), COLOR_BG(RED));
        assert("\u001b[38;2;255;165;0;9mORANGE_STR\u001b[29;39m", StyleTools.style("ORANGE_STR"   , [ COLOR_FG(ORANGE    ), STRIKETHROUGH]), COLOR_BG(RED));
        
        #if logger.unit_test.show_styles
        trace(results.join(" "));
        #end
    }
    
    function testUnstyle()
    {
        Assert.equals("GRAY_BG"   , StyleTools.unstyle("\u001b[40mGRAY_BG\u001b[49m"                ));
        Assert.equals("RED_BG"    , StyleTools.unstyle("\u001b[41mRED_BG\u001b[49m"                 ));
        Assert.equals("GREEN_BG"  , StyleTools.unstyle("\u001b[42mGREEN_BG\u001b[49m"               ));
        Assert.equals("YELLOW_BG" , StyleTools.unstyle("\u001b[43mYELLOW_BG\u001b[49m"              ));
        Assert.equals("BLUE_BG"   , StyleTools.unstyle("\u001b[44mBLUE_BG\u001b[49m"                ));
        Assert.equals("MAGENTA_BG", StyleTools.unstyle("\u001b[45mMAGENTA_BG\u001b[49m"             ));
        Assert.equals("CYAN_BG"   , StyleTools.unstyle("\u001b[46mCYAN_BG\u001b[49m"                ));
        Assert.equals("WHITE_BG"  , StyleTools.unstyle("\u001b[47mWHITE_BG\u001b[49m"               ));
        Assert.equals("ORANGE_BG" , StyleTools.unstyle("\u001b[48;2;255;165;0mORANGE_BG\u001b[49m"  ));
        Assert.equals("PURPLE_BG" , StyleTools.unstyle("\u001b[48;2;128;0;128mPURPLE_BG\u001b[49m"  ));
        Assert.equals("PINK_BG"   , StyleTools.unstyle("\u001b[48;2;255;192;203mPINK_BG\u001b[49m"  ));
        Assert.equals("000000_BG" , StyleTools.unstyle("\u001b[48;2;0;0;0m000000_BG\u001b[49m"      ));
        Assert.equals("AAAAAA_BG" , StyleTools.unstyle("\u001b[48;2;170;170;170mAAAAAA_BG\u001b[49m"));
        
        Assert.equals("BOLD"         , StyleTools.unstyle("\u001b[1mBOLD\u001b[22m"         ));
        Assert.equals("DIM"          , StyleTools.unstyle("\u001b[2mDIM\u001b[22m"          ));
        Assert.equals("ITALIC"       , StyleTools.unstyle("\u001b[3mITALIC\u001b[23m"       ));
        Assert.equals("UNDERLINE"    , StyleTools.unstyle("\u001b[4mUNDERLINE\u001b[24m"    ));
        Assert.equals("BLINK_SLOW"   , StyleTools.unstyle("\u001b[5mBLINK_SLOW\u001b[25m"   ));
        Assert.equals("BLINK_FAST"   , StyleTools.unstyle("\u001b[6mBLINK_FAST\u001b[25m"   ));
        Assert.equals("INVERSE"      , StyleTools.unstyle("\u001b[7mINVERSE\u001b[27m"      ));
        Assert.equals("CONCEAL"      , StyleTools.unstyle("\u001b[8mCONCEAL\u001b[28m"      ));
        Assert.equals("STRIKETHROUGH", StyleTools.unstyle("\u001b[9mSTRIKETHROUGH\u001b[29m"));
    }
    
    function testUsing()
    {
        assertStyle("\u001b[37mWHITE\u001b[39m", "WHITE".color(WHITE));
        assertStyle("\u001b[2mDIM\u001b[22m", "DIM".style(DIM));
        assertStyle("\u001b[3;4mITALIC_UNDERLINE\u001b[24;23m", "ITALIC_UNDERLINE".style([ITALIC, UNDERLINE]));
        assertStyle("ITALIC_UNDERLINE", "\u001b[3;4mITALIC_UNDERLINE\u001b[23;24m".unstyle());
    }
    
    @:ignore
    function assertStyle(expected:String, actual:String, ?msg, ?pos)
    {
        return Assert.equals(expected, actual, msg ?? 'Expected "$expected", got "$actual". Codes: "${escape(expected)}", "${escape(actual)}"', pos);
    }
    
    @:ignore
    function escape(str:String)
    {
        return str.split("\u001b").join("\\u001b");
    }
}