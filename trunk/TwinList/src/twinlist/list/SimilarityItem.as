package twinlist.list
{	
	public class SimilarityItem
	{
		private var l1Id:String;
		private var l2Id:String;
		private var type:int;
		private var attrDiff:Array;
		
		public static const IDENTICAL:uint = 0;
		public static const SIMILAR:uint = 1;
		public static const UNIQUE:uint = 2;

		public function SimilarityItem(l1Id:String, l2Id:String, type:uint = UNIQUE, attrDiff:Array = null)
		{	
			L1Id = l1Id;
			L2Id = l2Id;
			Type = type;
			if (attrDiff != null)
				this.attrDiff = attrDiff;
			else
				this.attrDiff = new Array();
		}

		public function get L1Id():String
		{
			return l1Id;
		}
		public function set L1Id(id:String):void
		{
			l1Id = id;
		}
		
		public function get L2Id():String
		{
			return l2Id;
		}
		public function set L2Id(id:String):void
		{
			l2Id = id;
		}

		public function get Type():uint
		{
			return type;
		}
		public function set Type(type:uint):void
		{
			this.type = type;
		}

		public function get AttributeDifferences():Array
		{
			return attrDiff;
		}
	}
}