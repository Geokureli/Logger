package debug.ansi;

import debug.ansi.Color;
import utest.Assert;

class ColorTest extends utest.Test
{
    function testNew()
    {
        assertColor(0x0080FF, new Color(0x00, 0x80, 0xFF));
        assertColor(0x00, 0x80, 0xFF, new Color(0x00, 0x80, 0xFF));
        
        // test over 255
        assertColor(0x00, 0x80, 0xF0, new Color(0xFF00, 0x8080, 0x01F0));
        
        // test no clamp
        assertColor(0xFF0080FF, new Color(0xFF0080FF));
        // test clamp
        assertColor(0x0080FF, new Color(0xFF0080FF, true));
    }
    
    function testIntCast()
    {
        assertColor(0x0080FF, 0x0080FF);
        assertColor(0x00, 0x80, 0xFF, 0xFF0080FF); // alpha ignored
    }
    
    function testToString()
    {
        final color:Color = 0xFF0000;
        Assert.equals("0xFF0000", '$color');
        final color:Color = 0x0080FF;
        Assert.equals("0x0080FF", '$color');
        final color:Color = 0xFF0080FF;
        Assert.equals("0xFF0080FF", '$color');
    }
    
    function testGetters()
    {
        final color:Color = 0xFF0080FF;
        Assert.equals(0x00, color.red);
        Assert.equals(0x80, color.green);
        Assert.equals(0xFF, color.blue);
    }
    
    function testTo24Bit()
    {
        assertColor(0xFF0080FF, new Color(0xFF0080FF));
        assertColor(0x0080FF, new Color(0xFF0080FF).to24Bit());
    }
    
    @:ignore
    overload inline extern function assertColor(expected:Color, actual:Color, ?msg, ?pos)
    {
        // return Assert.equals(expected, actual);
        Assert.equals(expected, actual, msg ?? 'Expected [$expected], got [$actual]', pos);
    }
    
    @:ignore
    overload inline extern function assertColor(r:UInt, g:UInt, b:UInt, actual:Color, ?msg, ?pos)
    {
        Assert.isTrue(actual.red == r && actual.green == g && actual.blue == b
            , msg ?? 'Expected [$r, $g, $b], got [${actual.red}, ${actual.green}, ${actual.blue}]'
            , pos
            );
    }
}