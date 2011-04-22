package twinlist.list
{
	import mx.collections.ArrayCollection;
	import twinlist.list.ItemAttribute;


	[Bindable]
	public class AttributeDescriptor
	{
		// property keys
		public static const PROP_MINVAL:String = "MinValue";
		public static const PROP_MAXVAL:String = "MaxValue";
		public static const PROP_UNIT:String = "Unit";

		private var name:String;
		private var type:uint;
		private var properties:Object;
		private var values:ArrayCollection;
		
		public function AttributeDescriptor(name:String = "", type:uint = -1, properties:Object = null)
		{
			Name = name;
			if (type != -1)
				Type = type;
			else
				Type = ItemAttribute.TYPE_GENERAL;
			if (properties != null)
				Properties = properties;
			else {
				Properties = new Object();
				if (type == ItemAttribute.TYPE_NUMERICAL) {
					Properties[PROP_MINVAL] = Number.NaN;
					Properties[PROP_MAXVAL] = Number.NaN;
				}
			}
			Values = new ArrayCollection();
		}
		
		public function get Name():String
		{
			return name;
		}
		public function set Name(name:String):void
		{
			this.name = name;
		}
		
		public function get Type():uint
		{
			return type;
		}
		public function set Type(type:uint):void
		{
			if (type > 2)
				throw new Error("Invalid ListItemAttribute type " + type);
			this.type = type;
		}

		
		public function get Properties():Object
		{
			return properties;
		}
		public function set Properties(properties:Object):void
		{
			this.properties = properties;
		}
		
		public function get Values():ArrayCollection
		{
			return values;
		}
		public function set Values(values:ArrayCollection):void
		{
			this.values = values;
		}
	        public function addValue(value:Object):void
	        {
		        this.Values.addItem(value)
		}
	  
		public function toString():String
		{
			var str:String = name;
			if (Type == ItemAttribute.TYPE_NUMERICAL && Properties[PROP_UNIT] != null)
				str += " (" + Properties[PROP_UNIT] + ")";
			return str;
		}
	        public function getAttributeType(attrType:String):uint
                {
		  var type:int = -1;
		  switch (attrType) {
		  case "Categorical":
		    type = ItemAttribute.TYPE_CATEGORICAL;
		    break;
		  case "Numerical":
		    type = ItemAttribute.TYPE_NUMERICAL;
		    break;
		  default:
		    type = ItemAttribute.TYPE_GENERAL;
		    break;
		  }
		  return type;
		}
	  
	}
	
}