
package ludumdare;

import flambe.animation.Ease;
import flambe.display.Sprite;
import flambe.Entity;
import flambe.input.Key;
import flambe.input.KeyboardEvent;
import flambe.input.PointerEvent;
import flambe.SpeedAdjuster;
import flambe.System;
import flambe.display.ImageSprite;
import flambe.display.TextSprite;
import flambe.display.Font;
import flambe.debug.FpsDisplay;

class PlayScene
{
    /** Creates the scene where the gameplay happens. */
    public static function create (ctx :GameContext)
    {
        var scene = new Entity();

        var level = new LevelModel(ctx);
        ctx.level = level;
        scene.add(level);

        // Show a score label on the top left
        var scoreLabel = new TextSprite(ctx.arialFont);
        scoreLabel.setXY(System.stage.width / 2, 20);
        scoreLabel.centerAnchor();
        scoreLabel.setAlign(flambe.display.TextAlign.Center);
        scene.addChild(new Entity().add(scoreLabel));
        level.moves.watch(function (moves, _) {
            scoreLabel.text = "Moves used: " + moves;
            scoreLabel.setScale(1.5);
            scoreLabel.scaleX.animateTo(1.0, 0.7, Ease.elasticOut);
            scoreLabel.scaleY.animateTo(1.0, 0.7, Ease.elasticOut);
            scoreLabel.letterSpacing._ = 5;
            scoreLabel.letterSpacing.animateTo(1.0, 0.7, Ease.elasticOut);
        });

        // Show a pause button
        // var pause = new ImageSprite(ctx.pack.getTexture("buttons/Pause"));
        // pause.setXY(System.stage.width-pause.texture.width-5, 5);
        // pause.pointerDown.connect(function (_) {
        //     ctx.showPrompt(ctx.messages.get("paused"), [
        //         "Play", function () {
        //             // Unpause by unwinding to the original scene
        //             ctx.director.unwindToScene(scene);
        //         }
        //     ]);
        // });
        // scene.addChild(new Entity().add(pause));

        // --- Set custom mouse cursor
        // System.mouse.cursor = None;

        // var cursorIcon :Cursor = new Cursor(ctx, "cursors/cursor");
        // var cursor :Entity = new Entity().add(cursorIcon);

        // System.pointer.move.connect(function (event :PointerEvent) {
        //     cursor.get(Sprite).setXY(event.viewX, event.viewY);
        // });
        // scene.addChild(cursor); 
        // ---

        ctx.pack.getSound("music/main").loop(0.2);

        #if debug
        addDebugSpeedAdjuster(System.root);

        var font:Font = ctx.arialFont; 
        var fpsMeterEntity = new Entity().add(new TextSprite(font)).add(new FpsDisplay());
        System.root.addChild(fpsMeterEntity);
        #end

        return scene;
    }

    // press + or - to decrease or increase speed. returns SignalConnection
    static function addDebugSpeedAdjuster(entity :Entity) 
    {
        if (!entity.has(SpeedAdjuster)) entity.add(new SpeedAdjuster(1));
        return System.keyboard.down.connect(function(event: KeyboardEvent)
        {
            var speedAdjuster = entity.get(SpeedAdjuster);
            if (event.key == Key.Minus) // LeftBracket
            {
                speedAdjuster.scale._ /= 1.61803398875;
                trace("Speed Adjuster scale: " + entity.get(SpeedAdjuster).scale._);
            }
            else if (event.key == Key.Equals) // RightBracket 
            {
                speedAdjuster.scale._ *= 1.61803398875;
                trace("Speed Adjuster scale: " + entity.get(SpeedAdjuster).scale._);
            }
        });
    }
}
