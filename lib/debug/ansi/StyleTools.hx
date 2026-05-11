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
    
    static public inline function color(string:String, color:Color):String
    {
        return apply(string, COLOR_FG(color));
    }
    
    static function apply(string:String, style:Style):String
    {
        final on = getOnCode(style);
        final off = getOffCode(style);
        return '\u001b[${on}m${string}\u001b[${off}m';
    }
    
    static function applyMany(string:String, styles:Array<Style>):String
    {
        final on = styles.map(getOnCode).join(";");
        final offFor = styles.map(getOffCode);
        offFor.reverse();
        final off = offFor.join(";");
        return '\u001b[${on}m${string}\u001b[${off}m';
    }
    
    static function getOnCode(style:Style):String
    {
        return switch style
        {
            case UNDERLINE    : AnsiCode.UNDERLINE_ON.toCode();
            case DIM          : AnsiCode.DIM_ON.toCode();
            case BOLD         : AnsiCode.BOLD_ON.toCode();
            case ITALIC       : AnsiCode.ITALIC_ON.toCode();
            case INVERSE      : AnsiCode.INVERSE_ON.toCode();
            case CONCEAL      : AnsiCode.CONCEAL_ON.toCode();
            case STRIKETHROUGH: AnsiCode.STRIKETHROUGH_ON.toCode();
            case BLINK(true)  : AnsiCode.BLINK_FAST.toCode();
            case BLINK(false) : AnsiCode.BLINK_SLOW.toCode();
            case COLOR_FG(col): AnsiCode.getForeground(col);
            case COLOR_BG(col): AnsiCode.getBackground(col);
        }
    }
    
    static function getOffCode(style:Style):String
    {
        return (switch style
        {
            case UNDERLINE    : AnsiCode.UNDERLINE_OFF;
            case DIM          : AnsiCode.INTESITY_OFF;
            case BOLD         : AnsiCode.INTESITY_OFF;
            case ITALIC       : AnsiCode.ITALIC_OFF;
            case INVERSE      : AnsiCode.INVERSE_OFF;
            case CONCEAL      : AnsiCode.CONCEAL_OFF;
            case STRIKETHROUGH: AnsiCode.STRIKETHROUGH_OFF;
            case BLINK(_)     : AnsiCode.BLINK_OFF;
            case COLOR_FG(_)  : AnsiCode.FG_OFF;
            case COLOR_BG(_)  : AnsiCode.BG_OFF;
        }).toCode();
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
    COLOR_FG(color:Color);
    COLOR_BG(color:Color);
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
    var FG_CUSTOM  = 38;
    var FG_OFF     = 39;
    var BG_BLACK   = 40;
    var BG_RED     = 41;
    var BG_GREEN   = 42;
    var BG_YELLOW  = 43;
    var BG_BLUE    = 44;
    var BG_MAGENTA = 45;
    var BG_CYAN    = 46;
    var BG_WHITE   = 47;
    var BG_CUSTOM  = 48;
    var BG_OFF     = 49;
    var FRAME_SQUARE = 51;
    var FRAME_CIRCLE = 52;
    var OVERLINE = 53;
    var FRAME_OFF = 54;
    var OVERLINE_OFF = 54;
    
    static final fgMap =
        [ Color.GRAY    => FG_BLACK
        , Color.RED     => FG_RED
        , Color.GREEN   => FG_GREEN
        , Color.YELLOW  => FG_YELLOW
        , Color.BLUE    => FG_BLUE
        , Color.MAGENTA => FG_MAGENTA
        , Color.CYAN    => FG_CYAN
        , Color.WHITE   => FG_WHITE
        ];
        
    static final bgMap =
        [ Color.GRAY    => BG_BLACK
        , Color.RED     => BG_RED
        , Color.GREEN   => BG_GREEN
        , Color.YELLOW  => BG_YELLOW
        , Color.BLUE    => BG_BLUE
        , Color.MAGENTA => BG_MAGENTA
        , Color.CYAN    => BG_CYAN
        , Color.WHITE   => BG_WHITE
        ];
    
    static public function getForeground(color:Color):String
    {
        if (fgMap.exists(color.to24Bit()))
            return fgMap[color].toCode();
        
        return '${FG_CUSTOM.toInt()};2;${color.red};${color.green};${color.blue}';
    }
    
    static public function getBackground(color:Color):String
    {
        if (bgMap.exists(color.to24Bit()))
            return bgMap[color].toCode();
        
        return '${BG_CUSTOM.toInt()};2;${color.red};${color.green};${color.blue}';
    }
    
    public function toAnsiString()
    {
        return '\u001b[${this}m';
    }
    
    public function toCode()
    {
        return '${this}';
    }
    
    function toInt():Int
    {
        return this;
    }
}