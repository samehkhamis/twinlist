package twinlist
{
	public class Option
	{
		private var name:String;
		private var value:Object;
		
		public function Option(name:String = "", value:Object = null)
		{
			Name = name;
			Value = value;
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
	}
}