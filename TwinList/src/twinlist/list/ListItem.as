package twinlist.list
{
	import mx.collections.ArrayCollection;

	[Bindable]
	public class ListItem
	{
		private var listId:String;
		private var id:String;
		private var name:String;
		private var attributes:Object;
		private var nameUnique:Boolean;
		private var actedOn:Boolean;
		private var display:Boolean;
		
		public function ListItem(id:String, name:String = "")
		{
			ListId = null;
			Id = id;
			Name = name;
			attributes = new Object();
			NameUnique = false;
			ActedOn = false;
			Display = true;
		}
		
		public function get ListId():String
		{
			return listId;
		}
		public function set ListId(value:String):void
		{
			listId = value;
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
		
		public function get NameUnique():Boolean
		{
			return nameUnique;
		}
		public function set NameUnique(nameUnique:Boolean):void
		{
			this.nameUnique = nameUnique;
		}
		
		public function get Attributes():Object
		{
			return attributes;
		}
		
		public function get ActedOn():Boolean
		{
			return actedOn;
		}
		public function set ActedOn(value:Boolean):void
		{
			actedOn = value;
		}
		
		public function get Display():Boolean
		{
			return display;
		}
		public function set Display(value:Boolean):void
		{
			display = value;
		}
				
		public function toString():String
		{
			var string:String = Name;
			for each (var attr:ItemAttribute in Attributes) {
				string += " " + attr.ValuesString();
			}
			return string;
		}
		
		public function AttributesString():String
		{
			var string:String = "";
			for each (var attr:ItemAttribute in Attributes) {
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
			for each (attr1 in Attributes) {
				attr2 = rhs.Attributes[attr1.Name];
				if (attr2 == null || !attr1.Equals(attr2))
					return false;
			}
			for each (attr1 in rhs.Attributes) {
				attr2 = Attributes[attr1.Name];
				if (attr2 == null || !attr1.Equals(attr2))
					return false;
			}
			return true;
		}
	}
}