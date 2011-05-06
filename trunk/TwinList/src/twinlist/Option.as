package twinlist
{
	public class Option
	{
		// option strings
		public static const OPT_FONTSIZE:String = "__FONT_SIZE__";
		public static const OPT_ANIMATIONSPEED:String = "__ANIM_SPEED__";
		public static const OPT_LINKIDENTICAL:String = "__LINK_IDENTICAL__";
		public static const OPT_ATTRIBIDENTICAL:String = "__ATTRIB_IDENTICAL__";
		public static const OPT_AFTERACTION:String = "__AFTER_ACTION__";
		public static const OPTVAL_GRAYOUT:String = "__GRAYOUT__";
		public static const OPTVAL_REMOVE:String = "__REMOVE__";
		
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