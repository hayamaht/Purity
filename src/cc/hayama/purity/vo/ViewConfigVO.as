package cc.hayama.purity.vo {

	public class ViewConfigVO extends ValueObject {

		//--------------------------------------
		//   Constructor 
		//--------------------------------------

		public function ViewConfigVO(params:Object = null) {
			super(params);
		}

		//--------------------------------------
		//   Property 
		//--------------------------------------

		public var type:String;

		public var className:String;

		public var path:String;

		public var assetClassName:String;

		public var components:Vector.<ComponentConfigVO>;

		public var isDefault:Boolean;

		public var index:int;

		public var shows:Vector.<String>;

		public var hides:Vector.<String>;

		public var asControl:ComponentConfigVO;
		
		public var drawerDir:String;
		
		public var navScreen:String;
		
		public var width:Number;
		
		public var height:Number;
	}
}
