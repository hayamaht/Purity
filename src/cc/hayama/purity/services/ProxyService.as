package cc.hayama.purity.services {

	import cc.hayama.purity.AppFacade;
	import org.puremvc.as3.interfaces.IProxy;

	public class ProxyService extends AbstructService implements IService {

		//--------------------------------------
		//   Constructor 
		//--------------------------------------

		public function ProxyService(name:String = null) {
			super();

			this.name = name;
		}

		//--------------------------------------
		//   Property 
		//--------------------------------------

		private var _name:String;

		private var proxy:IProxy;

		//--------------------------------------
		// Getters / setters 
		//--------------------------------------

		public function get name():String { return _name; }

		public function set name(value:String):void { _name = value; }

		//--------------------------------------
		//   Function 
		//--------------------------------------

		public function init():void {
			proxy = AppFacade.instance.retrieveProxy(name);
		}

		public function load():void {
			if (!proxy) {
				init();
			}

			onCompleted.dispatch("load", proxy.getData());
		}
	}
}
