package cc.hayama.purity.services {

	import cc.hayama.utils.ObjectUtil;
	import org.osflash.signals.Signal;

	public class AbstructService {

		//--------------------------------------
		//   Constructor 
		//--------------------------------------

		public function AbstructService() {
		}

		//--------------------------------------
		//   Property 
		//--------------------------------------

		private var _onCompleted:Signal = new Signal(String, Object);

		private var _onError:Signal = new Signal(String, Object);

		//--------------------------------------
		// Getters / setters 
		//--------------------------------------

		public function get onCompleted():Signal {
			return _onCompleted;
		}

		public function get onError():Signal {
			return _onError;
		}

		//--------------------------------------
		//   Function 
		//--------------------------------------

		public function send(... args):void {
			try {
				var f:Function = this[args[0]] as Function;
			} catch (err:Error) {
				return;
			}

			if (f.length == 0) {
				f.apply(this);
			} else {
				var a:Array = (f.length > 1 && args.length == 1)
					? ObjectUtil.toArray(args[0])
					: args;
				f.apply(this, a);
			}
		}

		public function dispose():void {
			// Override in subclasses
		}
	}
}
