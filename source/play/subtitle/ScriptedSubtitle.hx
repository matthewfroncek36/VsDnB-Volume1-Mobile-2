package play.subtitle;

import data.subtitle.SubtitleData;
import polymod.hscript.HScriptedClass;

/**
 * Scriptable subtitle class.
 *
 * SubtitleManager calls ScriptedSubtitle.scriptInit(scriptClass, data, manager).
 * Some Polymod/HScript setups do not auto-generate that static helper, so this
 * file provides a safe fallback.
 */
@:hscriptClass
class ScriptedSubtitle extends Subtitle implements HScriptedClass
{
	public function new(data:SubtitleData, manager:SubtitleManager)
	{
		super(data, manager);
	}

	public static function scriptInit(scriptClass:Dynamic, data:SubtitleData, manager:SubtitleManager):Subtitle
	{
		if (scriptClass != null)
		{
			try
			{
				var created:Dynamic = Type.createInstance(scriptClass, [data, manager]);
				if (Std.isOfType(created, Subtitle))
					return cast created;
			}
			catch (e:Dynamic)
			{
				trace('[ScriptedSubtitle] Failed to create scripted subtitle: ' + Std.string(e));
			}
		}

		return new Subtitle(data, manager);
	}
}
