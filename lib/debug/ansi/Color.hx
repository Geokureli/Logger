package debug.ansi;

import haxe.xml.Access;

/**
 * Class representing a color, based on Int
 */
enum abstract Color(Int) from Int from UInt to Int to UInt
{
    var BLACK   = 0x000000; // 30
    var RED     = 0xFF0000; // 31
    var GREEN   = 0x00FF00; // 32
    var YELLOW  = 0xFFFF00; // 33
    var BLUE    = 0x0000FF; // 34
    var MAGENTA = 0xFF00FF; // 35
    var CYAN    = 0x00FFFF; // 36
    var WHITE   = 0xFFFFFF; // 37
    var GRAY    = 0x808080;
    var ORANGE  = 0xFFA500;
    var PURPLE  = 0x800080;
    var PINK    = 0xFFC0CB;
    var BROWN   = 0x8B4513;
    
    public var red  (get, never):UInt;
    public var blue (get, never):UInt;
    public var green(get, never):UInt;
    
    inline function get_red  ():UInt return (this >> 16) & 0xFF;
    inline function get_green():UInt return (this >>  8) & 0xFF;
    inline function get_blue ():UInt return (this >>  0) & 0xFF;
    
    /**
     * Set RGB values as integers (0 to 255)
     *
     * @param   red    The red value of the color from 0 to 255
     * @param   green  The green value of the color from 0 to 255
     * @param   blue   The green value of the color from 0 to 255
     * @return This color
     */
    inline public function set(red:UInt, green:UInt, blue:UInt):Color
    {
        return this = concat(red, green, blue);
    }
    
    /**
     * Creates a color from an RGB int
     * 
     * @param   value      Usually a hex integer, I.E.: 0xFF00FF
     * @param   clampBits  If true, discards extra bits, I.E.: 0xFF00FF00 becomes 0x00FF00
     */
    overload public inline extern function new(value:UInt, clampBits = false)
    {
        this = clampBits ? value & 0xFFFFFF : value;
    }
    
    overload public inline extern function new(red:UInt, green:UInt, blue:UInt)
    {
        this = concat(red, green, blue);
    }
    
    /**
     * Returns a new color with extra bits discarded
     */
    inline public function to24Bit()
    {
        return new Color(this, true);
    }
    
    /**
     * Creates a hex string representing this color, in the format "0xRRGGBB"
     */
    public function toString()
    {
        return '0x' + StringTools.lpad(StringTools.hex(this), "0", 6);
    }
    
    /**
     * Internal helper for concatenating three color bytes into 1 24bit integer
     * 
     * @param   red    The red value of the color from 0 to 255
     * @param   green  The green value of the color from 0 to 255
     * @param   blue   The green value of the color from 0 to 255
     */
    static public inline function concat(red:UInt, green:UInt, blue:UInt)
    {
        return ((red   & 0xFF) << 16)
            |  ((green & 0xFF) <<  8)
            |  ((blue  & 0xFF) <<  0);
    }
}