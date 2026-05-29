package graphics.audio;

import funkin.vis.dsp.SpectralAnalyzer;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.sound.FlxSound;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import funkin.vis.dsp.SpectralAnalyzer;
import openfl.display.BlendMode;

typedef VisualizerPararms =
{
	/**
	 * The amount of bars there should be in the visualizer.
	 */
	var barCount:Int;

	/**
	 * The width of the visualizer.
	 */
	var width:Int;

	/**
	 * The height of the visualizer.
	 */
	var height:Int;

	/**
	 * The amount of pixels each bars should be spaced between from.
	 */
	var spacing:Int;

	/**
	 * Whether this visualizer should have peak lines.
	 */
	var peakLines:Bool;

	/**
	 * The color of the visualizer/bars.
	 */
	var color:FlxColor;

	/**
	 * The minimum frequency that'll be used by the analyzer to calculate the levels.
	 */
	var ?minFrequency:Float;
	
	/**
	 * The maximum frequency that'll be used by the analyzer to calculate the levels.
	 */
	var ?maxFrequency:Float;

	/**
	 * (Optional) The color of the peak lines.
	 */
	var ?peakColor:FlxColor;

	/**
	 * (Optional) The gradient colors to be used on the visualizer, if provided.
	 */
	var ?gradient:Array<FlxColor>;
}

/**
 * A group of sprites used to visualize an audio through a spectrogram.
 */
class SpectrogramVisualizer extends FlxSpriteGroup
{
	/**
	 * The analyzer used to generate the peaks, bar lines for the track.
	 */
	var analyzer:SpectralAnalyzer;

	/**
	 * The bars that are consistently updated based on the audio track's time.
	 */
	var bars:FlxSpriteGroup = new FlxSpriteGroup();

	/**
	 * A group of lines that show the song's currently peak volume.
	 */
	var peakLines:FlxSpriteGroup = new FlxSpriteGroup();

	/**
	 * The minimum frequency that's used to calculate the bars of the visualizer.
	 */
	public var minFrequency(default, set):Float;

	function set_minFrequency(value:Float):Float
	{
		if (analyzer != null)
			analyzer.minFreq = value;

		return minFrequency = value;
	}
	
	/**
	 * The maximum frequency that's used to calculate the bars of the visualizer.
	 */
	public var maxFrequency(default, set):Float;
	
	function set_maxFrequency(value:Float):Float
	{
		if (analyzer != null)
			analyzer.maxFreq = value;
		
		return maxFrequency = value;
	}

	/**
	 * The amount of bars in this visualizer.
	 */
	var barCount:Int;
	
	/**
	 * The current sound object that's being rendered to the visualizer.
	 */
	var sound:FlxSound;

	/**
	 * Whether this visualizer should have peak lines.
	 */
	public var havePeakLines(default, set):Bool;

	function set_havePeakLines(value:Bool):Bool
	{
		havePeakLines = value;

		for (i in peakLines.members)
			i.visible = value;

		return value;
	}

	/**
	 * The colors that each bar will have on the visualizer.
	 */
	public var visualizerColor(default, set):FlxColor = FlxColor.WHITE;
	
	function set_visualizerColor(value:FlxColor):FlxColor
	{
		for (i in bars.members)
		{
			i.color = value;
		}
		return visualizerColor = value;
	}

	/**
	 * The colors that each peak line will have.
	 */
	public var peakColor(default, set):FlxColor = FlxColor.WHITE;

	function set_peakColor(value:FlxColor):FlxColor
	{
		if (havePeakLines)
		{
			for (i in peakLines.members)
			{
				i.color = value;
			}
		}
		return peakColor = value;
	}

	/**
	 * The gradient color that's overlayed on each bar.
	 */
	public var gradientColor(default, set):Array<FlxColor>;

	function set_gradientColor(value:Array<FlxColor>):Array<FlxColor>
	{
		for (i in bars.members)
		{
			FlxGradient.overlayGradientOnFlxSprite(i, Std.int(i.width), Std.int(i.height), [FlxColor.WHITE]);
		}
		switch (value.length)
		{
			case 0:
				set_visualizerColor(visualizerColor);
			case 1:
				set_visualizerColor(value[0]);
			default:
				for (i in bars.members)
				{
					FlxGradient.overlayGradientOnFlxSprite(i, Std.int(i.width), Std.int(i.height), value);
				}
		}
		return gradientColor = value;
	}

	/**
	 * The blend mode for this visualizer.
	 */
	public var blendMode(default, set):BlendMode;

	function set_blendMode(value:BlendMode):BlendMode
	{
		for (i in bars.members)
			i.blend = value;

		for (i in peakLines.members)
			i.blend = value;

		return blendMode = value;
	}

	/**
	 * The width of this visualizer.
	 * Used to calculate the size of the bars.
	 */
	public var visualizerWidth(default, null):Int;

	/**
	 * The height of this visualizer.
	 * Used to calculate how tall the bars will go.
	 */
	public var visualizerHeight(default, null):Int;

	public function new(params:VisualizerPararms)
	{
		super();

		this.barCount = params.barCount;
		this.visualizerWidth = params.width;
		this.visualizerHeight = params.height;

		bars = new FlxSpriteGroup();
		add(bars);
		
		peakLines = new FlxSpriteGroup();
		add(peakLines);

		generateLines(params.barCount, visualizerWidth, visualizerHeight, params.spacing);
		generatePeakLines(params.barCount, params.width, params.spacing);


		if (params.gradient != null)
		{
			gradientColor = params.gradient;
		} else {
			visualizerColor = params.color;
		}
		
		this.peakColor = params.peakColor ?? params.color;
		this.havePeakLines = params.peakLines;
	}

	override function draw():Void
	{
		if (sound != null)
		{
			var levels = analyzer.getLevels();
			for (i in 0...min(bars.members.length, levels.length))
			{
				bars.members[i].scale.y = levels[i].value;
				if (havePeakLines)
					peakLines.members[i].y = this.y + height - (levels[i].peak * height);
			}
		}
		super.draw();
	}

	@:generic
	static inline function min<T:Float>(x:T, y:T):T
	{
		return x > y ? y : x;
	}

	public function start(sound:FlxSound):Void
	{
		this.sound = sound;

		@:privateAccess
		var source = cast sound._channel.__audioSource;

		analyzer = new SpectralAnalyzer(source, barCount, 0.1, 10, sound);
		analyzer.fftN = 512;
	}

	public function stop():Void
	{
		sound = null;
		analyzer = null;
	}

	function generateLines(barCount:Int, width:Int, height:Int, spacing:Int)
	{
		for (i in 0...barCount)
		{
			var spr = new FlxSprite((i / barCount) * width, 0).makeGraphic(Std.int((1 / barCount) * width) - spacing, height, FlxColor.WHITE);
			spr.origin.set(0, spr.height);
			bars.add(spr);
		}
	}

	function generatePeakLines(barCount:Int, width:Int, spacing:Int)
	{
		for (i in 0...barCount)
		{
			var spr = new FlxSprite((i / barCount) * width, 0).makeGraphic(Std.int((1 / barCount) * width) - spacing, 1, FlxColor.WHITE);
			peakLines.add(spr);
		}
	}

	override function set_visible(value:Bool)
	{
		super.set_visible(value);
		
		for (i in peakLines.members)
		{
			i.visible = value;
		}
		this.havePeakLines = this.havePeakLines;

		return value;
	}
}
