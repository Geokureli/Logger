package debug;

import debug.Assert;
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
abstract Logger(LoggerRaw) from LoggerRaw
{
    /**
     * The default logger, able to be referenced anywhere
     * 
     * Tip: Use `import.debug.Logger.log;` in a module to simplfy your calls
     */
    static public final log:Logger = LoggerRaw.fromLevels(null, VERBOSE);
    
    /**
     * Shortcut for `Logger.log.error.assert`
     * 
     * Tip: Use `import.debug.Logger.assert;` in a module to simplfy your calls
     */
    static public var assert(get, never):Assert;
    static inline function get_assert():Assert
    {
        return log.assert;
    }
    
    /**
     * Controls how each every Logger will actually log the message, this can also be set for each
     * individual logger with:
     * `myLogger.log = (msg, ?pos)->haxe.Log.trace('[${getTimestamp()}] $msg', pos);`
     */
    dynamic static public function globalLog(msg:String, ?pos:PosInfos)
    {
        haxe.Log.trace(msg, pos);
    }
    
    /**
     * Set this to make a custom log formatter, and log will use this to format it's information
     */
    dynamic static public function globalFormatter(id:Null<String>, priority:Priority, msg:Any, ?pos:PosInfos)
    {
        return if (id != null && priority != NONE)
            '$id[$priority]: $msg';
            else if (priority != NONE)
            '$priority: $msg';
            else if (id != null)
            '$id: $msg';
            else
            '$msg';
    }
    
    static final list = new Map<String, LoggerRaw>();
    
    /**
     * Creates a new logger
     * 
     * **Note:** `priority` and `throwPriority` can be overwritten via compiler flags
     * 
     * @param   id             The category of these logs, will prefix each log and specific culling
     * @param   priority       Determines the lowest priority to be logged
     * @param   throwPriority  Determines the lowest priority to throw exceptions
     */
    inline public function new(?id, priority = WARN, throwPriority = ERROR)
    {
        if (id == null)
        {
            this = (cast Logger.log: LoggerRaw);
        }
        else if (list.exists(id))
        {
            // Note: do not set priority again
            this = list[id];
        }
        else
        {
            this = LoggerRaw.fromLevels(id, priority, throwPriority);
            list[id] = this;
        }
    }
    
    @:op(a())
    inline function callPos(msg:Any, ?pos:PosInfos)
    {
        this.log(msg, pos);
    }
    
    /**
     * Creates a sub-category of this category, capable of having its own priorities.
     * By default, the priorities will match this, unless specifically set via compile flags
     * 
     * @param   subID  The id of the sub category
     * @return  A different logger
     */
    public function sub(subID:String):Logger
    {
        if (this.id == null)
            return new Logger(subID);
        
        final fullID = '${this.id}.$subID';
        if (list.exists(fullID))
            return list[fullID];
        
        return list[fullID] = LoggerRaw.fromParent(subID, this);
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
    
    /**
     * Shortcut for `error.assert`
     */
    public var assert(get, never):Assert;
    inline function get_assert():Assert
    {
        return error.assert;
    }
    
    /** Meant to be called, directly like a function, but also has an `enabled` and `throws` field */
    public final error:LoggerPriority;
    
    /** Meant to be called, directly like a function, but also has an `enabled` and `throws` field */
    public final warn:LoggerPriority;
    
    /** Meant to be called, directly like a function, but also has an `enabled` and `throws` field */
    public final info:LoggerPriority;
    
    /** Meant to be called, directly like a function, but also has an `enabled` and `throws` field */
    public final verbose:LoggerPriority;
    
    public function new(?id, priority:PriorityList, throwPriority:PriorityList)
    {
        this.id = id;
        logLevels = PriorityList.fromCompilerFlag(LOG, id, priority);
        throwLevels = PriorityList.fromCompilerFlag(THROW, id, throwPriority);
        error = new LoggerPriority(this, ERROR);
        warn = new LoggerPriority(this, WARN);
        info = new LoggerPriority(this, INFO);
        verbose = new LoggerPriority(this, VERBOSE);
    }
    
    #if logger.unit_test
    public function resetFromCompilerFlags()
    {
        logLevels.resetFromCompilerFlags(LOG, id);
        throwLevels.resetFromCompilerFlags(THROW, id);
    }
    #end
    
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
    
    // TODO: public var formatter = Logger.globalFormatter;
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
            throw formatter(level, msg, pos);
        
        if (logEnabled(level))
            logFinal(level, msg, pos);
    }
    
    static public function fromLevels(id:Null<String>, logLevel = WARN, throwLevel = ERROR)
    {
        return new LoggerRaw(id, PriorityList.fromPriority(logLevel), PriorityList.fromPriority(throwLevel));
    }
    
    static public function fromParent(subID:String, parent:LoggerRaw)
    {
        final logger = new LoggerRaw('${parent.id}.$subID', parent.logLevels, parent.throwLevels);
        // logger.formatter = parent.formatter;
        return logger;
    }
}

abstract PriorityList(Array<Priority>) from Array<Priority>
{
    inline public function new(levels:Array<Priority>)
    {
        this = levels;
    }
    
    public function copy()
    {
        return this.copy();
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
    
    function copyBase(arr:Array<Priority>)
    {
        this.splice(0, this.length);
        for (i in 0...arr.length)
            this.push(arr[i]);
    }
    
    #if logger.unit_test
    public function resetFromCompilerFlags(type:LogType, id:String)
    {
        final newList = fromCompilerFlag(type, id, this);
        if (newList != this)
            copyBase(cast newList);
    }
    #end
    
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
    
    static public function fromGlobalCompilerFlag(type:LogType, backup:PriorityList):PriorityList
    {
        if (LoggerDefines.all.exists(type))
            return fromString(LoggerDefines.all[type]);
        
        return backup;
    }
    
    overload inline extern static public function fromCompilerFlag(type, id, backup:Priority)
    {
        return fromCompilerFlagHelper(type, id, fromPriority(backup));
    }
    
    overload inline extern static public function fromCompilerFlag(type, id, backup:PriorityList)
    {
        return fromCompilerFlagHelper(type, id, backup);
    }
    
    static final flagsByID = new Map<String, Null<String>>();
    
    inline static var SUB_DELIMITER = ".";
    static final contextFinder = ~/\[.*?\]/;
    static function fromCompilerFlagHelper(type:LogType, id:Null<String>, backup:PriorityList):PriorityList
    {
        // Use global log level if there's no id
        if (id == null)
            return fromGlobalCompilerFlag(type, backup);
        
        final id = contextFinder.replace(id.toLowerCase(), "");
        
        // check if flags are cached for this id
        final key = '$id.$type';
        if (flagsByID.exists(key))
        {
            final flags = flagsByID[key];
            if (flags == null)
                return fromGlobalCompilerFlag(type, backup);
            
            return fromString(flags);
        }
        
        // check various combos of the sub categories
        final flag = checkAllFlags(id, type);
        
        // cache the flags for this id
        if (flag != null)
        {
            flagsByID[key] = LoggerDefines.all[flag];
            return fromString(flagsByID[key]);
        }
        
        // Use global log level as backup
        flagsByID[key] = null;
        return fromGlobalCompilerFlag(type, backup);
    }
    
    static function checkAllFlags(id:String, type:LogType):Null<String>
    {
        function check(id:String)
        {
            return LoggerDefines.all.exists('$id.$type');
            // final found = LoggerDefines.all.exists('$id.$type');
            // trace('$id.$type: $found');
            // return found;
        }
        
        // check the full id
        final fullCheck = check(id);
        if (fullCheck)
            return '${id}${SUB_DELIMITER}${type}';
        
        var firstIndex = id.indexOf(SUB_DELIMITER);
        if (firstIndex == -1)
            return null;
        
        // check flags matching the sub id first
        while(firstIndex != -1)
        {
            final subFlag = id.substr(firstIndex + 1);
            if (check(subFlag))
                return '${subFlag}${SUB_DELIMITER}${type}';
            firstIndex = id.indexOf(SUB_DELIMITER, firstIndex+1);
        }
        
        // remove last sub and try again
        final lastIndex = id.lastIndexOf(SUB_DELIMITER);
        return checkAllFlags(id.substr(0, lastIndex), type);
    }
    
    
}

private enum abstract LogType(String) to String
{
    var LOG = "log";
    var THROW = "throw";
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

#if !logger.unit_test
private 
#end
class LoggerDefines
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
