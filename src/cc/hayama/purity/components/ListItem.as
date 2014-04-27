package cc.hayama.purity.components {

	import flash.utils.Dictionary;
	import cc.hayama.purity.AppFacade;
	import cc.hayama.purity.factories.ComponentFactory;
	import cc.hayama.purity.views.Component;
	import cc.hayama.purity.vo.RouteVO;
	import cc.hayama.purity.vo.ViewConfigVO;
	import feathers.controls.Button;
	import feathers.controls.renderers.LayoutGroupListItemRenderer;
	import feathers.core.FeathersControl;
	import starling.display.DisplayObject;
	import starling.events.Event;

	public class ListItem extends LayoutGroupListItemRenderer {

		//--------------------------------------
		//   Constructor 
		//--------------------------------------

		public function ListItem() {
			super();
		}

		//--------------------------------------
		//   Property 
		//--------------------------------------

		public var config:ViewConfigVO;

		protected var components:Dictionary = new Dictionary();

		private var _backgroundSkin:DisplayObject;

		private var needToInjectRoutes:Vector.<RouteVO> = new Vector.<RouteVO>();

		//--------------------------------------
		// Getters / setters 
		//--------------------------------------

		public function get backgroundSkin():DisplayObject {
			return this._backgroundSkin;
		}

		public function set backgroundSkin(value:DisplayObject):void {
			if (this._backgroundSkin == value) {
				return;
			}
			if (this._backgroundSkin) {
				this.removeChild(this._backgroundSkin, true);
			}
			this._backgroundSkin = value;
			if (this._backgroundSkin) {
				this.addChildAt(this._backgroundSkin, 0);
			}
			this.invalidate(INVALIDATION_FLAG_SKIN);
		}

		//--------------------------------------
		//   Function 
		//--------------------------------------

		override protected function postLayout():void {
			if (this._backgroundSkin) {
				this._backgroundSkin.width = this.actualWidth;
				this._backgroundSkin.height = this.actualHeight;
			}
		}

		override protected function preLayout():void {
			if (this._backgroundSkin) {
				this._backgroundSkin.width = 0;
				this._backgroundSkin.height = 0;
			}
		}

		override protected function initialize():void {
			if (!config) {
				return;
			}

			ComponentFactory.setSize(this, config.width, config.height);
			ComponentFactory.setupBackground(this, config.background, this.width, this.height);

			if (config.layout) {
				this.layout = ComponentFactory.createLayout(config.layout);
			}

			for each (var vo:ViewConfigVO in config.children) {
				var c:FeathersControl = ComponentFactory.create(vo);

				if (c is Button && vo.click) {
					injectParams(c as Button, vo);
				}

				components[vo.name] = new Component(c);
				addChild(c);
			}
		}

		override protected function commitData():void {
			if (!data || !owner) {
				return;
			}

			for (var p:String in components) {
				if (p in data) {
					components[p].setValue(data[p]);
				}
			}

			for each (var route:RouteVO in needToInjectRoutes) {
				route.params = data;
			}
		}

		protected function setComponent(name:String, component:Component):void {
			components[name] = component;
			addChild(component.control);
		}

		protected function getComponent(name:String):Component {
			return components[name];
		}

		private function injectParams(button:Button, config:ViewConfigVO):void {
			button.removeEventListeners(Event.TRIGGERED);
			var routes:Array = config.click;
			var len:int = routes.length;
			var route:RouteVO;
			var newRoutes:Array = [];
			for (var i:int = 0; i < len; ++i) {
				route = routes[i].clone();
				if (route.params == "{data}" || (route.params is Array && route.params[0] == "{data}")) {
					needToInjectRoutes.push(route);
				}
				newRoutes.push(route);
			}

			button.addEventListener(Event.TRIGGERED, function(event:Event):void {
				AppFacade.instance.sendNotification(AppFacade.ROUTE, newRoutes);
			});
		}
	}
}
