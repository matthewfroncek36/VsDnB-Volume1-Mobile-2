package util.tools;

import flixel.util.FlxColor;

enum abstract AnsiCode(String) from String to String
{
    public var RESET = '\x1b[0m';

    // -- FORGROUND COLORS

    // 30-37 - NORMAL COLORS
    public var BLACK = '\x1b[30m';
    public var RED = '\x1b[31m';
    public var GREEN = '\x1b[32m';
    public var YELLOW = '\x1b[33m';
    public var BLUE = '\x1b[34m';
    public var MAGENTA = '\x1b[35m';
    public var CYAN = '\x1b[36m';
    public var WHITE = '\x1b[37m';

    // 90-97 - BRIGHT COLORS
    public var BRIGHT_BLACK = '\x1b[90m';
    public var BRIGHT_RED = '\x1b[91m';
    public var BRIGHT_GREEN = '\x1b[92m';
    public var BRIGHT_YELLOW = '\x1b[93m';
    public var BRIGHT_BLUE = '\x1b[94m';
    public var BRIGHT_MAGENTA = '\x1b[95m';
    public var BRIGHT_CYAN = '\x1b[96m';
    public var BRIGHT_WHITE = '\x1b[97m';

    
    // -- BACKGROUND COLORS

    // 40-47 - BACKGROUND COLORS
    public var BG_BLACK = '\x1b[40m';
    public var BG_RED = '\x1b[41m';
    public var BG_GREEN = '\x1b[42m';
    public var BG_YELLOW = '\x1b[43m';
    public var BG_BLUE = '\x1b[44m';
    public var BG_MAGENTA = '\x1b[45m';
    public var BG_CYAN = '\x1b[46m';
    public var BG_WHITE = '\x1b[47m';
    
    // 100-107 BRIGHT BACKGROUND COLORS
    public var BG_BRIGHT_BLACK = '\x1b[100m';
    public var BG_BRIGHT_RED = '\x1b[101m';
    public var BG_BRIGHT_GREEN = '\x1b[102m';
    public var BG_BRIGHT_YELLOW = '\x1b[103m';
    public var BG_BRIGHT_BLUE = '\x1b[104m';
    public var BG_BRIGHT_MAGENTA = '\x1b[105m';
    public var BG_BRIGHT_CYAN = '\x1b[106m';
    public var BG_BRIGHT_WHITE = '\x1b[107m';
}

enum abstract AnsiStyle(String) from String to String
{
    public var NORMAL = '0';
    public var BOLD = '1';
    public var FAINT = '2';
    public var ITALIC = '3';
    public var UNDERLINE = '4';
    public var SLOW_BLINK = '5';
    public var INVERSE = '7';
    public var STRIKETHROUGH = '9';
}

/**
 * Helper class for providing console tracing with ansi codes.
 * 
 * @see https://ansi-generator.pages.dev/
 */
class AnsiTrace
{
    #if sys
    static final REGEX_TEAMCITY_VERSION:EReg = ~/^9\.(0*[1-9]\d*)\.|\d{2,}\./;
    
    static final REGEX_TERM_256:EReg = ~/(?i)-256(color)?$/;
    
    static final REGEX_TERM_TYPES:EReg = ~/(?i)^screen|^xterm|^vt100|^vt220|^rxvt|color|ansi|cygwin|linux/;
    #end
    static final REGEX_ANSI_CODES:EReg = ~/\x1b\[[0-9;]*m/g;

    static var codesSupported:Null<Bool> = null;

    /**
     * Applies the given ansi code styles to a string.
     * @param str The string to apply the styles to.
     * @param styles The styles to apply.
     */
    public static function style(str:String, styles:Array<AnsiStyle>):String
    {
        var code:String = '\x1b[';
        for (style in styles)
        {
            code += '$style';
            if (styles.indexOf(style) != styles.length - 1)
                code += ';';
        }
        code += 'm';
        return apply(str, code);
    }
    
    /**
     * Applies the given AnsiCode to a string.
     * @param str The string to apply the ansi code to.
     * @param code The code to apply to the string.
     * @return A new string while using the given ansi code.
     */
    public static function apply(str:String, code:AnsiCode):String
    {
        if (str.indexOf(AnsiCode.RESET) != -1)
            str = str.replace(AnsiCode.RESET, "");

        return stripCodes(code + str + AnsiCode.RESET);
    }


    /**
     * FOREGROUND COLOR FUNCTIONS
     */

    @:noCompletion
    public static inline function black(str:String):String return apply(str, AnsiCode.BLACK);
    
    @:noCompletion
    public static inline function red(str:String):String return apply(str, AnsiCode.RED);
    
    @:noCompletion
    public static inline function green(str:String):String return apply(str, AnsiCode.GREEN);
    
    @:noCompletion
    public static inline function yellow(str:String):String return apply(str, AnsiCode.YELLOW);
    
    @:noCompletion
    public static inline function blue(str:String):String return apply(str, AnsiCode.BLUE);
    
    @:noCompletion
    public static inline function magenta(str:String):String return apply(str, AnsiCode.MAGENTA);
    
    @:noCompletion
    public static inline function cyan(str:String):String return apply(str, AnsiCode.CYAN);
    
    @:noCompletion
    public static inline function white(str:String):String return apply(str, AnsiCode.WHITE);
    
    // BRIGHT VARIANTS
    
    @:noCompletion
    public static inline function bright_black(str:String):String return apply(str, AnsiCode.BRIGHT_BLACK);
    
    @:noCompletion
    public static inline function bright_red(str:String):String return apply(str, AnsiCode.BRIGHT_RED);
    
    @:noCompletion
    public static inline function bright_green(str:String):String return apply(str, AnsiCode.BRIGHT_GREEN);
    
    @:noCompletion
    public static inline function bright_yellow(str:String):String return apply(str, AnsiCode.BRIGHT_YELLOW);
    
    @:noCompletion
    public static inline function bright_blue(str:String):String return apply(str, AnsiCode.BRIGHT_BLUE);
    
    @:noCompletion
    public static inline function bright_magenta(str:String):String return apply(str, AnsiCode.BRIGHT_MAGENTA);
    
    @:noCompletion
    public static inline function bright_cyan(str:String):String return apply(str, AnsiCode.BRIGHT_CYAN);
    
    @:noCompletion
    public static inline function bright_white(str:String):String return apply(str, AnsiCode.BRIGHT_WHITE);
    

    /**
     * BACKGROUND COLOR FUNCTIONS
     */

    @:noCompletion
    public static inline function bg_black(str:String):String return apply(str, AnsiCode.BG_BLACK);
    
    @:noCompletion
    public static inline function bg_red(str:String):String return apply(str, AnsiCode.BG_RED);
    
    @:noCompletion
    public static inline function bg_green(str:String):String return apply(str, AnsiCode.BG_GREEN);
    
    @:noCompletion
    public static inline function bg_yellow(str:String):String return apply(str, AnsiCode.BG_YELLOW);
    
    @:noCompletion
    public static inline function bg_blue(str:String):String return apply(str, AnsiCode.BG_BLUE);
    
    @:noCompletion
    public static inline function bg_magenta(str:String):String return apply(str, AnsiCode.BG_MAGENTA);
    
    @:noCompletion
    public static inline function bg_cyan(str:String):String return apply(str, AnsiCode.BG_CYAN);
    
    @:noCompletion
    public static inline function bg_white(str:String):String return apply(str, AnsiCode.BG_WHITE);
    
    // BRIGHT VARIANTS
    
    @:noCompletion
    public static inline function bg_bright_black(str:String):String return apply(str, AnsiCode.BG_BRIGHT_BLACK);
    
    @:noCompletion
    public static inline function bg_bright_red(str:String):String return apply(str, AnsiCode.BG_BRIGHT_RED);
    
    @:noCompletion
    public static inline function bg_bright_green(str:String):String return apply(str, AnsiCode.BG_BRIGHT_GREEN);
    
    @:noCompletion
    public static inline function bg_bright_yellow(str:String):String return apply(str, AnsiCode.BG_BRIGHT_YELLOW);
    
    @:noCompletion
    public static inline function bg_bright_blue(str:String):String return apply(str, AnsiCode.BG_BRIGHT_BLUE);
    
    @:noCompletion
    public static inline function bg_bright_magenta(str:String):String return apply(str, AnsiCode.BG_BRIGHT_MAGENTA);
    
    @:noCompletion
    public static inline function bg_bright_cyan(str:String):String return apply(str, AnsiCode.BG_BRIGHT_CYAN);
    
    @:noCompletion
    public static inline function bold(str:String):String return style(str, [AnsiStyle.BOLD]);
    
    @:noCompletion
    public static inline function faint(str:String):String return style(str, [AnsiStyle.FAINT]);
    
    @:noCompletion
    public static inline function italic(str:String):String return style(str, [AnsiStyle.ITALIC]);
    
    @:noCompletion
    public static inline function underline(str:String):String return style(str, [AnsiStyle.UNDERLINE]);
    
    @:noCompletion
    public static inline function slow_blink(str:String):String return style(str, [AnsiStyle.SLOW_BLINK]);
    
    @:noCompletion
    public static inline function inverse(str:String):String return style(str, [AnsiStyle.INVERSE]);
    
    @:noCompletion
    public static inline function strikethrough(str:String):String return style(str, [AnsiStyle.STRIKETHROUGH]);


    /**
     * Applies an AnsiCode string for a forground color with the given index.
     * @param index The index for the ansi code.
     */
    public static function fg_index(str:String, index:Int):String return apply(str, '\x1b[38;5;${index}m');

    /**
     * Applies an AnsiCode string for a foreground color with the given an `FlxColor`.
     * @param color The color to use for the ansi code.
     */
    public static function fg_rgb(str:String, color:FlxColor):String return apply(str, '\x1b[38;2;${color.red};${color.green};${color.blue}m');

    /**
     * Applies an AnsiCode string for a background color with the given index.
     * @param index The index for the ansi code.
     */
    public static function bg_index(str:String, index:Int):String return apply(str, '\x1b[48;5;${index}m');

    /**
     * Retrieves an AnsiCode string for a background color with the given an `FlxColor`.
     * @param color The color to use for the ansi code.
     */
    public static function bg_rgb(str:String, color:FlxColor):String return apply(str, '\x1b[48;2;${color.red};${color.green};${color.blue}m');


    static function getEnvSafe(name:String):Null<String>
    {
        #if sys
        return Sys.getEnv(name);
        #else
        return null;
        #end
    }

    public static function isSupported():Bool
    {
        if (codesSupported == null)
        {
            #if sys
            if (codesSupported == null)
            {
                final term:Null<String> = getEnvSafe('TERM');

                if (term == 'dumb')
                {
                    codesSupported = false;
                }
                else
                {
                    if (codesSupported != true && term != null)
                    {
                        codesSupported = REGEX_TERM_256.match(term) || REGEX_TERM_TYPES.match(term);
                    }

                    if (getEnvSafe('CI') != null)
                    {
                        final ciEnvNames:Array<String> = [
                        "GITHUB_ACTIONS", "GITEA_ACTIONS",    "TRAVIS", "CIRCLECI",
                                "APPVEYOR",     "GITLAB_CI", "BUILDKITE",    "DRONE"
                        ];

                        for (ci in ciEnvNames)
                        {
                            if (getEnvSafe(ci) != null)
                            {
                                codesSupported = true;
                                break;
                            }
                        }

                        if (codesSupported != true && getEnvSafe("CI_NAME") == "codeship")
                        {
                            codesSupported = true;
                        }
                    }

                    final teamCity:Null<String> = getEnvSafe("TEAMCITY_VERSION");

                    if (codesSupported != true && teamCity != null)
                        codesSupported = REGEX_TEAMCITY_VERSION.match(teamCity);

                    if (codesSupported != true)
                    {
                        codesSupported = getEnvSafe('TERM_PROGRAM') == 'iTerm.app'
                        || getEnvSafe('TERM_PROGRAM') == 'Apple_Terminal'
                        || getEnvSafe('COLORTERM') != null
                        || getEnvSafe('ANSICON') != null
                        || getEnvSafe('ConEmuANSI') != null
                        || getEnvSafe('WT_SESSION') != null;
                    }
                }
            }
            #else
            codesSupported = false;
            #end
        }

        return codesSupported == true;
    }

    static function stripCodes(str:String):String
    {
        return isSupported() ? str : REGEX_ANSI_CODES.replace(str, '');
    }
}