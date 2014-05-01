
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

        this.hurtParams = new vault.SfxrParams();
        this.hurtParams.generateHitHurt();

        this.jumpParams = new vault.SfxrParams();
        this.jumpParams.generateJump();

        this.powerupParams = new vault.SfxrParams();
        this.powerupParams.generatePowerup();

        this.explosionParams = new vault.SfxrParams();
        this.explosionParams.generateExplosion();

        this.beepParams = new vault.SfxrParams();
        this.beepParams.generateBlipSelect();

        this.coinParams = new vault.SfxrParams();
        this.coinParams.generatePickupCoin();
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

    private var hurtParams :vault.SfxrParams;
    public function playHurt() {
        hurtParams.mutate();
        hurtParams.masterVolume = 0.3;
        var sfxr = new vault.Sfxr(hurtParams);
        sfxr.play();
    }

    private var jumpParams :vault.SfxrParams;
    public function playJump() {
        jumpParams.mutate();
        jumpParams.masterVolume = 0.2;
        var sfxr = new vault.Sfxr(jumpParams);
        sfxr.play();
    }

    private var powerupParams :vault.SfxrParams;
    public function playPowerup() {
        powerupParams.mutate();
        powerupParams.masterVolume = 0.3;
        var sfxr = new vault.Sfxr(powerupParams);
        sfxr.play();
    }

    private var explosionParams :vault.SfxrParams;
    public function playExplosion() {
        explosionParams.mutate();
        explosionParams.sustainTime = 0.3;
        explosionParams.masterVolume = 0.3;
        var sfxr = new vault.Sfxr(explosionParams);
        sfxr.play();
    }

    private var beepParams :vault.SfxrParams;
    public function playBeep() {
        beepParams.mutate();
        beepParams.masterVolume = 0.3;
        var sfxr = new vault.Sfxr(beepParams);
        sfxr.play();
    }

    private var coinParams :vault.SfxrParams;
    public function playCoin() {
        coinParams.mutate();
        coinParams.masterVolume = 0.3;
        var sfxr = new vault.Sfxr(coinParams);
        sfxr.play();
    }

    // public function playSound() {
    //     var params = new vault.SfxrParams();
    //     params.waveType = 0;
    //     params.squareDuty = 0.55555*0.6;
    //     params.startFrequency = 0.3 + 0.55555*0.3;
    //     params.slide = 0.1 + 0.55555*0.2;
    //     params.attackTime = 0.0;
    //     params.sustainTime = 0.1 + 0.55555*0.3;
    //     params.decayTime = 0.1 + 0.55555*0.2;
    //     params.masterVolume = 0.4;

    //     // taken from as3sfxr:
    //     //params = vault.SfxrParams.fromString("0,,0.2193,,0.4748,0.3482,,0.0691,,,,,,0.3482,,,,,1,,,,,0.5");
    //     var sfxr = new vault.Sfxr(params);
    //     sfxr.play();
    // }
}
