package cc.hayama.purity.controllers {

	import com.junkbyte.console.Cc;
	
	import cc.hayama.purity.AppFacade;
	import cc.hayama.purity.models.ModelProxy;
	import cc.hayama.purity.views.Component;
	import cc.hayama.purity.views.ViewMediator;
	import cc.hayama.purity.vo.RouteVO;
	import cc.hayama.utils.ObjectUtil;
	
	import feathers.core.FeathersControl;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;

	public class AppCommand extends SimpleCommand {

		//--------------------------------------
		//   Function 
		//--------------------------------------

		override public function execute(notification:INotification):void {
			switch (notification.getName()) {
				case AppFacade.ROUTE:  {
					route(notification.getBody() as Array);
					break;
				}
			}
		}

		private function route(routes:Array):void {
			if (!routes || routes.length == 0) {
				return;
			}

			Cc.info("AppCommand.route(): routes=");
			Cc.explode(routes);
			Cc.info("-= End of exploding routes =-");

			var m:ViewMediator;
			var p:ModelProxy;
			var c:Component;

			for each (var route:RouteVO in routes) {
				route.params = parseParams(route.params, route);

				if (route.gotoMediator) {
					m = facade.retrieveMediator(route.gotoMediator) as ViewMediator;
					m.data = route.params;
					m.show();
				}

				if (route.mediatorName) {
					m = facade.retrieveMediator(route.mediatorName) as ViewMediator;

					if (route.mediatorMethodName) {
						m.call(route.mediatorMethodName, route.params);
					}

					if (route.componentName) {
						c = m.getComponent(route.componentName);

						if (route.componentMethodName) {
							c[route.componentMethodName].apply(c, ObjectUtil.toArray(route.params));
						}
					}
				} else if (route.fromMediatorName) {
					m = facade.retrieveMediator(route.fromMediatorName) as ViewMediator;
					if (route.componentName) {
						c = m.getComponent(route.componentName);

						if (route.componentMethodName) {
							c[route.componentMethodName].apply(c, ObjectUtil.toArray(route.params));
						} else {
							for (var ss:String in route.params) {
								c[ss] = route.params[ss];
							}
						}
					}
				}

				if (route.proxyName && route.proxyMethodName) {
					p = facade.retrieveProxy(route.proxyName) as ModelProxy;
					p.call(route.proxyMethodName, route.params);
				}

				if (route.proxyName && route.proxyMethodName) {
					p = facade.retrieveProxy(route.proxyName) as ModelProxy;
					p.call(route.proxyMethodName, route.params);
				}
			}
		}

		private function parseParams(params:Object, route:RouteVO):Object {
			var mn:String = (route.mediatorName) ? route.mediatorName :
				(route.fromMediatorName) ? route.fromMediatorName :
				route.gotoMediator;
			var m:ViewMediator = facade.retrieveMediator(mn) as ViewMediator;

			if (!m) {
				return params;
			}

//			var c:IUIComponent = m.getComponent(route.componentName);

			for (var p:String in params) {
				var v:String = String(params[p]);
				var match1:Array = v.match(/{data.([^}]+)}/);
				var match2:Array = v.match(/{([^}]+)}/);

				if (p == "data" && v == "{data}") {
					//					params[p] = c.parent.data;
				} else if (match1 && match1.length > 1) {
					//					params[p] = c.parent.data[match1[1]];
				} else if (match2 && match2.length > 1) {
					params[p] = m.getComponent(match2[1]).getValue();
				}
			}

			return params;
		}
	}
}
