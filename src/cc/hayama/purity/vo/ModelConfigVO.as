package cc.hayama.purity.vo {

	public class ModelConfigVO extends ValueObject {

		//--------------------------------------
		//   Constructor 
		//--------------------------------------

		public function ModelConfigVO(params:Object = null) {
			super(params);
		}

		//--------------------------------------
		//   Property 
		//--------------------------------------

		public var className:String;

		public var voClassName:String;

		public var serviceType:String;

		public var serviceParams:String;

		public var groupData:Boolean;

		public var preload:Boolean;
	}
}
