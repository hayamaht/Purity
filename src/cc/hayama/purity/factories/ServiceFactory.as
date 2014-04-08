package cc.hayama.purity.factories {

	import flash.utils.Dictionary;
	import cc.hayama.purity.services.DataService;
	import cc.hayama.purity.services.IService;
	import cc.hayama.purity.services.NullService;
	import cc.hayama.purity.services.ProxyService;
	import cc.hayama.purity.services.SharedObjectService;

	public class ServiceFactory {

		//--------------------------------------
		//   Static Property 
		//--------------------------------------

		private static var registeredServices:Dictionary = new Dictionary();

		//--------------------------------------
		//   Static Function 
		//--------------------------------------
		
		public static function init():void {
			register("data", DataService);
			register("so", SharedObjectService);
			register("proxy", ProxyService);
		}

		public static function register(type:String, serviceClass:Class):void {
			registeredServices[type] = serviceClass;
		}

		public static function create(type:String, params:String = null):IService {
			if (type == null) {
				return new NullService();
			}

			var c:Class = registeredServices[type];
			return (c != null) ? new c(params) : new NullService();
		}
	}
}
