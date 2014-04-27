package cc.hayama.purity {

	import com.greensock.loading.core.LoaderCore;
	import com.junkbyte.console.Cc;
	import flash.display.Sprite;
	import cc.hayama.purity.managers.LoadManager;
	import cc.hayama.purity.parsers.AppControllerConfigParser;
	import cc.hayama.purity.parsers.AppModelConfigParser;
	import cc.hayama.purity.parsers.AppSettingDataParser;
	import cc.hayama.purity.parsers.AppViewConfigParser;

	public class PurityAppLoader extends Sprite {

		//--------------------------------------
		//   Static Property 
		//--------------------------------------

		private static var instance:PurityAppLoader;

		//--------------------------------------
		//   Static Function 
		//--------------------------------------

		public static function reload():void {
			instance.removeChildren();
			LoadManager.clear();
			instance.load();
		}

		//--------------------------------------
		//   Constructor 
		//--------------------------------------

		public function PurityAppLoader(mainFile:String = "Main") {
			super();

			this.mainFile = mainFile;
			instance = this;

			Cc.config.commandLineAllowed = true;
			Cc.config.tracing = true;
			Cc.startOnStage(this, "`");
			initSlashCommands();
			
			load();
		}

		//--------------------------------------
		//   Property 
		//--------------------------------------

		protected var mainFile:String;

		//--------------------------------------
		// Getters / setters 
		//--------------------------------------

		public function get loadManager():LoadManager { return LoadManager.instance; }

		//--------------------------------------
		//   Function 
		//--------------------------------------

		protected function load():void {
			loadManager.onCompleted.removeAll();
			loadManager.onProgress.removeAll();
			loadManager.onError.removeAll();

			loadManager.onCompleted.add(onCompleted);
			loadManager.onProgress.add(onProgress);
			loadManager.onError.add(onError);

			initLoadingScreen();
			initLoadItems();
			loadMain();

			loadManager.start();
		}

		protected function initLoadItems():void {
			new AppConfigLoadItem("/config/app.json", new AppSettingDataParser);
			new AppConfigLoadItem("/config/controller.json", new AppControllerConfigParser);
			new AppConfigLoadItem("/config/model.json", new AppModelConfigParser);
			new AppConfigLoadItem("/config/view.json", new AppViewConfigParser);
		}

		protected function loadMain():void {
			loadManager.addItem("/" + mainFile + ".swf");
		}

		protected function onCompleted():void {
			loadManager.onCompleted.remove(onCompleted);
			loadManager.onProgress.remove(onProgress);
			loadManager.onError.remove(onError);

			removeLoadingScreen();

			addChild(LoadManager.getContent(mainFile));
		}

		protected function onProgress(progress:Number):void {
			// Overrided in subclasses
		}

		protected function onError(target:LoaderCore, text:String):void {
			// Overrided in subclasses
		}

		protected function initLoadingScreen():void {
			// Overrided in subclasses
		}

		protected function removeLoadingScreen():void {
			// Overrided in subclasses
		}

		protected function initSlashCommands():void {
			// Overrided in subclasses
		}
	}
}
