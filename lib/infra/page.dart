class Page<T> {
  final List<T> data;
  final int pageNumber;
  final int pageSize;

  late bool isLastPage;

  Page(this.data, this.pageNumber, this.pageSize) {
    isLastPage = data.isEmpty || pageSize > data.length;
  }
}
