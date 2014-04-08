package cc.hayama.purity.parsers {

	import cc.hayama.purity.PurityApp;
	import cc.hayama.purity.ViewType;
	import cc.hayama.purity.vo.ComponentConfigVO;
	import cc.hayama.purity.vo.RouteVO;
	import cc.hayama.purity.vo.ViewConfigVO;
	import cc.hayama.utils.StringUtil;

	public class AppViewConfigParser extends AppConfigParser {

		//--------------------------------------
		//   Function 
		//--------------------------------------

		override public function parse(data:Object):void {
			super.parse(data);

			var config:Vector.<ViewConfigVO> = new Vector.<ViewConfigVO>();
			_filepathes = [];

			for (var p:String in rawData) {
				if (validateName(p)) {
					var obj:Object = rawData[p];
					var vo:ViewConfigVO = new ViewConfigVO();
					var path:String = obj.path;
					var typeArr:Array;

					vo.name = p;
					vo.type = (obj.type) ? obj.type : ViewType.NORMAL;
					typeArr = vo.type.split(":");
					
					if(vo.type.indexOf(ViewType.DRAWER) >= 0) {
						vo.type = typeArr[0];
						vo.drawerDir = typeArr[1];
					}else if(vo.type.indexOf(ViewType.NAV) >= 0) {
						vo.type = typeArr[0];
						if(typeArr.length > 1) {
							vo.navScreen = typeArr[1];
						}else {
							vo.navScreen = "screen";
						}
					}
					
					vo.path = path;
					vo.className = (obj.className)
						? obj.className
						: PurityApp.packageName + ".views." + StringUtil.captitalizeFirstLetter(p + "Mediator");
					vo.isDefault = (vo.type == ViewType.NAV) ? Boolean(obj["default"]) : false;
					vo.index = obj.index;
					vo.assetClassName = obj.assetClassName;
					vo.width = obj.width;
					vo.height = obj.height;

					if (obj.asControl) {
						vo.asControl = (obj.asControl is String)
							? new ComponentConfigVO({ type: obj.asControl })
							: new ComponentConfigVO(obj.asControl);

						if (vo.asControl.footer) {
							vo.asControl.footer = parseComponents(vo.asControl.footer, vo.name);
						}

						vo.asControl.mediatorName = vo.name;
						vo.asControl.name = "asControl";
					}

					if (obj.shows) {
						var sa:Array = String(obj.shows).split(",");
						vo.shows = new Vector.<String>();
						for each (var ss:String in sa) {
							vo.shows.push(ss + ".show");
						}
					}

					if (obj.hides) {
						var ha:Array = String(obj.hides).split(",");
						vo.hides = new Vector.<String>();
						for each (var hs:String in ha) {
							vo.hides.push(hs + ".hide");
						}
					}

					if (obj.components) {
						vo.components = parseComponents(obj.components, vo.name);
					}

					if (vo.path && vo.path.length > 0 && filepathes.indexOf(vo.path) < 0) {
						filepathes.push(vo.path);
					}

					config.push(vo);
				}
			}

			config.sort(function(a:ViewConfigVO, b:ViewConfigVO):Number {
				return (a.index > b.index) ? 1 :
					(a.index < b.index) ? -1 : 0;
			});
			
			PurityApp.viewConfig = config;
		}

		private function parseComponents(obj:Object, mediatorName:String):Vector.<ComponentConfigVO> {
			var actions:Array = [
				"click", "over", "out", "up",
				"down", "doubleclick", "enter",
				"change"
				];
			var vec:Vector.<ComponentConfigVO> = new Vector.<ComponentConfigVO>();
			var parser:Function = function(data:Object, name:String = null):ComponentConfigVO {
				var item:ComponentConfigVO = new ComponentConfigVO(data);
				item.mediatorName = mediatorName;
				item.name = (name) ? name : data.name;

				if (item.item && item.item.components) {
					item.item.components = parseComponents(item.item.components, mediatorName);
				}

				for each (var ac:String in actions) {
					if (data[ac]) {
						item[ac] = createRoute(data[ac], itemName, item.mediatorName);
					}
				}

				return item;
			};

			if (obj is Array) {
				var len:int = obj.length;
				for (var i:int = 0; i < len; ++i) {
					vec.push(parser(obj[i]));
				}
			} else {
				for (var itemName:String in obj) {
					if (validateName(itemName)) {
						vec.push(parser(obj[itemName], itemName));
					}
				}
			}

			return vec;
		}

		private function createRoute(str:String, componentName:String, mediatorName:String):Array {
			var a:Array = str.split(";");
			var routes:Array = [];

			for each (var s:String in a) {
				var route:RouteVO = new RouteVO();
				var q:int = s.indexOf("?");
				var d:int = s.indexOf(".");
				var t:String = s.charAt(0);

				route.value = s;
				route.fromComponentName = componentName;
				route.fromMediatorName = mediatorName;
				route.params = (q > 0) ? genParams(s.substring(q + 1)) : null;

				if (t == "@") {
					route.gotoMediator = (q > 0) ? s.substring(1, q) : s.substring(1);
				} else if (t == "#") {
					route.mediatorName = mediatorName;
					route.mediatorMethodName = (q > 0) ? s.substring(1, q) : s.substring(1);
				} else if (t == "%") {
					// %proxy.dosomething?a=111&b=aaa
					route.proxyName = s.substring(1, d);
					route.proxyMethodName = (q > 0) ? s.substring(d + 1, q) : s.substring(d + 1);
				} else if (t == "$") {
					// $label?text=aaa
					// $label.show?a=true&b=hello
					if (d > 0) {
						route.componentName = s.substring(1, d);
						route.componentMethodName = s.substring(d + 1, q);
					} else {
						route.componentName = s.substring(1, q);
					}
				} else if (t == "!") {
					route.commandName = (q > 0) ? s.substring(1, q) : s.substring(1);
				}

				routes.push(route);
			}

			return routes;
		}

		private function genParams(str:String):Object {
			if (!str || str.length == 0) {
				return null;
			}

			// example:
			// a=343&b=hello
			// 343,hello

			var a:Array;
			var s:String;

			if (str.indexOf("&") > 0 || str.indexOf("=") > 0) {
				a = str.split("&");
				var obj:Object = {}
				for each (s in a) {
					var e:int = s.indexOf("=");
					var key:String = s.substring(1, e);
					var value:String = s.substring(e + 1);
					obj[key] = value;
				}

				return obj;
			} else {
				return str.split(",");
			}

			return str;
		}
	}
}
