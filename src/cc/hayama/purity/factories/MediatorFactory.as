package cc.hayama.purity.factories {

	import flash.utils.getDefinitionByName;
	
	import cc.hayama.purity.AppFacade;
	import cc.hayama.purity.models.ModelProxy;
	import cc.hayama.purity.views.Component;
	import cc.hayama.purity.views.ViewMediator;
	import cc.hayama.purity.vo.ViewConfigVO;
	
	import feathers.controls.Panel;
	import feathers.controls.PanelScreen;
	import feathers.controls.ScrollContainer;
	import feathers.controls.ScrollScreen;
	import feathers.core.FeathersControl;
	import feathers.layout.AnchorLayout;
	import feathers.layout.HorizontalLayout;
	import feathers.layout.ILayout;
	import feathers.layout.VerticalLayout;
	
	import org.osflash.signals.Signal;
	
	import starling.display.Sprite;

	public class MediatorFactory {

		//--------------------------------------
		//   Static Function 
		//--------------------------------------

		public static function create(config:ViewConfigVO):ViewMediator {
			var mediator:ViewMediator;
			var mediatorClass:Class;
			var containerClass:Class = (config.assetClassName) ? getDefinitionByName(config.assetClassName) as Class :
				(config.container == "scrollContainer") ? ScrollContainer :
				(config.container == "panelScreen") ? PanelScreen :
				(config.container == "scrollScreen") ? ScrollScreen :
				(config.container == "screen") ? ScrollScreen :
				(config.container == "panel") ? Panel :
				Sprite;

			var voClass:Class;
			var control:FeathersControl;
			var component:Component;
			var container:Sprite;
			var type:String = config.type;

			try {
				mediatorClass = getDefinitionByName(config.className) as Class;
			} catch (err:Error) {
				mediatorClass = ViewMediator;
			}

			if(config.container == "panel") {
				config.type = "panel";
				container = ComponentFactory.create(config);
			}else {
				container = new containerClass;
			}
			mediator = new mediatorClass(config.name, container);
			mediator.type = type;
			mediator.drawerDir = config.drawerDir;
			mediator.index = config.index;
			mediator.isDefault = config.isDefault;

			ComponentFactory.setupBackground(mediator.getViewComponent(), config.background, config.width, config.height);

			if (config.dataSource) {
				var proxy:ModelProxy = AppFacade.instance.retrieveProxy(config.dataSource) as ModelProxy;
				proxy.onChanged.add(function(data:Object):void {
					mediator.data = data;
				});
			}

			if (config.signals) {
				for (var p:String in config.signals) {
					setupSignal(mediator, p, config.signals[p]);
				}
			}

			if (config.layout) {
				var ly:ILayout = (config.layout == "anchor") ? new AnchorLayout() :
					(config.layout == "horizontal") ? new HorizontalLayout() :
					(config.layout == "vertical") ? new VerticalLayout() : null;

				mediator.getViewComponent().layout = ly;
			}

			if (config.children) {
				for each (var vo:ViewConfigVO in config.children) {
					control = ComponentFactory.create(vo);
					component = new Component(control);

					if (vo.dataSource) {
						bindComponent(component, vo.dataSource);
					}

					mediator.setComponent(vo.name, component);
				}
			}

			mediator.init();

			return mediator;
		}
		
		private static function setupSignal(mediator:ViewMediator, signalName:String, routes:Array):void {
			Signal(mediator[signalName]).add(function():void {
				AppFacade.instance.sendNotification(AppFacade.ROUTE, routes);
			});
		}

		private static function bindComponent(component:Component, dataSource:String):void {
			var p:ModelProxy = AppFacade.instance.retrieveProxy(dataSource) as ModelProxy;
			p.onChanged.add(function(data:Object):void {
				component.setValue(data);
			});
		}
	}
}
