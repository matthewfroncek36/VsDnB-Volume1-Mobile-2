package ui.intro;

import data.language.LanguageManager;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.text.FlxText;

class OptionsReminderState extends MusicBeatState
{
    var textString:String = LanguageManager.getTextString('intro_warning');

    public override function create()
    {
        var text = new FlxText(0, 0, FlxG.width, textString);
        text.setFormat(Paths.font('comic.ttf'), 32, FlxColor.WHITE, FlxTextAlign.CENTER);
        text.screenCenter();
        add(text);

        addTouchPad("NONE", "A");
        
        super.create();
    }

    override function update(elapsed:Float)
    {
        if (FlxG.keys.justPressed.ENTER || touchPad != null && touchPad.buttonA.justPressed)
        {
            FlxG.save.data.hasSeenOptionsReminder = true;
            FlxG.save.flush();

            FlxG.switchState(() -> new TitleState());
        }
        super.update(elapsed);
    }
}