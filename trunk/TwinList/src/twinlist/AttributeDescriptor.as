package twinlist
{
	[Bindable]
	public class AttributeDescriptor
	{
		// property keys
		public static const PROP_VALUES:String = "Values";
		public static const PROP_MINVAL:String = "MinValue";
		public static const PROP_MAXVAL:String = "MaxValue";

		private var name:String;
		private var type:uint;
		private var properties:Object;
		
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
				else
					Properties[PROP_VALUES] = new Object();
			}
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
		
		public function toString():String
		{
			return name;
		}
	}
}