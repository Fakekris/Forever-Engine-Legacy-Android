package gameFolder.meta.data.font;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

using StringTools;

/**
 * Loosley based on FlxTypeText lolol
 */
class Alphabet extends FlxSpriteGroup
{
	public var textSpeed:Float = 0.05;

	private var textSize:Float;

	public var paused:Bool = false;

	// for menu shit
	public var targetY:Float = 0;
	public var disableX:Bool = false;
	public var controlGroupID:Int = 0;
	public var extensionJ:Int = 0;

	public var textInit:String;

	public var xTo = 100;

	public var isMenuItem:Bool = false;

	public var text:String = "";

	public var _finalText:String = "";
	public var _curText:String = "";

	public var widthOfWords:Float = FlxG.width;

	var yMulti:Float = 1;

	// custom shit
	// amp, backslash, question mark, apostrophy, comma, angry faic, period
	var lastSprite:AlphaCharacter;
	var xPosResetted:Bool = false;
	var lastWasSpace:Bool = false;

	var splitWords:Array<String> = [];

	var isBold:Bool = false;

	public function new(x:Float, y:Float, text:String = "", ?bold:Bool = false, typed:Bool = false, ?textSize:Float = 1)
	{
		super(x, y);

		this.text = text;
		isBold = bold;
		this.textSize = textSize;

		restartText(text, typed);
	}

	public function restartText(text, typed)
	{
		xPosResetted = true;

		_finalText = text;
		textInit = text;

		if (text != "")
		{
			if (typed)
			{
				startTypedText();
			}
			else
			{
				addText();
			}
		}
	}

	public var arrayLetters:Array<AlphaCharacter>;

	public function addText()
	{
		doSplitWords();

		arrayLetters = [];
		var xPos:Float = 0;
		for (character in splitWords)
		{
			if (character == " " || character == "-")
				lastWasSpace = true;

			var isNumber:Bool = AlphaCharacter.numbers.contains(character);
			var isSymbol:Bool = AlphaCharacter.symbols.contains(character);

			if ((AlphaCharacter.alphabet.indexOf(character.toLowerCase()) != -1) || (AlphaCharacter.numbers.contains(character)))
			{
				if (xPosResetted)
				{
					xPos = 0;
					xPosResetted = false;
				}
				else
				{
					if (lastSprite != null)
						xPos += lastSprite.width;
				}

				if (lastWasSpace)
				{
					xPos += 40;
					lastWasSpace = false;
				}

				var letter:AlphaCharacter = new AlphaCharacter(xPos, 0, textSize);

				if (isBold)
					letter.createBold(character);
				else
				{
					if (isNumber)
						letter.createNumber(character);
					else if (isSymbol)
						letter.createSymbol(character);
					else
						letter.createLetter(character);
				}

				arrayLetters.push(letter);
				add(letter);

				lastSprite = letter;
			}
		}
	}

	function doSplitWords():Void
		splitWords = _finalText.split("");

	public var personTalking:String = 'gf';

	public function startTypedText():Void
	{
		_finalText = text;
		doSplitWords();

		var loopNum:Int = 0;

		var xPos:Float = 0;
		var curRow:Int = 0;

		new FlxTimer().start(textSpeed, function(tmr:FlxTimer)
		{
			if (_finalText.fastCodeAt(loopNum) == "\n".code)
			{
				yMulti += 1;
				xPosResetted = true;
				curRow += 1;
			}

			if (splitWords[loopNum] == " ")
			{
				lastWasSpace = true;
			}

			#if (haxe >= "4.0.0")
			var isNumber:Bool = AlphaCharacter.numbers.contains(splitWords[loopNum]);
			var isSymbol:Bool = AlphaCharacter.symbols.contains(splitWords[loopNum]);
			#else
			var isNumber:Bool = AlphaCharacter.numbers.indexOf(splitWords[loopNum]) != -1;
			var isSymbol:Bool = AlphaCharacter.symbols.indexOf(splitWords[loopNum]) != -1;
			#end

			if (AlphaCharacter.alphabet.indexOf(splitWords[loopNum].toLowerCase()) != -1 || isNumber || isSymbol)
			{
				if (lastSprite != null && !xPosResetted)
				{
					lastSprite.updateHitbox();
					xPos += lastSprite.width + 3;
				}
				else
				{
					xPos = 0;
					xPosResetted = false;
				}

				if (lastWasSpace)
				{
					xPos += 20;
					lastWasSpace = false;
				}
				var letter:AlphaCharacter = new AlphaCharacter(xPos, 55 * yMulti, textSize);
				letter.row = curRow;
				if (isBold)
				{
					letter.createBold(splitWords[loopNum]);
				}
				else
				{
					if (isNumber)
						letter.createNumber(splitWords[loopNum]);
					else if (isSymbol)
						letter.createSymbol(splitWords[loopNum]);
					else
						letter.createLetter(splitWords[loopNum]);

					letter.x += 90;
				}

				if (FlxG.random.bool(40))
				{
					var daSound:String = "GF_";
					FlxG.sound.play(Paths.soundRandom(daSound, 1, 4));
				}

				add(letter);

				lastSprite = letter;
			}

			loopNum += 1;

			tmr.time = FlxG.random.float(0.04, 0.09);
		}, splitWords.length);
	}

	override function update(elapsed:Float)
	{
		if (isMenuItem)
		{
			var scaledY = FlxMath.remapToRange(targetY, 0, 1, 0, 1.3);

			y = FlxMath.lerp(y, (scaledY * 120) + (FlxG.height * 0.48), elapsed * 6);
			// lmao
			if (!disableX)
				x = FlxMath.lerp(x, (targetY * 20) + 90, elapsed * 6);
			else
				x = FlxMath.lerp(x, xTo, elapsed * 6);
		}

		if ((text != textInit))
		{
			if (arrayLetters.length > 0)
				for (i in 0...arrayLetters.length)
					arrayLetters[i].destroy();
			//
			lastSprite = null;
			restartText(text, false);
		}

		super.update(elapsed);
	}
}

class AlphaCharacter extends FlxSprite
{
	public static var alphabet:String = "abcdefghijklmnopqrstuvwxyz";

	public static var numbers:String = "1234567890";

	public static var symbols:String = "|~#$%()*+-:;<=>@[]^_.,'!?";

	public var row:Int = 0;

	private var textSize:Float = 1;

	public function new(x:Float, y:Float, ?textSize:Float = 1)
	{
		super(x, y);
		this.textSize = textSize;
		var tex = Paths.getSparrowAtlas('UI/default/base/alphabet');
		frames = tex;

		antialiasing = (!Init.trueSettings.get('Disable Antialiasing'));
	}

	public function createBold(letter:String)
	{
		if (AlphaCharacter.alphabet.indexOf(letter.toLowerCase()) != -1)
		{
			// or just load regular text
			animation.addByPrefix(letter, letter.toUpperCase() + " bold", 24);
			animation.play(letter);
			scale.set(textSize, textSize);
			updateHitbox();
		}
	}

	public function createLetter(letter:String):Void
	{
		var letterCase:String = "lowercase";
		if (letter.toLowerCase() != letter)
		{
			letterCase = 'capital';
		}

		animation.addByPrefix(letter, letter + " " + letterCase, 24);
		animation.play(letter);
		scale.set(textSize, textSize);
		updateHitbox();

		FlxG.log.add('the row' + row);

		y = (110 - height);
		y += row * 60;
	}

	public function createNumber(letter:String):Void
	{
		animation.addByPrefix(letter, letter, 24);
		animation.play(letter);

		updateHitbox();
	}

	public function createSymbol(letter:String)
	{
		switch (letter)
		{
			case '.':
				animation.addByPrefix(letter, 'period', 24);
				animation.play(letter);
				y += 50;
			case "'":
				animation.addByPrefix(letter, 'apostraphie', 24);
				animation.play(letter);
				y -= 0;
			case "?":
				animation.addByPrefix(letter, 'question mark', 24);
				animation.play(letter);
			case "!":
				animation.addByPrefix(letter, 'exclamation point', 24);
				animation.play(letter);
			default:
				animation.addByPrefix(letter, letter, 24);
				animation.play(letter);
		}

		updateHitbox();
	}
}
