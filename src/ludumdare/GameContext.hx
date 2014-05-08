
package ludumdare;

import flambe.animation.Ease;
import flambe.asset.AssetPack;
import flambe.display.Font;
import flambe.scene.Director;
import flambe.scene.SlideTransition;
import flambe.swf.Flipbook;
import flambe.swf.Library;
import flambe.util.MessageBundle;
import flambe.util.Random;

/** Contains all the game state that needs to get passed around. */
class GameContext
{
    /** The main asset pack. */
    public var pack (default, null) :AssetPack;

    public var director (default, null) :Director;

    // Some constructed assets
    public var messages (default, null) :MessageBundle;
    public var arialFont (default, null) :Font;

    public var random (default, null) :Random;

    /** The currently active level. */
    public var level :LevelModel;

    public function new (mainPack :AssetPack, localePack :AssetPack, director :Director)
    {
        this.pack = mainPack;
        this.director = director;

        this.random = new Random(1337);

        this.messages = MessageBundle.parse(localePack.getFile("messages.ini").toString());
        this.arialFont = new Font(pack, "fonts/handel");
    }

    public function enterPlayScene (animate :Bool = true)
    {
        director.unwindToScene(PlayScene.create(this), animate ? new SlideTransition(0.5, Ease.quadOut) : null);
    }

    public function showPrompt (text :String, message :String, buttons :Array<Dynamic>)
    {
        director.pushScene(PromptScene.create(this, text, message, 
            buttons));
    }
}
