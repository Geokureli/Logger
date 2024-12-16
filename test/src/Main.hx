class Main
{
    static public var log = new Logger("Special", WARN);
    static public function main():Void
    {
        log.log = (msg, ?pos) -> Logger.globalLog('SPECIAL_$msg', pos);
        log("test log");
        if (log.error.throws == false)
            log.error("test log");
        log.warn("test log");
        log.info("test log");
        log.verbose("test log");
    }
}