package cc.hayama.purity.vo {

	public class ValueObject {

		//--------------------------------------
		//   Constructor 
		//--------------------------------------

		public function ValueObject(params:Object = null) {
			for (var param:String in params) {
				try {
					if (params[param] == "true") {
						this[param] = true;
					} else if (params[param] == "false") {
						this[param] = false;
					} else {
						this[param] = params[param];
					}
				} catch (e:Error) {
					trace("Warning: The parameter " + param + " does not exist on " + this);
				}
			}
		}

		//--------------------------------------
		//   Property 
		//--------------------------------------

		public var name:String;
	}
}
