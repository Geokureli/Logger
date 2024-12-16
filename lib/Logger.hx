package;

import haxe.PosInfos;

/**
 * Tool used to simplify the categorization of logs, and easily customize which type of logs
 * are displayed, and which throw exceptions.
 * 
 * ## Creating categories
 * To create categories, simple instantiate multiple `Logger` instances, like so:
 * ```haxe
 * static public var combatLog = new Logger("Combat", WARN);
 * static public var resourceLog = new Logger("Res", INFO);
 * ```
 * 
 * Typically, though, you would give each static class, tool or important object it's own `Logger`,
 * such as `CombatUtil.log` or `myHero.log`. For uncategorized logs, simply use `Logger.log`
 * 
 * ## Logging
 * To log, you can call Logger instances as if they were functions, for example:
 * `Logger.log(imporantInfo);` or `CombatUtil.log("battle started")`, but each logger also has
 * various priorities that are conditionally logged, like `Logger.log.error("Missing asset")`
 * or `CombatUtil.log.verbose("attacked for 5 damage");`. While these log priorities can be called,
 * they too, also have fields. You can disable a certain priority like so: `log.verbose.enabled = false;`
 * or you can make a certain priority throw exceptions instead of logging via: `log.warn.throws = true;`
 * 
 * ## Enabling logs via compile flags
 * While the `Logger` constructor has `priority` and `throwPriority` args, these can be
 * overriden from compiler flags, by adding the flag `-D log=WARN` all log priorities less than
 * `WARN` (i.e.: `INFO` and `VERBOSE`) are disabled. You can also specify exactly which priorities
 * are enabled, for example, `-D log=[info,error]` will disable all priorities other than `INFO`
 * and `ERROR`. The `log` flag will also effect all categories, unless the category has it's own
 * log priorities set in compiler flags. For example, a logger with the id "Combat" can have its
 * log priorities set via `-D combat.log=error`. There is a similar `throw` flag to specify which
 * logs throw an exception
 */
@:forward
abstract Logger(LoggerRaw)
{
    /**
     * The default logger, able to be referenced anywhere
     * 
     * Tip: Use `import.Logger.log;` in a module to simplfy your calls
     */
    static public final log = new Logger(VERBOSE);
    
    /**
     * Controls how each every Logger will actually log the message, this can also be set for each
     * individual logger with:
     * `myLogger.log = (msg, ?pos)->haxe.Log.trace('[${getTimestamp()}] $msg', pos);`
     */
    dynamic static public function globalLog(msg:Any, ?pos:PosInfos)
    {
        haxe.Log.trace(msg, pos);
    }
    
    /**
     * Creates a new logger
     * 
     * **Note:** `priority` and `throwPriority` can be overwritten via compiler flags
     * 
     * @param   id             The category of these logs, will prefix each log and specific culling
     * @param   priority       Determines the lowest priority to be logged
     * @param   throwPriority  Determines the lowest priority to throw exceptions
     */
    public function new(?id, priority = WARN, throwPriority = ERROR)
    {
        this = new LoggerRaw(id, priority, throwPriority);
    }
    
    @:op(a())
    inline function callPos(msg:Any, ?pos:PosInfos)
    {
        this.log(msg, pos);
    }
}

@:allow(Logger)
private class LoggerRaw
{
    /**
     * The category of this logger, will prefix each log and specific culling
     */
    public final id:Null<String>;
    
    final logLevels:LogLevelList;
    final throwLevels:LogLevelList;
    final prefix:String = "";
    
    /** Meant to be called, directly like a function, but also has an `enabled` and `throws` field */
    public final error:LoggerLevel;
    
    /** Meant to be called, directly like a function, but also has an `enabled` and `throws` field */
    public final warn:LoggerLevel;
    
    /** Meant to be called, directly like a function, but also has an `enabled` and `throws` field */
    public final info:LoggerLevel;
    
    /** Meant to be called, directly like a function, but also has an `enabled` and `throws` field */
    public final verbose:LoggerLevel;
    
    public function new(id, priority = WARN, throwPriority = ERROR)
    {
        this.id = id;
        this.prefix = id == null || id == "" ? "" : '$id - ';
        logLevels = LogLevelList.fromCompilerFlag("log", id, LogLevelList.fromPriority(priority));
        throwLevels = LogLevelList.fromCompilerFlag("throw", id, LogLevelList.fromPriority(throwPriority));
        error = new LoggerLevel(this, ERROR);
        warn = new LoggerLevel(this, WARN);
        info = new LoggerLevel(this, INFO);
        verbose = new LoggerLevel(this, VERBOSE);
    }
    
    public function destroy()
    {
        error.destroy();
        warn.destroy();
        info.destroy();
        verbose.destroy();
    }
    
    dynamic public function log(msg:Any, ?pos:PosInfos)
    {
        Logger.globalLog('${prefix}$msg', pos);
    }
    
    /**
     * Determines the lowest priority to be logged
     */
    public function setPriority(value:LogLevel)
    {
        logLevels.setPriority(value);
    }
    
    /**
     * Determines the lowest priority that will throw exceptions
     */
    public function setThrowPriority(value:LogLevel)
    {
        throwLevels.setPriority(value);
    }
    
    inline function logEnabled(level:LogLevel)
    {
        return logLevels.has(level);
    }
    
    inline function setLogEnabled(level:LogLevel, value:Bool):Bool
    {
        return logLevels.set(level, value);
    }
    
    inline function throwEnabled(level:LogLevel)
    {
        return throwLevels.has(level);
    }
    
    inline function setThrowEnabled(level:LogLevel, value:Bool):Bool
    {
        return throwLevels.set(level, value);
    }
    
    inline function logIf(level:LogLevel, msg:Any, ?pos)
    {
        if (throwEnabled(level))
            throw '${prefix}$msg';
        
        if (logEnabled(level))
            log(msg, pos);
    }
}

@:forward(enabled, throws)
abstract LoggerLevel(LoggerLevelRaw)
{
    public function new(parent, level)
    {
        this = new LoggerLevelRaw(parent, level);
    }
    
    @:op(a())
    inline function callPos(msg:Any, ?pos:PosInfos)
    {
        this.log(msg, pos);
    }
    
    @:allow(LoggerRaw)
    inline function destroy()
    {
        this.destroy();
    }
}

@:allow(LoggerLevel)
private class LoggerLevelRaw
{
    var parent:LoggerRaw;
    final level:LogLevel;
    final prefix:String;
    
    /** Whether this log level is enabled */
    public var enabled(get, set):Bool;
    inline function get_enabled() return parent.logEnabled(level);
    inline function set_enabled(value:Bool) return parent.setLogEnabled(level, value);
    
    /** Whether this log level is set to throw exceptions when called */
    public var throws(get, set):Bool;
    inline function get_throws() return parent.throwEnabled(level);
    inline function set_throws(value:Bool) return parent.setThrowEnabled(level, value);
    
    public function new(parent:LoggerRaw, level:LogLevel)
    {
        this.parent = parent;
        this.level = level;
        this.prefix = '$level:';
    }
    
    public function destroy()
    {
        parent = null;
    }
    
    function log(msg:Any, ?pos:PosInfos):Void
    {
        parent.logIf(level, '${prefix}${msg}', pos);
    }
}

abstract LogLevelList(Array<LogLevel>) from Array<LogLevel>
{
    inline public function new(levels:Array<LogLevel>)
    {
        this = levels;
    }
    
    public function setPriority(priority:LogLevel)
    {
        this.resize(0);
        for (level in LogLevel.all)
        {
            if (priority.priority >= level.priority)
                add(level);
        }
    }
    
    inline public function has(level:LogLevel)
    {
        return this.contains(level);
    }
    
    public function add(level:LogLevel)
    {
        if (has(level) == false)
            this.push(level);
    }
    
    inline public function remove(level:LogLevel)
    {
        this.remove(level);
    }
    
    public function set(level:LogLevel, value:Bool)
    {
        if (value == false && has(level))
            this.remove(level);
        else if (value && has(level) == false)
            this.push(level);
        
        return value;
    }
    
    static final arrReg = ~/^\[(.+)\]$/;
    
    /**
     * If `value` is `"0"`-`"4"` or matches the name of a `LogLevel`, all levels up to
     * that level are enabled. If `value` has commas or is wrapped in square brackets,
     * those listed levels are enabled
     */
    static public function fromString(value:String):LogLevelList
    {
        final isArray = arrReg.match(value);
        // remove square brackets
        if (isArray)
            value = arrReg.matched(1);
        
        if (value.indexOf(",") != -1 || isArray)
            return value.split(",").map(LogLevel.fromString);
        
        return fromPriority(LogLevel.fromString(value));
    }
    
    static public function fromPriority(level:LogLevel):LogLevelList
    {
        return LogLevel.all.filter((l) -> level.priority >= l.priority);
    }
    
    static public function fromGlobalCompilerFlag(backup:LogLevelList):LogLevelList
    {
        if (LoggerDefines.all.exists("log"))
            return fromString(LoggerDefines.all["log"]);
        
        return backup;
    }
    
    static public function fromCompilerFlag(type:String, id:Null<String>, backup:LogLevelList):LogLevelList
    {
        // Use global log level if there's no id
        if (id == null)
            return fromGlobalCompilerFlag(backup);
        
        // Use specific log level if one is set, Note: tasc[foo] uses log.tasc
        final featureID = id.split('[')[0].toLowerCase();
        final flagID = '$featureID.$type';
        if (LoggerDefines.all.exists(flagID))
            return fromString(LoggerDefines.all[flagID]);
        
        // Use global log level as backup
        return fromGlobalCompilerFlag(backup);
    }
}

/**
 * The varying degrees of importance that a log can have, used to selectively cull logs
 */
@:allow(LogLevelList)
enum abstract LogLevel(Int)
{
    var NONE = 0;
    var ERROR = 1;
    var WARN = 2;
    var INFO = 3;
    var VERBOSE = 4;
    
    /**
     * A number representing this level's importance, the lower the number, the higher the priority,
     * or the greater the importance
     */
    public var priority(get, never):Int;
    
    inline function get_priority()
        return this;
    
    /**
     * Contains every log priority
     */
    static public final all = [NONE, ERROR, WARN, INFO, VERBOSE];
    
    public function toString()
    {
        return switch abstract
        {
            case NONE: "NONE";
            case ERROR: "ERROR";
            case WARN: "WARN";
            case INFO: "INFO";
            case VERBOSE: "VERBOSE";
        }
    }
    
    static public function fromString(value:String):LogLevel
    {
        return switch (value.toUpperCase())
        {
            case "0" | "NONE": NONE;
            case "1" | "ERROR": ERROR;
            case "2" | "WARN": WARN;
            case "3" | "INFO": INFO;
            case "4" | "VERBOSE": VERBOSE;
            case unexpected: throw 'Unexpected logLevel: $unexpected';
        }
    }
}

private class LoggerDefines
{
    /**
     * Every single compiler flag, and its value
     */
    #if (!display && !macro)
    public static final all:Map<String, String> = getDefines();
  	#else
    public static final all:Map<String, String> = [];
    #end
    
    static macro function getDefines()
    {
        return buildDefines();
    }
    
    #if macro
    public static function buildDefines():haxe.macro.Expr
    {
        final defines = haxe.macro.Context.getDefines();
        final expr = [for (name => value in defines) macro $v{name} => $v{value}];
        return macro $a{expr};
    }
    #end
}
