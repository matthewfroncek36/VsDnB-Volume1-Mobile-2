package play.ui;

import backend.Conductor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.tweens.FlxTween;
import flixel.util.typeLimit.OneOfTwo;
import play.save.Preferences;
import util.tools.Preloader;

typedef RatingsType =
{
	/**
	 * The asset directory this type is in.
	 */
	var directory:String;

	/**
	 * The size of this rating type.
	 */
	var size:Float;

	/**
	 * Whether this rating type is aliased, or not.
	 */
	var antialiasing:Bool;
}

class RatingsGroup extends FlxSpriteGroup implements IHudItem
{
	final UPSCROLL_Y:Float = 550;
	final DOWNSCROLL_Y:Float = 250;
	
	/**
	 * List of all the types of ratings used, and the data for each.
	 * TODO: Probably best to softcode this.
	 */
	var types:Map<OneOfTwo<String, Array<String>>, RatingsType> = [
		'normal' => {directory: 'normal/', size: 0.7 * 0.5, antialiasing: true},
		['3d', 'shape'] => {directory: '3D/', size: 0.7 * 0.5, antialiasing: false},
		'pixel' => {directory: 'pixel/', size: 6 * 0.5, antialiasing: false}
	];

	/**
	 * The current style this group uses.
	 */
	var style(default, set):String;

	function set_style(value:String):String
	{
		if (style == value)
			return style;

		var ratingData:RatingsType = getData(value);

		cacheStyle(value);

		comboSpr.loadGraphic(Paths.image('ui/combo/${ratingData.directory}combo'));
		comboSpr.scale.set(ratingData.size, ratingData.size);
		comboSpr.updateHitbox();
		comboSpr.antialiasing = ratingData.antialiasing;

		return style = value;
	}

	public var scrollType(default, set):String;

	function set_scrollType(value:String):String
	{
		this.scrollType = value;
		if (scrollType == 'downscroll')
			this.y = DOWNSCROLL_Y;
		else
			this.y = UPSCROLL_Y;

		return value;
	}

	/**
	 * The rating sprite of this group.
	 * Updates in accordance to the style.
	 * Gets reused when popups happen for performance.
	 */
	var ratingSpr:FlxSprite;

	/**
	 * The combo sprite of this group.
	 * Updates in accordance to this style.
	 * Gets reused when popups happen for performance.
	 */
	var comboSpr:FlxSprite;

	/**
	 * Renders the combo numbers in-game.
	 */
	var comboNumbers:FlxSpriteGroup;

	public function new(style:String)
	{
		super();

		ratingSpr = new FlxSprite();
		ratingSpr.alpha = 0.0001;
		add(ratingSpr);

		comboSpr = new FlxSprite();
		comboSpr.alpha = 0.0001;
		comboSpr.scale.set(0.5, 0.5);
		add(comboSpr);

		comboNumbers = new FlxSpriteGroup();
		add(comboNumbers);

		this.style = style;
	}

	public override function draw():Void
	{
		if (!Preferences.minimalUI)
			super.draw();
	}

	/**
	 * Caches a the specified rating style.
	 * Useful to make sure the game doesn't lag when a player hits a note.
	 * @param style The style to be cached.
	 */
	public function cacheStyle(?style:String)
	{
		var data:RatingsType = getData(style);

		for (i in 0...10)
		{
			Preloader.cacheImage('ui/combo/${data.directory}num${i}');
		}
		for (i in ['bad', 'combo', 'good', 'shit', 'sick'])
		{
			Preloader.cacheImage('ui/combo/${data.directory}${i}');
		}
	}

	/**
	 * Gets the data for the specified style.
	 * @param style The style to get the data of.
	 */
	function getData(style:String)
	{
		var ratingData:RatingsType = types.get('normal');
		for (key => value in types)
		{
			if (key.contains(style))
				ratingData = value;
		}
		return ratingData;
	}

	/**
	 * Displays a visual popup showing the rating based on how a player is doing.
	 * @param rating The rating to show.
	 * @param combo The current combo the player has, used to display a 'combo' graphic if the specified combo is high enough.
	 * @param style The style the rating should be.
	 */
	public function ratingPopup(rating:String, combo:Int, ?style:String)
	{
		var ratingData:RatingsType = getData(style ?? this.style);

		showRatingsSprite(ratingData, rating);
		
		var hasCombo:Bool = combo % 50 == 0 && combo != 0;
		if (hasCombo)
		{
			showComboSprite(ratingData);
		}

		// Build combo numbers..
		buildComboNumbers(combo, ratingData);
	}

	/**
	 * Displays the current rating sprite should be.
	 * @param ratingData The style the rating sprite should be.
	 */
	function showRatingsSprite(ratingData:RatingsType, rating:String):Void
	{
		ratingSpr.loadGraphic(Paths.image('ui/combo/${ratingData.directory}${rating}'));
		ratingSpr.setGraphicSize(Std.int(ratingSpr.width * ratingData.size));
		ratingSpr.updateHitbox();
		ratingSpr.antialiasing = ratingData.antialiasing;

		// Reset the rating sprite to be re-used.
		ratingSpr.alpha = 1;
		ratingSpr.velocity.set();
		ratingSpr.acceleration.set();
		FlxTween.cancelTweensOf(ratingSpr);

		ratingSpr.x = this.x - ratingSpr.width / 2;
		ratingSpr.y = this.y;

		ratingSpr.acceleration.y = 550;
		ratingSpr.velocity.x -= FlxG.random.int(0, 10);
		ratingSpr.velocity.y -= FlxG.random.int(125, 150);
	}

	/**
	 * Displays the combo sprite for when the user reaches a specific combo.
	 * @param ratingData The style the combo sprite should be.
	 */
	function showComboSprite(ratingData:RatingsType):Void
	{
		comboSpr.loadGraphic(Paths.image('ui/combo/${ratingData.directory}combo'));
		comboSpr.scale.set(ratingData.size, ratingData.size);
		comboSpr.updateHitbox();
		comboSpr.antialiasing = ratingData.antialiasing;
		
		// Reset the combo sprite to be re-used.
		comboSpr.alpha = 1;
		comboSpr.velocity.set();
		comboSpr.acceleration.set();
		FlxTween.cancelTweensOf(comboSpr);

		comboSpr.x = this.x + ratingSpr.width + 10;
		comboSpr.y = this.y;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.x += FlxG.random.int(1, 10);
		comboSpr.velocity.y -= 150;

		ratingTween(comboSpr);
	}

	/**
	 * Builds all combo numbers based on the user's current combo.
	 * @param combo The combo to display.
	 * @param ratingData The style that the numbers should be.
	 */
	function buildComboNumbers(combo:Int, ratingData:RatingsType):Void
	{
		var comboSplit:Array<String> = Std.string(combo).split('');
		var seperatedScore:Array<Int> = [for (num in comboSplit) Std.parseInt(num)];

		var numList:Array<FlxSprite> = [];
		for (i in 0...seperatedScore.length)
		{
			var numScore:FlxSprite = createComboNumber(comboSplit[i], ratingData);
			positionComboNumber(numScore, numList);
			
			comboNumbers.add(numScore);
			numList.push(numScore);
			
			ratingTween(numScore, 0.75, function(tween:FlxTween)
			{
				comboNumbers.remove(numScore, true);
				numScore.destroy();
				numScore = null;
			});
		}
		ratingTween(ratingSpr, 1);
	}

	/**
	 * Builds a combo number sprite.
	 * @param combo The number for the sprite to show.
	 * @param ratingData The style of the combo.
	 * @return FlxSprite
	 */
	function createComboNumber(combo:String, ratingData:RatingsType):FlxSprite
	{
		var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image('ui/combo/${ratingData.directory}num${combo}'));
		numScore.velocity.set();
		numScore.acceleration.set();
		numScore.alpha = 1;
		numScore.visible = true;
		FlxTween.cancelTweensOf(numScore);

		numScore.antialiasing = ratingData.antialiasing;
		numScore.scale.set(ratingData.size, ratingData.size);
		numScore.updateHitbox();

		numScore.velocity.x = FlxG.random.float(-5, 5);
		numScore.velocity.y -= FlxG.random.int(80, 90);
		numScore.acceleration.y = FlxG.random.int(200, 300);

		return numScore;
	}

	/**
	 * Positions the given combo number depending on how many sprites there currently are being rendered.
	 * @param list The list of sprites currently made.
	 */
	function positionComboNumber(comboNumerSprite:FlxSprite, list:Array<FlxSprite>):Void
	{
		if (list.length == 0)
		{
			// Center the number to the combo sprite.
			comboNumerSprite.x = (this.ratingSpr.x - this.x) + (ratingSpr.width - comboNumerSprite.width) / 2;
			comboNumerSprite.y = (this.ratingSpr.y - this.y) - ratingSpr.height - 10;
		}
		else
		{
			comboNumerSprite.x = (list[list.length - 1].x - this.x) + comboNumerSprite.width + 2;
			comboNumerSprite.y = (list[list.length - 1].y - this.y);
		}
	}

	/**
	 * Helper function to a quick tween relating to ratings.
	 * @param spr The rating sprite to do a tween of.
	 * @param delayTime Delay time before the rating disappears. Defaults to 1.
	 * @param onComplete Function to call when the tween is complete.
	 */
	function ratingTween(spr:FlxSprite, delayTime:Float = 1, ?onComplete:FlxTween->Void)
	{
		FlxTween.tween(spr, {alpha: 0}, 0.2, {onComplete: onComplete, startDelay: (Conductor.instance.crochet / 1000) * delayTime});
	}
	
	function onPreferenceChange(preference:String, value:Any)
	{
		if (preference == 'downscroll')
		{
			if (value == 'downscroll')
			{
				for (number in comboNumbers.members)
					number.y += (DOWNSCROLL_Y - UPSCROLL_Y);
			}
			else
			{
				for (number in comboNumbers.members)
					number.y -= (DOWNSCROLL_Y - UPSCROLL_Y);
			}
		}
	}
}