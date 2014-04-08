package cc.hayama.purity.factories {

	import flash.utils.getDefinitionByName;
	
	import cc.hayama.purity.AppFacade;
	import cc.hayama.purity.ViewType;
	import cc.hayama.purity.models.ModelProxy;
	import cc.hayama.purity.views.Component;
	import cc.hayama.purity.views.ViewMediator;
	import cc.hayama.purity.vo.ComponentConfigVO;
	import cc.hayama.purity.vo.ViewConfigVO;
	
	import feathers.controls.PanelScreen;
	import feathers.controls.Screen;
	import feathers.controls.ScrollContainer;
	import feathers.controls.ScrollScreen;
	import feathers.core.FeathersControl;
	
	import starling.display.Sprite;

	public class MediatorFactory {

		//--------------------------------------
		//   Static Function 
		//--------------------------------------

		public static function create(config:ViewConfigVO):ViewMediator {
			var mediator:ViewMediator;
			var mediatorClass:Class;
			var assetClass:Class = (config.assetClassName) ? getDefinitionByName(config.assetClassName) as Class :
				(config.type == ViewType.DRAWER) ? ScrollContainer :
				(config.type == ViewType.NAV) ? (
				(config.navScreen == "panel") ? PanelScreen :
				(config.navScreen == "scroll") ? ScrollScreen : Screen) :
				Sprite;
			var control:FeathersControl;
			var component:Component;
			
			try {
				mediatorClass = getDefinitionByName(config.className) as Class;
			} catch (err:Error) {
				mediatorClass = ViewMediator;
			}

			mediator = new mediatorClass(config.name);
			mediator.type = config.type;
			mediator.drawerDir = config.drawerDir;
			mediator.index = config.index;
			mediator.isDefault = config.isDefault;
			mediator.setViewComponent(new assetClass);

			if (config.components) {
				for each (var vo:ComponentConfigVO in config.components) {
					control = ComponentFactory.create(vo);
					component = new Component(control);

					if (vo.dataSource) {
						bindComponent(component, vo.dataSource);
					}

					mediator.setComponent(vo.name, component);
					ComponentFactory.setPosition(control, vo.x, vo.y);
				}

				mediator.init();				
			}
			
			return mediator;
		}

		private static function bindComponent(component:Component, dataSource:String):void {
			var p:ModelProxy = AppFacade.instance.retrieveProxy(dataSource) as ModelProxy;
			p.onChanged.add(function(data:Object):void {
				component.setValue(data);
			});
		}
	}
}
