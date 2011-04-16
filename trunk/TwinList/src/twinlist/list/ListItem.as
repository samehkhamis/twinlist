package twinlist.list
{
	import mx.collections.ArrayCollection;

	[Bindable]
	public class ListItem
	{
		private var id:String;
		private var name:String;
		private var attributes:Object;
		
		public function ListItem(id:String, name:String = "")
		{
			this.id = id;
			this.name = name;
			this.attributes = new Object();
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
		
		public function get Attributes():Object
		{
			return attributes;
		}
				
		public function toString():String
		{
			var string:String = Name;
			for each (var attr:ItemAttribute in attributes) {
				string += " " + attr.ValuesString();
			}
			return string;
		}
		
		public function AttributesString():String
		{
			var string:String = "";
			for each (var attr:ItemAttribute in attributes) {
				string += " " + attr.ValuesString();
			}
			return string;
		}
		
		public function Equals(rhs:ListItem):Boolean
		{
			if (this.name != rhs.name)
				return false;
			var attr1:ItemAttribute = null;
			var attr2:ItemAttribute = null;
			for each (attr1 in this.attributes) {
				attr2 = rhs.attributes[attr1.Name];
				if (attr2 == null || !attr1.Equals(attr2))
					return false;
			}
			for each (attr1 in rhs.attributes) {
				attr2 = this.attributes[attr1.Name];
				if (attr2 == null || !attr1.Equals(attr2))
					return false;
			}
			return true;
		}
	}
}