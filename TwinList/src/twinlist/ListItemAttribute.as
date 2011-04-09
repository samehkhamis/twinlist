package twinlist
{
	[Bindable]
	public class ListItemAttribute
	{
		private var name:String;
		private var values:Array;
		
		public function ListItemAttribute(name:String = "", value:Array = null)
		{
			this.name = name;
			this.values = value;
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