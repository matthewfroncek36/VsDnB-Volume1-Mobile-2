package graphics;

import flixel.FlxCamera;
import flixel.system.frontEnds.CameraFrontEnd;

/**
 * An extension of the CameraFrontEnd to make sure the game always renders `GameCamera`!
 */
class GameCameraFrontEnd extends CameraFrontEnd
{
    public override function reset(?camera:FlxCamera)
    {
        super.reset(camera ?? new GameCamera());
    }
}