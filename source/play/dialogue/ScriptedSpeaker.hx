package play.dialogue;

import data.dialogue.DialogueSpeakerData;
import polymod.hscript.HScriptedClass;

@:hscriptClass
class ScriptedSpeaker extends DialogueSpeaker implements HScriptedClass
{
	public function new(data:DialogueSpeakerData)
	{
		super(data);
	}

	public static function scriptInit(scriptClass:Dynamic, data:DialogueSpeakerData):DialogueSpeaker
	{
		if (scriptClass != null)
		{
			try
			{
				var created:Dynamic = Type.createInstance(scriptClass, [data]);
				if (Std.isOfType(created, DialogueSpeaker))
					return cast created;
			}
			catch (e:Dynamic)
			{
				trace('[ScriptedSpeaker] Failed to create scripted speaker: ' + Std.string(e));
			}
		}

		return new DialogueSpeaker(data);
	}
}
