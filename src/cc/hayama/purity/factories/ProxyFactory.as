package cc.hayama.purity.factories {

	import flash.utils.getDefinitionByName;
	import cc.hayama.purity.models.ModelProxy;
	import cc.hayama.purity.vo.ModelConfigVO;

	public class ProxyFactory {

		//--------------------------------------
		//   Static Function 
		//--------------------------------------

		public static function create(config:ModelConfigVO):ModelProxy {
			var proxy:ModelProxy;
			var proxyClass:Class;

			try {
				proxyClass = getDefinitionByName(config.className) as Class;
			} catch (err:Error) {
				proxyClass = ModelProxy;
			}

			try {
				proxy.voClass = getDefinitionByName(config.voClassName) as Class;
			} catch (err:Error) {
				proxy.voClass = null;
			}

			proxy.loadWhileInit = config.preload;
			proxy.isGroupData = config.groupData;
			proxy.service = ServiceFactory.create(config.serviceType, config.serviceParams);
			proxy.init();

			return proxy;
		}
	}
}
