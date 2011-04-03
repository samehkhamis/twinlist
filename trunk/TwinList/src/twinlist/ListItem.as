package twinlist
{
	import mx.collections.ArrayCollection;

	[Bindable]
	public class ListItem
	{
		private var id:String;
		private var name:String;
		private var attributes:ArrayCollection = new ArrayCollection();
		
		public function ListItem(id:String, name:String = "")
		{
			this.id = id;
			this.name = name;
		}
		
		public function get Id():String
		{
			return id;
		}
		public function set Id(id:String):void
		{
			this.id = id;
		}
		
		public function get Name():String
		{
			return name;
		}
		public function set Name(name:String):void
		{
			this.name = name;
		}
		
		public function get Attributes():ArrayCollection
		{
			return attributes;
		}
		
		public function GetAttribute(name:String):ListItemAttribute
		{
			for each (var attr:ListItemAttribute in attributes) {
				if (attr.Name == name)
					return attr;
			}
			return null;
		}
		
		public function toString():String
		{
			var string:String = Name;
			for each (var attr:ListItemAttribute in attributes) {
				string += " " + attr.Value;
			}
			return string;
		}
		
		public function Equals(rhs:ListItem):Boolean
		{
			if (this.Attributes.length != rhs.Attributes.length)
				return false;
			var identical:Boolean = true;
			for each (var attr1:ListItemAttribute in this.Attributes) {
				var found:Boolean = false;
				for each (var attr2:ListItemAttribute in rhs.Attributes) {
					if (attr1.Equals(attr2)) {
						found = true;
						break;
					}
				}
				identical &&= found;
			}
			return identical;
		}
	}
}