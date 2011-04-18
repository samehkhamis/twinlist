package twinlist
{
	import mx.collections.ArrayCollection;
	
	public class SimilarityItem
	{
		private var l1Index:String;
		private var l2Index:String;
		private var type:int;
		private var diffs:uint;
		private var attrDiff:ArrayCollection;
		
		public static const IDENTICAL:uint = 0;
		public static const SIMILAR:uint = 1;
		public static const UNIQUE:uint = 2;

		public function SimilarityItem(l1Index:String, l2Index:String, type:uint, diffs:int, attrDiff:ArrayCollection) {
			
			this.l1Index=l1Index;
			this.l2Index=l2Index;
			this.type=type;
			this.diffs=diffs;
			this.attrDiff=attrDiff;
		}

		public function get L1Index ():String {
			return l1Index;
		}
		
		public function get L2Index ():String {
			return l2Index;
		}

		public function get Type ():uint {
			return type;
		}
		
		public function get Diffs ():uint {
			return diffs;
		}

		public function get AttrDiff ():ArrayCollection {
			return attrDiff;
		}

	}
}