package modding;

import flixel.FlxG;
import polymod.Polymod.PolymodError;
import polymod.Polymod.PolymodErrorType;

class PolymodErrorHandler
{
	public static function printError(error:PolymodError):Void
	{
		var code:String = Std.string(error.code);

		switch (code)
		{
			case "SCRIPT_PARSE_FAILED":
				log(ERROR, error.message);
				showErrorAlert(error.message, "There was an error while parsing a script.");

			case "SCRIPTED_CLASS_BLACKLISTED_MODULE":
				log(ERROR, error.message);
				showErrorAlert(error.message, "Polymod Script Blacklist Error");

			case "SCRIPT_RUNTIME_EXCEPTION":
				log(ERROR, "SCRIPT RUNTIME ERROR - " + error.message);
				showErrorAlert(error.message, "There was an error while the script was running.");

			case "MOD_METADATA_PARSE_FAILED" | "MOD_VERSION_PARSE_FAILED" | "MOD_API_VERSION_PARSE_FAILED" | "APP_API_VERSION_PARSE_FAILED":
				log(ERROR, "MOD PARSING ERROR - " + error.message);
				showErrorAlert(error.message, "There was an error while parsing a mod.");

			case "SCRIPTED_CLASS_NOT_REGISTERED" | "SCRIPTED_CLASS_UNRESOLVED_IMPORT":
				log(WARNING, "SCRIPT WARNING - " + error.message);
				showErrorAlert(error.message, "Polymod Script Notice");

			case "MOD_LOAD_FAILED":
				log(INFO, "[MOD] FAILED TO LOAD - " + error.message);

			case "MOD_LOAD_START":
				log(INFO, "[MOD] LOADING - " + error.message);

			case "MOD_LOAD_DONE":
				log(INFO, "[MOD] FINISHED LOADING: " + error.message);

			case "SCRIPT_NOT_FOUND":
				log(ERROR, "SCRIPT NOT FOUND - " + error.message);

			case "SCRIPTED_CLASS_ALREADY_REGISTERED" | "SCRIPTED_CLASS_REDUNDANT_IMPORT":
				log(WARNING, "SCRIPT INFO - " + error.message);

			case "POLYMOD_NOT_INITIALIZED":
				log(ERROR, "NOT LOADED - " + error.message);

			case "MOD_MISSING_DIRECTORY":
				log(ERROR, "MISSING MOD - " + error.message);

			default:
				log(error.severity, error.message);
		}
	}

	public static function showErrorAlert(errorMessage:String, title:String):Void
	{
		#if !mobile
		if (FlxG.stage != null && FlxG.stage.application != null && FlxG.stage.application.window != null)
			FlxG.stage.application.window.alert(errorMessage, title);
		#end
	}

	public static function log(type:PolymodErrorType, message:String):Void
	{
		switch (type)
		{
			case INFO: info(message);
			case WARNING: warning(message);
			case DEBUG: debug(message);
			case ERROR: error(message);
		}
	}

	public static function info(message:String):Void
		trace("POLYMOD: INFO " + message);

	public static function warning(message:String):Void
		trace("POLYMOD: WARNING " + message);

	public static function debug(message:String):Void
		trace("POLYMOD: DEBUG " + message);

	public static function error(message:String):Void
		trace("POLYMOD: ERROR " + message);
}
