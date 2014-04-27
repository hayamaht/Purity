package cc.hayama.purity.parsers {

	import cc.hayama.purity.PurityApp;
	import cc.hayama.purity.ViewType;
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

			var isArray:Boolean = rawData is Array;
			var vo:ViewConfigVO;

			for (var p:String in rawData) {
				var obj:Object = rawData[p];

				if (!(!isArray && validateName(p)) && !(isArray && validateName(obj.name))) {
					continue;
				}

				vo = parseViewConfig(obj, (isArray) ? null : p, (isArray) ? int(p) : -1);

				config.push(vo);

			}

			config.sort(function(a:ViewConfigVO, b:ViewConfigVO):Number {
				return (a.index > b.index) ? 1 :
					(a.index < b.index) ? -1 : 0;
			});

			PurityApp.viewConfig = config;
		}

		private function parseViewConfig(data:Object, name:String = null, index:int = -1):ViewConfigVO {
			var vo:ViewConfigVO = new ViewConfigVO(data);
			
			parseType(vo, data.type);

			vo.name = (name) ? name : data.name;
			vo.className = (data.className)
				? data.className
				: PurityApp.packageName + ".views." + StringUtil.captitalizeFirstLetter(vo.name + "Mediator");
			vo.isDefault = (vo.type == ViewType.NAV) ? Boolean(data["default"]) : false;
			vo.index = (index >= 0) ? index : int(data.index);
			
			if(vo.container == "panel" && (vo.header || vo.footer)) {
				if(vo.header) {
					vo.header = parseViewConfig(vo.header);
				}
				
				if(vo.footer) {
					vo.footer = parseViewConfig(vo.footer);
				}
			}

			if (data.background) {
				if (data.background is String) {
					vo.background = uint("0x" + String(data.background).substr(1));
				} else if (data.background is Object) {

				}
			}

			if (data.signals) {
				vo.signals = {};
				for (var sp:String in data.signals) {
					vo.signals[sp] = createRoute(data.signals[sp], null, vo.name);
				}
			}

			if (data.shows) {
				var sa:Array = String(data.shows).split(",");
				vo.shows = new Vector.<String>();
				for each (var ss:String in sa) {
					vo.shows.push(ss + ".show");
				}
			}

			if (data.hides) {
				var ha:Array = String(data.hides).split(",");
				vo.hides = new Vector.<String>();
				for each (var hs:String in ha) {
					vo.hides.push(hs + ".hide");
				}
			}

			if (data.children) {
				vo.children = parseChildren(data.children, vo.name, vo.layout);
			}

			return vo;
		}

		private function parseType(vo:ViewConfigVO, type:String):void {
			var typeArr:Array;

			vo.type = (type) ? type : ViewType.NORMAL;
			typeArr = vo.type.split(":");

			if (vo.type.indexOf(ViewType.DRAWER) >= 0) {
				vo.type = typeArr[0];
				vo.drawerDir = typeArr[1];
				vo.container = "scrollContainer";
			} else if (vo.type.indexOf(ViewType.NAV) >= 0) {
				vo.type = typeArr[0];
				vo.container = (typeArr.length > 1) ? typeArr[1] : "screen";
			} else if (vo.type.indexOf(ViewType.POPUP) >= 0) {
				vo.type = typeArr[0];
				vo.container = (typeArr.length > 1) ? typeArr[1] : "sprite";
			}
		}

		private function parseChildren(obj:Object, mediatorName:String, layoutData:String = null):Vector.<ViewConfigVO> {
			var actions:Array = [
				"click", "over", "out", "up",
				"down", "doubleclick", "enter",
				"change"
				];
			var vec:Vector.<ViewConfigVO> = new Vector.<ViewConfigVO>();
			var parser:Function = function(data:Object, name:String = null):ViewConfigVO {
				var item:ViewConfigVO = new ViewConfigVO(data);
				item.mediatorName = mediatorName;
				item.layoutData = layoutData;
				item.name = (name) ? name : data.name;

				if (item.item) {
					item.item.name = mediatorName;
					item.item = parseViewConfig(item.item);
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
			if(!str) {
				return null;
			}
			
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
