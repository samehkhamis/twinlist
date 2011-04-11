package twinlist
{
	[Bindable]
	public class ListItemAttribute
	{
		public static const TYPE_CATEGORICAL:uint = 0;
		public static const TYPE_NUMBER:uint = 1;
		
		private var name:String;
		private var values:Array;
		private var type:uint;
		
		public function ListItemAttribute(name:String = "", values:Array = null, type:uint = TYPE_CATEGORICAL)
		{
			this.name = name;
			this.values = values;
			this.type = type;
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
			if (type > 1)
				throw new Error("Invalid ListItemAttribute type " + type);
			this.type = type;
		}
		
		public function Equals(rhs:ListItemAttribute):Boolean
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
	}
}