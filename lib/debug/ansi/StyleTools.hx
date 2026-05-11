package debug.ansi;

class StyleTools
{
    overload static public inline extern function unstyle(string:String):String
    {
        // #if interp
        final split = string.split("\u001b[");
        for (i in 1...split.length)// skip first
        {
            final str = split[i];
            split[i] = str.substr(str.indexOf("m") + 1);
        }
        
        return split.join("");
        // #else // TODO: Test on various targets
        // try
        // {
        //     static final remover = ~/\u001b\[[0-9;]+m/g;
        //     return remover.split(string).join("");
        // }
        // catch(e)
        // {
        //     throw "Error creating EReg, create an issue, here: https://github.com/Geokureli/Logger/issues/new"
        // }
        // #end
    }
    
    overload static public inline extern function style(string:String, style:Style):String
    {
        return apply(string, style);
    }
    
    overload static public inline extern function style(string:String, styles:Array<Style>):String
    {
        return applyMany(string, styles);
    }
    
    overload static public inline extern function style(string:String, color:ColorStyle):String
    {
        return apply(string, COLOR_FG(color));
    }
    
    static function apply(string:String, style:Style):String
    {
        final start = switch style
        {
            case UNDERLINE    : AnsiCode.UNDERLINE_ON;
            case DIM          : AnsiCode.DIM_ON;
            case BOLD         : AnsiCode.BOLD_ON;
            case ITALIC       : AnsiCode.ITALIC_ON;
            case INVERSE      : AnsiCode.INVERSE_ON;
            case CONCEAL      : AnsiCode.CONCEAL_ON;
            case STRIKETHROUGH: AnsiCode.STRIKETHROUGH_ON;
            case BLINK(true)  : AnsiCode.BLINK_FAST;
            case BLINK(false) : AnsiCode.BLINK_SLOW;
            case COLOR_FG(col): AnsiCode.getForeground(col);
            case COLOR_BG(col): AnsiCode.getBackground(col);
        }
        
        final end = switch style
        {
            case UNDERLINE    : AnsiCode.UNDERLINE_OFF;
            case DIM          : AnsiCode.INTESITY_OFF;
            case BOLD         : AnsiCode.BOLD_OFF;
            case ITALIC       : AnsiCode.ITALIC_OFF;
            case INVERSE      : AnsiCode.INVERSE_OFF;
            case CONCEAL      : AnsiCode.CONCEAL_OFF;
            case STRIKETHROUGH: AnsiCode.STRIKETHROUGH_OFF;
            case BLINK(_)     : AnsiCode.BLINK_OFF;
            case COLOR_FG(_)  : AnsiCode.FG_OFF;
            case COLOR_BG(_)  : AnsiCode.BG_OFF;
        }
        
        return '${start}${string}${end}';
    }
    
    static function applyMany(string:String, styles:Array<Style>):String
    {
        for (style in styles)
            string = apply(string, style);
        return string;
    }
}

enum Style
{
    UNDERLINE;
    DIM;
    BOLD;
    ITALIC;
    INVERSE;
    CONCEAL;
    STRIKETHROUGH;
    BLINK(fast:Bool);
    COLOR_FG(color:ColorStyle);
    COLOR_BG(color:ColorStyle);
}

enum abstract ColorStyle(Int)
{
    var BLACK         = 0;
    var RED           = 1;
    var GREEN         = 2;
    var YELLOW        = 3;
    var BLUE          = 4;
    var MAGENTA       = 5;
    var CYAN          = 6;
    var WHITE         = 7;
    var DEFAULT       = 9;
    
    function toInt()
    {
        return this;
    }
}

private enum abstract AnsiCode(Int) from Int to Int
{
    var RESET = 0;
    var BOLD_ON = 1;
    var DIM_ON = 2; //Not widely supported.
    var ITALIC_ON = 3; // Not widely supported. //Sometimes treated as inverse.
    var UNDERLINE_ON = 4;
    var BLINK_SLOW = 5; // less than 150 per minute
    var BLINK_FAST = 6; // 150+ per minute; not widely supported
    var INVERSE_ON = 7; // [[reverse video]]	swap foreground and background colors
    var CONCEAL_ON = 8; // Not widely supported.
    var STRIKETHROUGH_ON = 9;// Not widely supported.
    // var DEFAULT_FONT = 10;
    // var ALT_FONT1 = 11;
    // var ALT_FONT2 = 12;
    // var ALT_FONT3 = 13;
    // var ALT_FONT4 = 14;
    // var ALT_FONT5 = 15;
    // var ALT_FONT6 = 16;
    // var ALT_FONT7 = 17;
    // var ALT_FONT8 = 18;
    // var ALT_FONT9 = 19;
    var BOLD_OFF = 21;
    var INTESITY_OFF = 22;// dim or bold
    var ITALIC_OFF = 23;
    var UNDERLINE_OFF = 24;
    var BLINK_OFF = 25;
    var INVERSE_OFF = 27;
    var CONCEAL_OFF = 28;
    var STRIKETHROUGH_OFF = 29;
    var FG_BLACK   = 30;
    var FG_RED     = 31;
    var FG_GREEN   = 32;
    var FG_YELLOW  = 33;
    var FG_BLUE    = 34;
    var FG_MAGENTA = 35;
    var FG_CYAN    = 36;
    var FG_WHITE   = 37;
    var FG_OFF     = 39;
    var BG_BLACK   = 40;
    var BG_RED     = 41;
    var BG_GREEN   = 42;
    var BG_YELLOW  = 43;
    var BG_BLUE    = 44;
    var BG_MAGENTA = 45;
    var BG_CYAN    = 46;
    var BG_WHITE   = 47;
    var BG_OFF     = 49;
    var FRAME_SQUARE = 51;
    var FRAME_CIRCLE = 52;
    var OVERLINE = 53;
    var FRAME_OFF = 54;
    var OVERLINE_OFF = 54;
    
    static public function getForeground(color:ColorStyle):AnsiCode
    {
        @:privateAccess
        return FG_BLACK.toInt() + color.toInt();
    }
    
    static public function getBackground(color:ColorStyle):AnsiCode
    {
        @:privateAccess
        return BG_BLACK.toInt() + color.toInt();
    }
    
    public function toString()
    {
        return '\u001b[${this}m';
    }
    
    function toInt():Int
    {
        return this;
    }
}