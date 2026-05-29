package play.dialogue;

import data.dialogue.DialogueBoxData;
import polymod.hscript.HScriptedClass;

@:hscriptClass
class ScriptedDialogue extends DialogueBox implements HScriptedClass
{
	public function new(data:DialogueBoxData)
	{
		super(data);
	}

	public static function scriptInit(scriptClass:Dynamic, data:DialogueBoxData):DialogueBox
	{
		if (scriptClass != null)
		{
			try
			{
				var created:Dynamic = Type.createInstance(scriptClass, [data]);
				if (Std.isOfType(created, DialogueBox))
					return cast created;
			}
			catch (e:Dynamic)
			{
				trace('[ScriptedDialogue] Failed to create scripted dialogue: ' + Std.string(e));
			}
		}

		return new DialogueBox(data);
	}
}
