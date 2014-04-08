package cc.hayama.purity.vo {

	public dynamic class ComponentConfigVO extends ValueObject {

		//--------------------------------------
		//   Constructor 
		//--------------------------------------

		public function ComponentConfigVO(params:Object = null) {
			super(params);

			for (var p:String in params) {
				this[p] = params[p];
			}
		}

		//--------------------------------------
		//   Property 
		//--------------------------------------

		public var type:String;

		public var className:String;

		public var mediatorName:String;
	}
}
