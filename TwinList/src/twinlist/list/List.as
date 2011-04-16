package twinlist.list
{
	import mx.collections.ArrayCollection;
	
	public class List extends ArrayCollection
	{
		private var id:String;
		private var name:String;
		
		public function List(id:String = null, name:String = null, source:Array = null)
		{
			super(source);
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
	}
}