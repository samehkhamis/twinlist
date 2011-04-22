package twinlist
{
	import twinlist.list.ListItem;

	public class ListViewerItem
	{
		private var l1_unique:ListItem;
		private var l1_similar:ListItem;
		private var identical1:ListItem;
		private var identical2:ListItem;
		private var l2_similar:ListItem;
		private var l2_unique:ListItem;
		
		public function ListViewerItem()
		{
		}
		
		public function get L1Unique():ListItem
		{
			return l1_unique;
		}
		public function set L1Unique(item:ListItem):void
		{
			l1_unique = item;
		}
		
		public function get L1Similar():ListItem
		{
			return l1_similar;
		}
		public function set L1Similar(item:ListItem):void
		{
			l1_similar = item;
		}
		
		public function get Identical1():ListItem
		{
			return identical1;
		}
		public function set Identical1(item:ListItem):void
		{
			identical1 = item;
		}
		
		public function get Identical2():ListItem
		{
			return identical2;
		}
		public function set Identical2(item:ListItem):void
		{
			identical2 = item;
		}
		
		public function get L2Similar():ListItem
		{
			return l2_similar;
		}
		public function set L2Similar(item:ListItem):void
		{
			l2_similar = item;
		}
		
		public function get L2Unique():ListItem
		{
			return l2_unique;
		}
		public function set L2Unique(item:ListItem):void
		{
			l2_unique = item;
		}
	}
}