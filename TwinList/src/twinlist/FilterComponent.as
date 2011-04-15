package twinlist {

	import com.carlcalderon.arthropod.Debug;
	
	import mx.containers.*;
	import mx.core.*;
	
	import spark.components.CheckBox;
	import spark.components.HGroup;
	import spark.components.HSlider;
	import spark.components.TextInput;

	public class FilterComponent extends HBox {
	
		private var checked:CheckBox;
		private var inputKey:UIComponent;
		private var type:uint;
		
		public function FilterComponent(type:uint, attribute:String) {
			super();
			if (type==ItemAttribute.TYPE_NUMERICAL)
				inputKey = new HSlider();
			else {
				inputKey = new TextInput();
				//(inputKey as TextInput).text="Testing";
			}
			checked = new CheckBox();
			checked.label=attribute;
		
			
			addChild(inputKey);
			addChild(checked);
		}

		
		public function get Checked():Boolean {
			return checked.selected;
		}

		public function set Checked(checked:Boolean):void {
			this.checked.selected=checked;
		}
		
		public function get InputKey():String {
		// Will have to treat different ways of outputing the value of this component depending on the type
			return InputKey.toString();
			if (this.type==ItemAttribute.TYPE_NUMERICAL)
				return (inputKey as HSlider).value.toString();
			else 
				return (inputKey as TextInput).text;
		}
		public function set KeyValue(keyValue:String):void {
			// Will have to treat different ways of setting the value of this component depending on the type
			if (this.type==ItemAttribute.TYPE_NUMERICAL)
				(inputKey as HSlider).value=Number(keyValue);
			else 
				(inputKey as TextInput).text=keyValue;
		}
		
	}

}

//<!-- <twinlist:FilterComponent type="ListItemAttribute.TYPE_GENERAL" desc="Name" /> -->