package twinlist.list
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
		private var unit:String;
		
		public function ItemAttribute(name:String = "", values:Array = null, type:uint = TYPE_GENERAL)
		{
			Name = name;
			Values = new Array();
			if (values != null)
				Values.push(values);
			Type = type;
			Unit = null;
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
		
		public function get Unit():String
		{
			return unit;
		}
		public function set Unit(unit:String):void
		{
			this.unit = unit;
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
			var str:String = name;
			if (Type == TYPE_NUMERICAL && Unit != null)
				str += " (" + Unit + ")";
			return str;
		}
		
		public function ValuesString():String
		{
			var string:String = Values.toString();
			if (Type == TYPE_NUMERICAL && Unit != null)
				string += " " + Unit;
			return string;
		}
	}
}