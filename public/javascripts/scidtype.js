function replace3f3(str) {
	str = str.substring(str.indexOf('SC') + 2);
	num = str * 1;
	return num;
}

SortableTable.prototype.addSortType( "SCID", replace3f3 );