package debug;

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
 * overriden from compiler flags, for example: 
 * - `-D log=WARN`: Set global log-priority to warnings and errors
 * - `-D throw=ERROR`: Set global throw-priority to errors
 * - `-D log=[info,error]`: Only log info and errors, not warnings and verbose
 * - `-D combat.log=verbose`: Enable ALL logs with the id "Combat" (not case sensitive), overrides global log-priority
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
    
    dynamic static public function globalFormatter(id:String, priority:Priority, msg:Any, ?pos:PosInfos)
    {
        return priority != NONE ? '$id[$priority]: $msg' : '$id: $msg';
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

@:allow(debug.Logger)
private class LoggerRaw
{
    /**
     * The category of this logger, will prefix each log and specific culling
     */
    public final id:Null<String>;
    
    final logLevels:PriorityList;
    final throwLevels:PriorityList;
    final prefix:String = "";
    
    /** Meant to be called, directly like a function, but also has an `enabled` and `throws` field */
    public final error:LoggerPriority;
    
    /** Meant to be called, directly like a function, but also has an `enabled` and `throws` field */
    public final warn:LoggerPriority;
    
    /** Meant to be called, directly like a function, but also has an `enabled` and `throws` field */
    public final info:LoggerPriority;
    
    /** Meant to be called, directly like a function, but also has an `enabled` and `throws` field */
    public final verbose:LoggerPriority;
    
    public function new(id, priority = WARN, throwPriority = ERROR)
    {
        this.id = id;
        this.prefix = id == null || id == "" ? "" : '$id - ';
        logLevels = PriorityList.fromCompilerFlag("log", id, PriorityList.fromPriority(priority));
        throwLevels = PriorityList.fromCompilerFlag("throw", id, PriorityList.fromPriority(throwPriority));
        error = new LoggerPriority(this, ERROR);
        warn = new LoggerPriority(this, WARN);
        info = new LoggerPriority(this, INFO);
        verbose = new LoggerPriority(this, VERBOSE);
    }
    
    public function destroy()
    {
        error.destroy();
        warn.destroy();
        info.destroy();
        verbose.destroy();
    }
    
    public function log(msg:Any, ?pos:PosInfos)
    {
        if (logLevels.isEmpty() == false)
            logFinal(NONE, msg, pos);
    }
    
    function logFinal(priority:Priority, msg:Any, ?pos:PosInfos)
    {
        Logger.globalLog(formatter(priority, msg, pos), pos);
    }
    
    dynamic public function formatter(priority:Priority, msg:Any, ?pos:PosInfos)
    {
        return Logger.globalFormatter(id, priority, msg, pos);
    }
    
    /**
     * Determines the lowest priority to be logged
     */
    public function setPriority(value:Priority)
    {
        logLevels.setPriority(value);
    }
    
    /**
     * Determines the lowest priority that will throw exceptions
     */
    public function setThrowPriority(value:Priority)
    {
        throwLevels.setPriority(value);
    }
    
    inline function logEnabled(level:Priority)
    {
        return logLevels.has(level);
    }
    
    inline function setLogEnabled(level:Priority, value:Bool):Bool
    {
        return logLevels.set(level, value);
    }
    
    inline function throwEnabled(level:Priority)
    {
        return throwLevels.has(level);
    }
    
    inline function setThrowEnabled(level:Priority, value:Bool):Bool
    {
        return throwLevels.set(level, value);
    }
    
    inline function logIf(level:Priority, msg:Any, ?pos)
    {
        if (throwEnabled(level))
            throw '${prefix}$msg';
        
        if (logEnabled(level))
            logFinal(level, msg, pos);
    }
}

@:forward(enabled, throws)
abstract LoggerPriority(LoggerPriorityRaw)
{
    public function new(parent, level)
    {
        this = new LoggerPriorityRaw(parent, level);
    }
    
    @:op(a())
    inline function callPos(msg:Any, ?pos:PosInfos)
    {
        this.log(msg, pos);
    }
    
    @:allow(debug.LoggerRaw)
    inline function destroy()
    {
        this.destroy();
    }
}

@:allow(debug.LoggerPriority)
private class LoggerPriorityRaw
{
    var parent:LoggerRaw;
    final level:Priority;
    
    /** Whether this log level is enabled */
    public var enabled(get, set):Bool;
    inline function get_enabled() return parent.logEnabled(level);
    inline function set_enabled(value:Bool) return parent.setLogEnabled(level, value);
    
    /** Whether this log level is set to throw exceptions when called */
    public var throws(get, set):Bool;
    inline function get_throws() return parent.throwEnabled(level);
    inline function set_throws(value:Bool) return parent.setThrowEnabled(level, value);
    
    public function new(parent:LoggerRaw, level:Priority)
    {
        this.parent = parent;
        this.level = level;
    }
    
    public function destroy()
    {
        parent = null;
    }
    
    function log(msg:Any, ?pos:PosInfos):Void
    {
        parent.logIf(level, msg, pos);
    }
}

abstract PriorityList(Array<Priority>) from Array<Priority>
{
    inline public function new(levels:Array<Priority>)
    {
        this = levels;
    }
    
    public function setPriority(priority:Priority)
    {
        this.resize(0);
        for (level in Priority.allButNone)
        {
            if (priority.priority >= level.priority)
                add(level);
        }
    }
    
    inline public function isEmpty()
    {
        return this.length == 0;
    }
    
    inline public function has(level:Priority)
    {
        return this.contains(level);
    }
    
    public function add(level:Priority)
    {
        if (has(level) == false)
            this.push(level);
    }
    
    inline public function remove(level:Priority)
    {
        this.remove(level);
    }
    
    public function set(level:Priority, value:Bool)
    {
        if (value == false && has(level))
            this.remove(level);
        else if (value && has(level) == false)
            this.push(level);
        
        return value;
    }
    
    static final arrReg = ~/^\[(.+)\]$/;
    
    /**
     * If `value` is `"0"`-`"4"` or matches the name of a `Priority`, all levels up to
     * that level are enabled. If `value` has commas or is wrapped in square brackets,
     * those listed levels are enabled
     */
    static public function fromString(value:String):PriorityList
    {
        final isArray = arrReg.match(value);
        // remove square brackets
        if (isArray)
            value = arrReg.matched(1);
        
        if (value == "NONE")
            return [];
        
        if (value.indexOf(",") != -1 || isArray)
            return value.split(",").map(Priority.fromString);
        
        return fromPriority(Priority.fromString(value));
    }
    
    static public function fromPriority(level:Priority):PriorityList
    {
        return Priority.allButNone.filter((l) -> level.priority >= l.priority);
    }
    
    static public function fromGlobalCompilerFlag(backup:PriorityList):PriorityList
    {
        if (LoggerDefines.all.exists("log"))
            return fromString(LoggerDefines.all["log"]);
        
        return backup;
    }
    
    static public function fromCompilerFlag(type:String, id:Null<String>, backup:PriorityList):PriorityList
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
@:allow(debug.PriorityList)
enum abstract Priority(Int)
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
    static public final allButNone = [ERROR, WARN, INFO, VERBOSE];
    
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
    
    static public function fromString(value:String):Priority
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