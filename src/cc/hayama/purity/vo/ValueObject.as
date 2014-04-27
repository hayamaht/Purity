package cc.hayama.purity.vo {

	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	public dynamic class ValueObject {

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
					trace("Warning: The parameter '" + param + "' does not exist in " + this);
				}
			}
		}

		//--------------------------------------
		//   Property 
		//--------------------------------------

		public var name:String;

		//--------------------------------------
		//   Function 
		//--------------------------------------

		public function clone():* {
			var str:String = JSON.stringify(this);
			var c:Class = getDefinitionByName(getQualifiedClassName(this)) as Class;
			var vo:ValueObject = new c(JSON.parse(str));
			return vo;
		}
	}
}
