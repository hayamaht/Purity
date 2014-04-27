package cc.hayama.purity {

	import com.junkbyte.console.Cc;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	import cc.hayama.purity.factories.ComponentFactory;
	import cc.hayama.purity.factories.ServiceFactory;
	import cc.hayama.purity.managers.LoadManager;
	import cc.hayama.purity.vo.ControllerConfigVO;
	import cc.hayama.purity.vo.ModelConfigVO;
	import cc.hayama.purity.vo.ViewConfigVO;
	import feathers.controls.Drawers;
	import feathers.controls.ScreenNavigator;
	import feathers.system.DeviceCapabilities;
	import feathers.themes.MetalWorksMobileTheme;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.events.Event;

	public class PurityApp extends Sprite {

		//--------------------------------------
		//   Static Property 
		//--------------------------------------

		public static var modelConfig:Vector.<ModelConfigVO>;

		public static var viewConfig:Vector.<ViewConfigVO>;

		public static var controllerConfig:Vector.<ControllerConfigVO>;

		public static var packageName:String;

		public static var container:starling.display.Sprite;

		public static var drawers:Drawers = new Drawers();

		public static var nav:ScreenNavigator = new ScreenNavigator();

		private static var _instance:PurityApp;

		//--------------------------------------
		//   Static getters / setters 
		//--------------------------------------

		public static function get instance():PurityApp {
			return _instance;
		}

		public static function get width():Number {
			return instance.starling.stage.stageWidth;
		}

		public static function get height():Number {
			return instance.starling.stage.stageHeight;
		}

		//--------------------------------------
		//   Static Function 
		//--------------------------------------

		public static function addView(view:DisplayObject):void {
			container.addChild(view);
		}

		public static function removeView(view:DisplayObject):void {
			container.removeChild(view);
		}

		//--------------------------------------
		//   Constructor 
		//--------------------------------------

		public function PurityApp() {
			super();

			_instance = this;

			initServiceTypes();
			initComponentTypes();

			if (stage) {
				init();
			} else {
				addEventListener(flash.events.Event.ADDED_TO_STAGE, init);
			}
		}

		//--------------------------------------
		//   Property 
		//--------------------------------------

		protected var _starling:Starling;

		protected var debug:Boolean = true;

		//--------------------------------------
		// Getters / setters 
		//--------------------------------------

		public function get starling():Starling {
			return _starling;
		}

		//--------------------------------------
		//   Function 
		//--------------------------------------

		public function setLocale(locale:String):void {
			AppLocale.currentLocale = locale;
			dispose();
			PurityAppLoader.reload();
		}

		public function dispose():void {
			AppFacade.instance.dispose();
		}

		protected function init(event:flash.events.Event = null):void {
			Cc.info("App init()");

			mouseEnabled = mouseChildren = false;
			setupStarling();

			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(flash.events.Event.RESIZE, onStageResize);

			for each (var locale:String in AppLocale.locales) {
				AppLocale.addLocaleData(locale, JSON.parse(LoadManager.getContent("locale/" + locale)));
			}

			initSlashCommands();
		}

		protected function onStageResize(event:flash.events.Event):void {
			this._starling.stage.stageWidth = this.stage.stageWidth;
			this._starling.stage.stageHeight = this.stage.stageHeight;

			AppFacade.instance.resize(PurityApp.width, PurityApp.height);

			const viewPort:Rectangle = this._starling.viewPort;
			viewPort.width = this.stage.stageWidth;
			viewPort.height = this.stage.stageHeight;
			try {
				this._starling.viewPort = viewPort;
			} catch (error:Error) {
			}
		}

		protected function setupStarling():void {
			Starling.multitouchEnabled = true;
			Starling.handleLostContext = true;

			_starling = new Starling(RootClass, stage);
			_starling.simulateMultitouch = true;
			_starling.enableErrorChecking = Capabilities.isDebugger;
			_starling.showStats = debug;
			_starling.addEventListener(starling.events.Event.ROOT_CREATED, function(event:starling.events.Event):void {
				_starling.removeEventListeners(starling.events.Event.ROOT_CREATED);
				handleStarlingReady();
			});
			_starling.start();
		}

		protected function handleStarlingReady():void {
			initFeatherTheme();
			container = _starling.stage.getChildAt(0) as starling.display.Sprite;
			drawers = new Drawers();
			nav = new ScreenNavigator();
			container.addChild(drawers);
			drawers.content = nav;
			AppFacade.instance.startup();
			handleAppReady();
		}

		protected function handleAppReady():void {
			// Override in subclasses
		}

		protected function initSlashCommands():void {
			Cc.addSlashCommand("setLocale", function(param:String):void {
				setLocale(param);
			});
		}

		protected function initFeatherTheme():void {
			// Overrde in subclasses
			new MetalWorksMobileTheme(null, DeviceCapabilities.dpi != 72);
		}

		protected function initServiceTypes():void {
			ServiceFactory.init();
		}

		protected function initComponentTypes():void {
			ComponentFactory.init();
		}
	}
}

import starling.display.Sprite;

/**
 * RootClass is the root of Starling, it is never destroyed
 * and only accessed through <code>_starling.stage</code>.
 */
internal class RootClass extends Sprite {

	//--------------------------------------
	//   Constructor 
	//--------------------------------------

	public function RootClass() {
	}
}
