package twinlist
{
	import mx.collections.ArrayCollection;

	[Bindable]
	public class ItemAttribute
	{
		// type constants
		public static const TYPE_GENERAL:uint = 0;
		public static const TYPE_CATEGORICAL:uint = 1;
		public static const TYPE_NUMERICAL:uint = 2;
		
		private var name:String;
		private var values:Array;
		private var type:uint;
		
		public function ItemAttribute(name:String = "", values:Array = null, type:uint = TYPE_GENERAL)
		{
			Name = name;
			Values = new Array();
			if (values != null)
				Values.push(values);
			Type = type;
		}
		
		public function get Name():String
		{
			return name;
		}
		public function set Name(name:String):void
		{
			this.name = name;
		}
		
		public function get Values():Array
		{
			return values;
		}
		public function set Values(values:Array):void
		{
			this.values = values;
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
		
		public function Equals(rhs:ItemAttribute):Boolean
		{
			if (this.Name != rhs.Name)
				return false;
			if (this.Values.length != rhs.Values.length)
				return false;
			for each (var val:Object in this.Values) {
				if (rhs.Values.indexOf(val) == -1)
					return false;
			}
			return true;
		}
		
		public function toString():String
		{
			return name;
		}
	}
}