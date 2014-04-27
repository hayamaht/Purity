package cc.hayama.purity.views {

	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import cc.hayama.purity.AppFacade;
	import cc.hayama.purity.models.ModelProxy;
	
	import feathers.controls.Button;
	import feathers.controls.ButtonGroup;
	import feathers.controls.Check;
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	import feathers.controls.List;
	import feathers.controls.NumericStepper;
	import feathers.controls.ProgressBar;
	import feathers.controls.Slider;
	import feathers.controls.TextArea;
	import feathers.controls.TextInput;
	import feathers.controls.ToggleSwitch;
	import feathers.core.FeathersControl;
	import feathers.data.ListCollection;

	public class Component {

		//--------------------------------------
		//   Static Property 
		//--------------------------------------

		private static var componentValueGetters:Dictionary = new Dictionary();

		private static var componentValueSetters:Dictionary = new Dictionary();

		//--------------------------------------
		//   Static Function 
		//--------------------------------------

		public static function register(componentClass:Class, getter:Function, setter:Function):void {
			componentValueGetters[componentClass] = getter;
			componentValueSetters[componentClass] = setter;
		}

		//--------------------------------------
		//   Constructor 
		//--------------------------------------

		public function Component(control:FeathersControl) {
			_control = control;
			controlClass = getDefinitionByName(getQualifiedClassName(control)) as Class;
		}

		//--------------------------------------
		//   Property 
		//--------------------------------------

		protected var _control:FeathersControl;

		protected var controlClass:Class;

		//--------------------------------------
		// Getters / setters 
		//--------------------------------------

		public function get control():FeathersControl { return _control; }

		//--------------------------------------
		//   Function 
		//--------------------------------------

		public function getValue():* {
			if (control is Button) {
				return Button(control).label;
			} else if (control is Check) {
				return Check(control).isSelected;
			} else if (control is ImageLoader) {
				return ImageLoader(control).source;
			} else if (control is Label) {
				return Label(control).text;
			} else if (control is NumericStepper) {
				return NumericStepper(control).value;
			} else if (control is ProgressBar) {
				return ProgressBar(control).value;
			} else if (control is Slider) {
				return Slider(control).value;
			} else if (control is TextArea) {
				return TextArea(control).text;
			} else if (control is TextInput) {
				return TextInput(control).text;
			} else if (control is ToggleSwitch) {
				return ToggleSwitch(control).isSelected;
			} else if (control is ButtonGroup) {
				return ButtonGroup(control).dataProvider;
			} else if (control is List) {
				return List(control).dataProvider;
			} else if (componentValueGetters[controlClass]) {
				return componentValueGetters[controlClass]();
			}

			return null;
		}

		public function setValue(value:*):void {
			if (control is Button) {
				Button(control).label = (value != null) ? value : "";
			} else if (control is Check) {
				Check(control).isSelected = value;
			} else if (control is ImageLoader) {
				ImageLoader(control).source = value;
			} else if (control is Label) {
				Label(control).text = (value != null) ? value : "";
			} else if (control is NumericStepper) {
				NumericStepper(control).value = (value != null) ? value : 0;
			} else if (control is ProgressBar) {
				ProgressBar(control).value = (value != null) ? value : 0;
			} else if (control is Slider) {
				Slider(control).value = (value != null) ? value : 0;
			} else if (control is TextArea) {
				TextArea(control).text = (value != null) ? value : "";
			} else if (control is TextInput) {
				TextInput(control).text = (value != null) ? value : "";
			} else if (control is ToggleSwitch) {
				ToggleSwitch(control).isSelected = value;
			} else if (control is ButtonGroup) {
				ButtonGroup(control).dataProvider = (value != null)
					? ((value is ListCollection) ? value : new ListCollection(value))
					: null;
			} else if (control is List) {
				List(control).dataProvider = (value != null)
					? ((value is ListCollection) ? value : new ListCollection(value))
					: null;
			} else if (componentValueSetters[controlClass]) {
				componentValueSetters[controlClass](value);
			}
		}

		public function bindWithProxy(name:String):void {
			var p:ModelProxy = AppFacade.instance.retrieveProxy(name) as ModelProxy;
			var component:Component = this;
			p.onChanged.add(function(data:Object):void {
				component.setValue(data);
			});
		}
	}
}
