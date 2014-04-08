package cc.hayama.purity {

	import com.junkbyte.console.Cc;
	
	import flash.utils.getDefinitionByName;
	
	import cc.hayama.purity.controllers.AppCommand;
	import cc.hayama.purity.factories.MediatorFactory;
	import cc.hayama.purity.factories.ProxyFactory;
	import cc.hayama.purity.models.ModelProxy;
	import cc.hayama.purity.views.ViewMediator;
	import cc.hayama.purity.vo.ControllerConfigVO;
	import cc.hayama.purity.vo.ModelConfigVO;
	import cc.hayama.purity.vo.ViewConfigVO;
	
	import feathers.controls.Drawers;
	import feathers.controls.ScreenNavigator;
	import feathers.controls.ScreenNavigatorItem;
	
	import org.puremvc.as3.patterns.facade.Facade;
	
	import starling.display.DisplayObject;

	public class AppFacade extends Facade {

		//--------------------------------------
		//	Static Const Property 
		//--------------------------------------

		public static const READY:String = "ready";

		public static const ROUTE:String = "route";

		//--------------------------------------
		//   Static Property 
		//--------------------------------------

		private static var _instance:AppFacade = new AppFacade();

		//--------------------------------------
		//   Static getters / setters 
		//--------------------------------------

		public static function get instance():AppFacade { return _instance; }

		//--------------------------------------
		//   Constructor 
		//--------------------------------------

		public function AppFacade() {
			super();
			if (_instance) {
				throw new Error("AppFacade is a singleton class");
			}
		}

		//--------------------------------------
		//   Function 
		//--------------------------------------

		public function startup():void {
			Cc.info("AppFacade.startup()");

			startupModels();
			startupViews();
			starupControllers();

			sendNotification(AppFacade.READY);
		}

		public function resize(width:Number, height:Number):void {
			var config:Vector.<ViewConfigVO> = PurityApp.viewConfig;
			var vo:ViewConfigVO;
			var len:int = config.length;
			var mediator:ViewMediator;

			for (var i:int = 0; i < len; ++i) {
				vo = config[i];
				mediator = retrieveMediator(vo.name) as ViewMediator;
				mediator.resize(width, height);
			}
		}

		public function dispose():void {
			Cc.info("AppFacade.dispose()");

			disposeModels();
			disposeViews();
		}

		override protected function initializeController():void {
			super.initializeController();
			registerCommand(ROUTE, AppCommand);
		}

		private function startupModels():void {
			var config:Vector.<ModelConfigVO> = PurityApp.modelConfig;
			var len:int = config.length;

			for (var i:int = 0; i < len; ++i) {
				registerProxy(ProxyFactory.create(config[i]));
			}
		}

		private function startupViews():void {
			var config:Vector.<ViewConfigVO> = PurityApp.viewConfig;
			var len:int = config.length;
			var vo:ViewConfigVO;
			var mediator:ViewMediator;
			var d:DisplayObject;
			var defaultMediator:ViewMediator;

			for (var i:int = 0; i < len; ++i) {
				vo = config[i];
				mediator = MediatorFactory.create(vo);
				d = mediator.getViewComponent() as DisplayObject;
				d.name = vo.name;
				
				if(vo.width) {
					d.width = vo.width;
				}
				
				if(vo.height) {
					d.height = vo.height;
				}

				if(mediator.isDefault && defaultMediator == null) {
					defaultMediator = mediator;
				}
				
				if (mediator.type == ViewType.NAV) {
					PurityApp.nav.addScreen(vo.name, new ScreenNavigatorItem(d));
				} else if (mediator.type == ViewType.DRAWER) {
					if (mediator.drawerDir == "top") {
						PurityApp.drawers.topDrawer = d;
					} else if (mediator.drawerDir == "bottom") {
						PurityApp.drawers.bottomDrawer = d;
					} else if (mediator.drawerDir == "left") {
						PurityApp.drawers.leftDrawer = d;
					} else if (mediator.drawerDir == "right") {
						PurityApp.drawers.rightDrawer = d;
					}
				}else if(mediator.type == ViewType.NORMAL) {
					PurityApp.addView(d);
				}

				registerMediator(mediator);
			}
			
			if(defaultMediator) {
				PurityApp.nav.showScreen(defaultMediator.getMediatorName());
			}
		}

		private function starupControllers():void {
			var config:Vector.<ControllerConfigVO> = PurityApp.controllerConfig;

			for each (var vo:Object in config) {
				var c:Class = getDefinitionByName(vo.className) as Class;
				registerCommand(vo.name, c);
			}
		}

		private function disposeModels():void {
			var config:Vector.<ModelConfigVO> = PurityApp.modelConfig;
			var len:int = config.length;
			var proxy:ModelProxy;

			for (var i:int = 0; i < len; ++i) {
				proxy = retrieveProxy(config[i].name) as ModelProxy;
				proxy.dispose();
			}
		}

		private function disposeViews():void {
			var config:Vector.<ViewConfigVO> = PurityApp.viewConfig;
			var len:int = config.length;
			var mediator:ViewMediator;

			for (var i:int = 0; i < len; ++i) {
				mediator = retrieveMediator(config[i].name) as ViewMediator;
				mediator.dispose();
			}
		}
	}
}
