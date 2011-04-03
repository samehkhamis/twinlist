package twinlist
{
	[Bindable]
	public class ListItemAttribute
	{
		private var name:String;
		private var value:Object;
		
		public function ListItemAttribute(name:String = "", value:Object = null)
		{
			this.name = name;
			this.value = value;
		}
		
		public function get Name():String
		{
			return name;
		}
		public function set Name(name:String):void
		{
			this.name = name;
		}
		
		public function get Value():Object
		{
			return value;
		}
		public function set Value(value:Object):void
		{
			this.value = value;
		}
		
		public function Equals(rhs:ListItemAttribute):Boolean
		{
			if ((this.Name == rhs.Name) && (this.Value == rhs.Value))
				return true;
			return false;
		}
	}
}